import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    const themeModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: themeModes.length,
        itemBuilder: (context, index) {
          final themeMode = themeModes[index];
          final isSelected = themeMode == themeProvider.themeMode;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? const BorderSide(color: AppConstants.primaryGreen, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.primaryGreen.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  themeProvider.getThemeModeIcon(themeMode),
                  color: isSelected ? AppConstants.primaryGreen : Colors.grey,
                  size: 26,
                ),
              ),
              title: Text(
                themeProvider.getThemeModeDisplayName(themeMode),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppConstants.primaryGreen : null,
                ),
              ),
              subtitle: Text(
                _getThemeDescription(themeMode),
                style: TextStyle(
                  color: isSelected
                      ? AppConstants.primaryGreen.withValues(alpha: 0.7)
                      : null,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle,
                      color: AppConstants.primaryGreen)
                  : const Icon(Icons.radio_button_unchecked,
                      color: Colors.grey),
              onTap: () async {
                await themeProvider.setThemeMode(themeMode);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Theme changed to ${themeProvider.getThemeModeDisplayName(themeMode)}'),
                      backgroundColor: AppConstants.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
            const SizedBox(height: 8),
            Text(
              'System default will automatically switch between light and dark mode based on your device settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeDescription(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system settings';
    }
  }
}
