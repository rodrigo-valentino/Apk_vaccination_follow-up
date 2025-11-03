import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our test app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: CounterTestPage()));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

class CounterTestPage extends StatefulWidget {
  const CounterTestPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CounterTestPageState createState() => _CounterTestPageState();
}

class _CounterTestPageState extends State<CounterTestPage> {
  int _counter = 0;

  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Test')),
      body: Center(child: Text('$_counter', style: const TextStyle(fontSize: 24))),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
