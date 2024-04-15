import 'dart:io';

import 'package:console/console.dart';
import 'package:icecast/src/stream.dart';

void main() async {
  var icecastStream = Stream(
    url: "stream.rekt.network",
    resource: "datawave.ogg",
  );
  var subscription = await icecastStream.connect();

  // Wait for the header to be parsed before printing.
  await Future.delayed(Duration(seconds: 1)); // Adjust the delay as needed.

  print('Header: ${icecastStream.header?.contentType}');

  // Set lineMode to false to listen for each byte of input.
  stdin.lineMode = false;

  // Start a command-line interface.
  while (true) {
    stdout.write("Enter a command: (\"help\" for help)\n\$ ");

    // Read a line of input from the user.
    var input = Console.readLine();

    // Remove the "$ " prefix from the input.
    // input = input.startsWith('\$ ') ? input?.substring(2) : input;
    input?.substring(2);

    // Execute the command.
    switch (input?.toLowerCase()) {
      case 'c':
        // Stop the stream when the 'C' command is entered.
        subscription.cancel();
        print('Stopped listening.');
        break;
      case 'help':
        // Print a help message when the 'help' command is entered.
        print('Help:\n'
            '- "close" to stop listening.\n'
            '- "help" for this help message.\n'
            '- "quit" or "exit" to quit the program.');
        break;
      case 'exit':
      case 'quit':
        // Exit the program when the 'exit' or 'quit' command is entered.
        print('Exiting program.');
        exit(0);
        break;
      default:
        // Print an error message if the command doesn't exist.
        print('Error: Command not found.');
        break;
    }
  }
}
