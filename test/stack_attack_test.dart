import 'package:stack_attack/stack_attack.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  group('StackTraceFormatter', () {
    test('', () async {
      final formatter = await StackTraceFormatter.create(
        includeFrameNumbers: true,
      );
      print(formatter.formatParsed(Trace.parse(stackTrace)));
    });
  });
}

const stackTrace = '''
#0      ClientSocketHandler._clientConnected (package:walkii_server/src/handler/client_socket_handler.dart:64:5)
#1      ClientSocketHandler.onConnect.<anonymous closure> (package:walkii_server/src/handler/client_socket_handler.dart:34:15)
#2      ClientSocketHandler.onConnect.<anonymous closure> (package:walkii_server/src/handler/client_socket_handler.dart:33:7)
#3      runZonedGuardedFinally.<anonymous closure> (package:walkii_foundation/src/zone.dart:13:30)
#4      runZonedGuardedFinally.<anonymous closure> (package:walkii_foundation/src/zone.dart:12:37)
#5      _rootRun (dart:async/zone.dart:1428:13)
#6      _CustomZone.run (dart:async/zone.dart:1328:19)
#7      _runZoned (dart:async/zone.dart:1863:10)
#8      runZonedGuarded (dart:async/zone.dart:1851:12)
#9      runZonedGuardedFinally (package:walkii_foundation/src/zone.dart:12:10)
#10     ClientSocketHandler.onConnect (package:walkii_server/src/handler/client_socket_handler.dart:32:11)
#11     webSocketHandler.<anonymous closure> (package:shelf_web_socket/shelf_web_socket.dart:48:55)
#12     WebSocketHandler.handle.<anonymous closure> (package:shelf_web_socket/src/web_socket_handler.dart:81:20)
#13     _fromHttpRequest.onHijack.<anonymous closure> (package:shelf/shelf_io.dart:167:35)
#14     _rootRunUnary (dart:async/zone.dart:1436:47)
#15     _CustomZone.runUnary (dart:async/zone.dart:1335:19)
<asynchronous suspension>
''';
