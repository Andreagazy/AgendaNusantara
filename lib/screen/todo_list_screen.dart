// lib/screen/task_list_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/toDoList.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<ToDo> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await Database_helper.instance.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _toggleStatus(ToDo todo) async {
    await Database_helper.instance.updateStatus(todo.id!, !todo.isDone);
    _loadTasks();
  }

  Future<void> _editTask(ToDo todo) async {
    final taskController = TextEditingController(text: todo.task);
    final descController = TextEditingController(text: todo.description);
    DateTime selectedDate = DateTime.parse(todo.dueDate);
    String selectedCategory = todo.category;

    final updatedTodo = await showDialog<ToDo>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isPenting = selectedCategory == 'penting';
            final accentColor = isPenting
                ? Colors.red
                : const Color(0xFF2D8B7A);

            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(primary: accentColor),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                setDialogState(() => selectedDate = picked);
              }
            }

            return AlertDialog(
              title: const Text('Update Task'),
              backgroundColor: Colors.white,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        labelText: 'Judul tugas',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tanggal jatuh tempo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatTanggal(selectedDate.toIso8601String()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Penting'),
                          selected: selectedCategory == 'penting',
                          selectedColor: Colors.red.withOpacity(0.15),
                          onSelected: (value) {
                            if (value) {
                              setDialogState(
                                () => selectedCategory = 'penting',
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Biasa'),
                          selected: selectedCategory == 'biasa',
                          selectedColor: const Color(
                            0xFF2D8B7A,
                          ).withOpacity(0.15),
                          onSelected: (value) {
                            if (value) {
                              setDialogState(() => selectedCategory = 'biasa');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final task = taskController.text.trim();
                    final description = descController.text.trim();

                    if (task.isEmpty || description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Judul dan deskripsi tidak boleh kosong!',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      ctx,
                      todo
                        ..task = task
                        ..description = description
                        ..dueDate = selectedDate.toIso8601String().substring(
                          0,
                          10,
                        )
                        ..category = selectedCategory,
                    );
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    taskController.dispose();
    descController.dispose();

    if (updatedTodo != null) {
      await Database_helper.instance.updateTask(updatedTodo);
      _loadTasks();
    }
  }

  Future<void> _hapusTugas(int id) async {
    // Konfirmasi sebelum hapus
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Apakah kamu yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await Database_helper.instance.deleteTask(id);
      _loadTasks();
    }
  }

  String _formatTanggal(String isoDate) {
    final date = DateTime.parse(isoDate);
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${bulan[date.month - 1]} '
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D8B7A),
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? _buildKosong()
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _tasks.length,
                itemBuilder: (ctx, i) => _buildTaskItem(_tasks[i]),
              ),
            ),
    );
  }

  // ===== WIDGET ITEM TUGAS =====
  Widget _buildTaskItem(ToDo todo) {
    final isPenting = todo.category == 'penting';
    final arrowColor = isPenting ? Colors.red : const Color(0xFF2D8B7A);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: () => _editTask(todo),

        // ===== CHECKBOX =====
        leading: GestureDetector(
          onTap: () => _toggleStatus(todo),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: todo.isDone ? const Color(0xFF2D8B7A) : Colors.transparent,
              border: Border.all(
                color: todo.isDone ? const Color(0xFF2D8B7A) : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: todo.isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),

        // ===== JUDUL & SUBTITLE =====
        title: Text(
          todo.task,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${_formatTanggal(todo.dueDate)} · '
            '${todo.category[0].toUpperCase()}${todo.category.substring(1)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ),

        // ===== IKON PANAH + HAPUS =====
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, color: arrowColor, size: 28),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _hapusTugas(todo.id!),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.grey,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== WIDGET JIKA LIST KOSONG =====
  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada tugas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah tugas baru dari halaman Beranda',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
