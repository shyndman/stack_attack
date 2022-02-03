// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:stack_attack/stack_attack.dart';

void main() async {
  final formatter =
      await StackTraceFormatter.create(packageNamesToResolve: ['stack_attack']);
  print(formatter.format(a()));
}

StackTrace a() {
  return b();
}

StackTrace b() {
  return c();
}

StackTrace c() {
  late StackTrace st;
  [1, 2, 3].forEach((element) {
    st = StackTrace.current;
  });
  return st;
}
