import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'signin_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filter = 'Semua';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _logout() async {
    await AuthService().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  Future<void> _showAddOrEditTodoDialog({String? initial, String? id}) async {
    final controller = TextEditingController(text: initial ?? '');
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeInOut,
            ),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 32,
                      offset: Offset(0, 12),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.22),
                    width: 1.5,
                  ),
                  backgroundBlendMode: BlendMode.overlay,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.purpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.18),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        id == null ? Icons.add_task_rounded : Icons.edit,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      id == null ? 'Tambah Tugas' : 'Edit Tugas',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.blueAccent,
                        letterSpacing: 1.2,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tulis tugas...',
                        hintStyle: GoogleFonts.poppins(color: Colors.blueAccent.shade100),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.blueAccent.shade100, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        fillColor: Colors.white.withOpacity(0.10),
                        filled: true,
                      ),
                      onSubmitted: (val) => Navigator.of(context).pop(val),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text('Batal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.purpleAccent,
                            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: null,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 6,
                            shadowColor: Colors.blueAccent.withOpacity(0.2),
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.purpleAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                id == null ? 'Tambah Tugas' : 'Simpan',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      final user = _auth.currentUser;
      if (user == null) return;
      if (id == null) {
        await _firestore.collection('users').doc(user.uid).collection('todos').add({
          'text': result,
          'done': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tugas berhasil ditambahkan!', style: GoogleFonts.poppins()), backgroundColor: Colors.green.shade600),
        );
      } else {
        await _firestore.collection('users').doc(user.uid).collection('todos').doc(id).update({
          'text': result,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tugas berhasil diubah!', style: GoogleFonts.poppins()), backgroundColor: Colors.blue.shade600),
        );
      }
    }
  }

  Future<void> _deleteTodo(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('todos').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Tugas dihapus!'), backgroundColor: Colors.red.shade400),
    );
  }

  Future<void> _toggleDone(String id, bool done) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('todos').doc(id).update({'done': done});
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final user = _auth.currentUser;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () async {
            await AuthService().signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
              (route) => false,
            );
          },
        ),
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.blueAccent.shade100,
                Colors.purpleAccent.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            'Catatan Tugas',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.2,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: Offset(0, 2)),
                Shadow(color: Colors.white.withOpacity(0.15), blurRadius: 0, offset: Offset(0, 0)),
              ],
            ),
          ),
          blendMode: BlendMode.srcIn,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blueAccent),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blueGrey.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.25),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddOrEditTodoDialog(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
          tooltip: 'Tambah Tugas',
        ),
      ),
      body: Stack(
        children: [
          // Background gradasi
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.grey.shade900,
                  Colors.grey.shade800,
                  Colors.grey.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Ilustrasi/logo watermark di pojok kanan bawah
          Positioned(
            right: -60,
            bottom: -60,
            child: Opacity(
              opacity: 0.13,
              child: Image.asset(
                'icons/logo_ilustration.png',
                width: isWide ? 340 : 180,
                height: isWide ? 340 : 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Konten utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                children: [
                  // Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final f in ['Semua', 'Belum Selesai', 'Selesai'])
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: _filter == f ? Colors.blueAccent.shade100.withOpacity(0.18) : Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _filter == f
                                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.18), blurRadius: 8, offset: Offset(0, 4))]
                                  : [],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => setState(() => _filter = f),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  child: Text(
                                    f,
                                    style: GoogleFonts.poppins(
                                      color: _filter == f ? Colors.blueAccent : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // List tugas
                  Expanded(
                    child: user == null
                        ? Center(child: Text('User tidak ditemukan', style: GoogleFonts.poppins(color: Colors.white)))
                        : StreamBuilder<QuerySnapshot>(
                            stream: _firestore.collection('users').doc(user.uid).collection('todos').orderBy('createdAt', descending: true).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.13),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.deepPurple.withOpacity(0.18),
                                              blurRadius: 24,
                                              offset: Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(32),
                                        child: Icon(Icons.check_circle_outline_rounded, color: Colors.blueAccent.shade100, size: 72),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Belum ada tugas, yuk mulai catat tugasmu! ✨',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              var docs = snapshot.data!.docs;
                              if (_filter == 'Selesai') {
                                docs = docs.where((d) => d['done'] == true).toList();
                              } else if (_filter == 'Belum Selesai') {
                                docs = docs.where((d) => d['done'] != true).toList();
                              }
                              return ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: docs.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  final data = doc.data() as Map<String, dynamic>;
                                  final text = data['text'] ?? '';
                                  final done = data['done'] ?? false;
                                  final created = data.containsKey('createdAt') && data['createdAt'] != null
                                      ? DateFormat('dd MMM yyyy, HH:mm').format((data['createdAt'] as Timestamp).toDate())
                                      : '';
                                  return AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: Duration(milliseconds: 500 + (index * 50)),
                                    child: Card(
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      color: done
                                          ? Colors.blueAccent.withOpacity(0.18)
                                          : Colors.white.withOpacity(0.13),
                                      shadowColor: done
                                          ? Colors.blueAccent.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.2),
                                      child: ListTile(
                                        leading: Checkbox(
                                          value: done,
                                          onChanged: (_) => _toggleDone(doc.id, !done),
                                          activeColor: Colors.blueAccent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        title: Text(
                                          text,
                                          style: GoogleFonts.poppins(
                                            color: done ? Colors.grey.shade400 : Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            decoration: done ? TextDecoration.lineThrough : null,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        subtitle: created.isNotEmpty ? Text('Dibuat: $created', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)) : null,
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 24),
                                              tooltip: 'Edit',
                                              onPressed: () => _showAddOrEditTodoDialog(initial: text, id: doc.id),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
                                              tooltip: 'Hapus',
                                              onPressed: () => _deleteTodo(doc.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
