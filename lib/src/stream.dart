import 'dart:async';
import 'dart:io';

import 'header.dart';

/// Handles Icecast streams.
class Stream {
  String url;
  String resource;
  Socket? socket;
  int port;

  StreamSubscription? subscription;
  Header? header;

  Stream(
      {String url = "stream.rekt.network",
      String resource = "datawave.ogg",
      Socket? socket,
      int? port})
      : url = url,
        resource = resource,
        socket = socket,
        port = 80 {
    print('Stream initialized.');
  }

  /// Connect to an Icecast stream.
  Future<StreamSubscription> connect() async {
    socket = await Socket.connect(url, port);

    // Send request to server.
    socket!.writeln('GET /$resource HTTP/1.1');
    socket!.writeln('Host: $url');
    socket!.writeln('Icy-MetaData: 1');
    socket!.writeln('User-Agent: Icecast.dart/0.0.1');
    socket!.writeln('Accept: */*');
    socket!.writeln('Connection: Close');
    socket!.writeln();

    // Wait for the socket to be connected.
    await socket!.flush();

    // Check if the socket is still open before starting to listen.
    if (socket != null) {
      // Start listening to the socket.
      subscription = startListening();
    } else {
      throw Exception('Socket is closed');
    }

    // Wait for the header to be parsed.
    while (header == null) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    return subscription!;
  }

  /// Listen to the stream and parse the header.
  StreamSubscription startListening() {
    var headerBuffer = StringBuffer();
    var headerComplete = false;
    var prevCharCode;
    var totalData = 0;
    var startTime = DateTime.now();
    var maxRatePerSecond = <int, double>{};
    var currentSecond = 0;

    subscription = socket!.listen(
      (data) {
        final response = String.fromCharCodes(data);
        headerBuffer.write(response);

        for (var charCode in data) {
          if (prevCharCode == 13 && charCode == 10) {
            // Check for CRLF
            if (headerBuffer.toString().endsWith('\r\n\r\n')) {
              headerComplete = true;
              break;
            }
          }
          prevCharCode = charCode;
        }

        if (headerComplete) {
          // Store the parsed header.
          header = Header(headerBuffer.toString());
          headerComplete = false; // Reset for next header
        } else {
          // Calculate the total data streamed and the rate of streaming.
          totalData += data.length;
          var duration = DateTime.now().difference(startTime);
          var rate = totalData / duration.inSeconds;

          // Update the max rate for the current second if the current rate is higher.
          if (duration.inSeconds > currentSecond) {
            currentSecond = duration.inSeconds;
            maxRatePerSecond[currentSecond] = rate;
            print(
                'New max rate at second $currentSecond: ${maxRatePerSecond[currentSecond]} bytes/sec');
          } else if (rate > (maxRatePerSecond[currentSecond] ?? 0)) {
            maxRatePerSecond[currentSecond] = rate;
            print(
                'New max rate at second $currentSecond: ${maxRatePerSecond[currentSecond]} bytes/sec');
          }
        }
      },
      // Handle done event.
      onDone: () {
        socket!.close();
      },
      // Handle error event.
      onError: (error) {
        print('Error: $error');
      },
    );

    return subscription!;
  }
}
