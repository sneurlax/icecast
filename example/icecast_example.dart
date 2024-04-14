import 'dart:io';

void main() async {
  final url = 'stream.rekt.network';
  final resource = 'datawave.ogg';

  final socket = await Socket.connect(url, 80);

  socket.writeln('GET /$resource HTTP/1.1');
  socket.writeln('Host: $url');
  socket.writeln('Icy-MetaData: 1');
  socket.writeln('User-Agent: WinampMPEG/2.9');
  socket.writeln('Accept: */*');
  socket.writeln('Connection: Close');
  socket.writeln();

  var header = StringBuffer();
  var headerComplete = false;
  var prevCharCode;

  await for (var data in socket) {
    final response = String.fromCharCodes(data);
    header.write(response);

    for (var charCode in data) {
      if (prevCharCode == 13 && charCode == 10) { // Check for CRLF
        if (header.toString().endsWith('\r\n\r\n')) {
          headerComplete = true;
          break;
        }
      }
      prevCharCode = charCode;
    }

    if (headerComplete) {
      break;
    }
  }

  print(header.toString());
  socket.close();
}
