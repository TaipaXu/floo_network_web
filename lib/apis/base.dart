import 'package:web_socket_channel/web_socket_channel.dart';

typedef OnMessage = void Function(String message);

void start({required String ip, required int port, OnMessage? onMessage}) {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://$ip:$port'),
  );

  channel.stream.listen((dynamic message) {
    print('Received: $message');
    onMessage?.call(message as String);
  });
}
