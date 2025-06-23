import 'package:app/ui/todo/todo_page.dart';
import 'package:app/vaden_application.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(VadenApp(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TodoPage(),
    );
  }
}
