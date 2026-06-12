import 'package:flutter/material.dart';

import '../../core/accessibility/accessibility_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibility = AccessibilityController.instance;

    return AnimatedBuilder(
      animation: accessibility,
      builder: (context, _) {
        final theme = Theme.of(context);
        final hasMusic = accessibility.backgroundTrack != null;

        return Scaffold(
          appBar: AppBar(title: const Text('Accesibilidad')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Personaliza tu experiencia',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Modo oscuro'),
                  subtitle: const Text('Cambia los colores de la app.'),
                  value: accessibility.darkMode,
                  onChanged: accessibility.setDarkMode,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.format_size),
                        title: Text('Tamaño de letra'),
                        subtitle: Text('Aumenta o reduce el texto.'),
                      ),
                      Slider(
                        min: 0.9,
                        max: 1.4,
                        divisions: 5,
                        label: '${(accessibility.fontScale * 100).round()}%',
                        value: accessibility.fontScale,
                        onChanged: accessibility.setFontScale,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.music_note),
                        title: const Text('Música de fondo'),
                        subtitle: Text(
                          hasMusic
                              ? 'Activa o quita la música.'
                              : 'Agrega un audio en assets/sounds/.',
                        ),
                        value: accessibility.musicEnabled,
                        onChanged: accessibility.setMusicEnabled,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.volume_down),
                          Expanded(
                            child: Slider(
                              min: 0,
                              max: 1,
                              divisions: 10,
                              label:
                                  '${(accessibility.musicVolume * 100).round()}%',
                              value: accessibility.musicVolume,
                              onChanged: accessibility.setMusicVolume,
                            ),
                          ),
                          const Icon(Icons.volume_up),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
