import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Appearance Section
                _buildSectionHeader('Appearance'),
                const SizedBox(height: 16),

                // Dark Mode Toggle
                _buildSettingCard(
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark themes',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),

                const SizedBox(height: 12),

                // Color Theme Selection
                _buildSettingCard(
                  title: 'Color Theme',
                  subtitle: 'Choose your preferred color scheme',
                  trailing: DropdownButton<String>(
                    value: themeProvider.selectedTheme,
                    dropdownColor: Theme.of(context).cardColor,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    items: const [
                      DropdownMenuItem(
                          value: 'default', child: Text('Default (Red)')),
                      DropdownMenuItem(value: 'blue', child: Text('Blue')),
                      DropdownMenuItem(value: 'green', child: Text('Green')),
                      DropdownMenuItem(value: 'purple', child: Text('Purple')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setTheme(value);
                      }
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Auto Dark Mode
                _buildSettingCard(
                  title: 'Auto Dark Mode',
                  subtitle: 'Automatically switch based on system settings',
                  trailing: Switch(
                    value: themeProvider.autoDarkMode,
                    onChanged: (value) => themeProvider.toggleAutoDarkMode(),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),

                const SizedBox(height: 32),

                // Reading Section
                _buildSectionHeader('Reading Experience'),
                const SizedBox(height: 16),

                // Reading History
                _buildSettingCard(
                  title: 'Reading History',
                  subtitle: 'View and manage your reading history',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/recently-viewed');
                  },
                ),

                const SizedBox(height: 12),

                // Bookmarks
                _buildSettingCard(
                  title: 'Bookmarks',
                  subtitle: 'Manage your saved articles',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/bookmarks');
                  },
                ),

                const SizedBox(height: 32),

                // About Section
                _buildSectionHeader('About'),
                const SizedBox(height: 16),

                _buildSettingCard(
                  title: 'Version',
                  subtitle: '1.0.0',
                  trailing: const Icon(Icons.info_outline, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                _buildSettingCard(
                  title: 'Privacy Policy',
                  subtitle: 'Learn how we protect your data',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // Navigate to privacy policy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Privacy Policy coming soon')),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildSettingCard(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // Navigate to terms of service
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Terms of Service coming soon')),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
