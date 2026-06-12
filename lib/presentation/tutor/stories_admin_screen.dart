import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/models/story_override_model.dart';
import '../../data/repositories/story_repository.dart';
import 'story_edit_screen.dart';

class StoriesAdminScreen extends StatefulWidget {
  const StoriesAdminScreen({super.key});

  @override
  State<StoriesAdminScreen> createState() => _StoriesAdminScreenState();
}

class _StoriesAdminScreenState extends State<StoriesAdminScreen> {
  final StoryRepository _repository = StoryRepository();

  List<StoryLevelSummary> ideaLevels = [];
  List<StoryLevelSummary> rapidLevels = [];
  bool loading = true;
  String? tutorEmail;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    tutorEmail = user?.email;

    if (tutorEmail == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    final idea = await _repository.listLevels(
      tutorEmail: tutorEmail!,
      game: StoryGameType.ideaPrincipal,
    );

    final rapid = await _repository.listLevels(
      tutorEmail: tutorEmail!,
      game: StoryGameType.preguntasRapidas,
    );

    if (!mounted) return;

    setState(() {
      ideaLevels = idea;
      rapidLevels = rapid;
      loading = false;
    });
  }

  int _nextLevel(List<StoryLevelSummary> levels) {
    if (levels.isEmpty) {
      return 1;
    }

    return levels.map((item) => item.level).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> openEditor({
    required String game,
    required int level,
    bool isNew = false,
  }) async {
    if (tutorEmail == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StoryEditScreen(
          tutorEmail: tutorEmail!,
          game: game,
          level: level,
          isNewLevel: isNew,
        ),
      ),
    );

    if (result == true) {
      await loadData();
    }
  }

  Widget _categorySection({
    required String title,
    required IconData icon,
    required Color color,
    required String game,
    required List<StoryLevelSummary> levels,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => openEditor(
                    game: game,
                    level: _nextLevel(levels),
                    isNew: true,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo'),
                ),
              ],
            ),
          ),
          if (levels.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No hay niveles disponibles.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: levels.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = levels[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Text(
                      '${item.level}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                    item.isNewLevel
                        ? 'Nivel nuevo'
                        : item.isCustomized
                        ? 'Personalizado'
                        : 'Contenido predeterminado',
                    style: TextStyle(color: isDark ? Colors.white70 : null),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () => openEditor(game: game, level: item.level),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Historias'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.blue.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.menu_book, color: Colors.white, size: 48),
                          SizedBox(height: 12),
                          Text(
                            'Personaliza historias',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Edita el contenido predeterminado o agrega nuevos niveles.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _categorySection(
                      title: 'Idea Principal',
                      icon: Icons.lightbulb,
                      color: Colors.orange,
                      game: StoryGameType.ideaPrincipal,
                      levels: ideaLevels,
                    ),
                    _categorySection(
                      title: 'Preguntas Rápidas',
                      icon: Icons.quiz,
                      color: Colors.purple,
                      game: StoryGameType.preguntasRapidas,
                      levels: rapidLevels,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
