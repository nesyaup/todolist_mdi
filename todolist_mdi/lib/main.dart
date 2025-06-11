import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'todo_screen.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBQ-9AB2EMSOB-2jtUvyyq51dD9KRvW1pc",
      authDomain: "todolist-412a2.firebaseapp.com",
      projectId: "todolist-412a2",
      storageBucket: "todolist-412a2.appspot.com", // ← diperbaiki
      messagingSenderId: "926307458175",
      appId: "1:926307458175:web:1acab3192bf3babaff334a",
      measurementId: "G-34TSRWFY4V",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: FutureBuilder<String?>(
        future: AuthService().getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return TodoScreen();
          } else {
            return SignInScreen();
          }
        },
      ),
      routes: {
        '/signin': (_) => SignInScreen(),
        '/signup': (_) => SignUpScreen(),
        '/todo': (_) => TodoScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      FirebaseFirestore.instance.collection('tasks').add({
        'title': text,
        'isDone': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  void _toggleTask(DocumentSnapshot doc) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(doc.id)
        .update({'isDone': !(doc['isDone'] ?? false)});
  }

  void _deleteTask(String docId) {
    FirebaseFirestore.instance.collection('tasks').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Tambahkan tugas...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Tambah'),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('Belum ada tugas'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final title = doc['title'];
                    final isDone = doc['isDone'] ?? false;

                    return ListTile(
                      title: Text(
                        title,
                        style: TextStyle(
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      leading: Checkbox(
                        value: isDone,
                        onChanged: (_) => _toggleTask(doc),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(doc.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
