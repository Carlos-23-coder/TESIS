import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/models/user_model.dart' as app_user;
import '../../data/repositories/user_repository.dart';
import 'create_tutor_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final UserRepository _userRepository = UserRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<app_user.User> _localUsers = [];
  bool _loadingLocal = true;

  @override
  void initState() {
    super.initState();
    _loadLocalUsers();
  }

  Future<void> _loadLocalUsers() async {
    final users = await _userRepository.getUsersByRoles([
      'Tutor',
      'Alumno',
    ]);

    if (!mounted) return;

    setState(() {
      _localUsers = users;
      _loadingLocal = false;
    });
  }

  Future<void> _openCreateTutor() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateTutorScreen()),
    );

    if (created == true) {
      await _loadLocalUsers();
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  List<_AdminUser> _mergeUsers(QuerySnapshot? snapshot) {
    final usersByEmail = <String, _AdminUser>{};

    for (final localUser in _localUsers) {
      usersByEmail[localUser.email.toLowerCase()] = _AdminUser(
        username: localUser.username,
        email: localUser.email,
        role: localUser.role,
        source: 'Local',
      );
    }

    if (snapshot != null) {
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final role = data['role']?.toString() ?? '';

        if (role != 'Tutor' && role != 'Alumno') {
          continue;
        }

        final email = (data['email'] ?? doc.id).toString().toLowerCase();

        usersByEmail[email] = _AdminUser(
          username: data['username']?.toString() ?? 'Sin nombre',
          email: email,
          role: role,
          source: 'Firebase',
        );
      }
    }

    final users = usersByEmail.values.toList()
      ..sort((a, b) {
        final roleCompare = a.role.compareTo(b.role);

        if (roleCompare != 0) {
          return roleCompare;
        }

        return a.username.compareTo(b.username);
      });

    return users;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark ? const Color(0xFF1D4ED8) : Colors.blueAccent;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: headerColor,
        title: const Text('Administrador'),
        actions: [
          IconButton(
            tooltip: 'Accesibilidad',
            icon: const Icon(Icons.accessibility_new),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            tooltip: 'Cerrar sesion',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTutor,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Crear tutor'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          final users = _mergeUsers(snapshot.hasData ? snapshot.data : null);
          final tutors = users.where((user) => user.role == 'Tutor').toList();
          final students =
              users.where((user) => user.role == 'Alumno').toList();

          return RefreshIndicator(
            onRefresh: _loadLocalUsers,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 58,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Panel de administracion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Crea tutores y revisa los usuarios registrados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _infoBox(
                      icon: Icons.cloud_off,
                      color: Colors.orange,
                      text:
                          'No se pudo cargar Firebase. Se muestran datos locales.',
                    ),
                  ),
                if (_loadingLocal && !snapshot.hasData)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _statCard(
                          title: 'Tutores',
                          value: tutors.length.toString(),
                          icon: Icons.supervisor_account,
                          color: Colors.purple,
                        ),
                        _statCard(
                          title: 'Alumnos',
                          value: students.length.toString(),
                          icon: Icons.school,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  _userSection(
                    title: 'Tutores registrados',
                    icon: Icons.supervisor_account,
                    color: Colors.purple,
                    users: tutors,
                    emptyText: 'No hay tutores registrados.',
                  ),
                  _userSection(
                    title: 'Alumnos registrados',
                    icon: Icons.school,
                    color: Colors.green,
                    users: students,
                    emptyText: 'No hay alumnos registrados.',
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 34, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_AdminUser> users,
    required String emptyText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(emptyText),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(
                    user.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.email),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: user.source == 'Firebase'
                          ? Colors.blue.withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.source,
                      style: TextStyle(
                        color: user.source == 'Firebase'
                            ? Colors.blue
                            : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _AdminUser {
  final String username;
  final String email;
  final String role;
  final String source;

  const _AdminUser({
    required this.username,
    required this.email,
    required this.role,
    required this.source,
  });
}
