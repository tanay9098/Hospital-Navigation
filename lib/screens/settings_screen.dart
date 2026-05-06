import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(settingsProvider.translate('settings')),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(settingsProvider.translate('enable_voice')),
            subtitle: Text(settingsProvider.translate('voice_language') + ': ' + settingsProvider.supportedLanguages[settingsProvider.selectedLanguageCode]!),
            value: settingsProvider.isVoiceEnabled,
            onChanged: (bool value) {
              settingsProvider.setVoiceEnabled(value);
            },
            secondary: const Icon(Icons.volume_up),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(settingsProvider.translate('display_language')),
            trailing: DropdownButton<String>(
              value: settingsProvider.selectedLanguageCode,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  settingsProvider.loadLanguage(newValue);
                }
              },
              items: settingsProvider.supportedLanguages.entries
                  .map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
