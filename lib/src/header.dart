/// A Stream's header.
class Header {
  late String contentType;

  Header(String rawHeader) {
    print('Raw Header:');
    print(rawHeader);

    final lines = rawHeader.split('\r\n');
    for (var line in lines) {
      if (line.startsWith('Content-Type:')) {
        contentType = line.split(' ')[1];
        print('Content-Type Found: $contentType');
      }
    }
  }
}
