// lib/main.dart

import 'package:flutter/material.dart';
import 'screen/add_task_screen.dart';
import 'screen/login.dart';
import 'screen/home_screen.dart';
import 'screen/setting_screen.dart';
import 'screen/todo_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Nusantara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D8B7A),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoginScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/add-penting': (ctx) => const AddTaskScreen(category: 'penting'),
        '/add-biasa': (ctx) => const AddTaskScreen(category: 'biasa'),
        '/todo-list': (ctx) => const TodoListScreen(),
        // Nanti ditambah setelah screen dibuat:
        '/pengaturan': (ctx) => const SettingsScreen(),
      },
    );
  }
}