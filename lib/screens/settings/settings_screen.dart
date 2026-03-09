import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../screens/listings/my_listings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final theme = Theme.of(context);
    final user = auth.firebaseUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      (user?.email?.isNotEmpty == true
                          ? user!.email![0].toUpperCase()
                          : '?'),
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    auth.userProfile?.displayName ?? 'Kigali User',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '—',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info section
          _SectionHeader(label: 'Account Info'),
          _InfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.email ?? '—',
          ),
          _InfoTile(
            icon: Icons.fingerprint_rounded,
            label: 'User ID',
            value: user?.uid ?? '—',
            mono: true,
          ),
          _InfoTile(
            icon: Icons.verified_rounded,
            label: 'Email verified',
            value: (user?.emailVerified ?? false) ? 'Yes ✓' : 'Not verified',
            valueColor: (user?.emailVerified ?? false)
                ? Colors.green
                : theme.colorScheme.error,
          ),
          const SizedBox(height: 16),

          // My Listings section
          _SectionHeader(label: 'My Listings'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.list_alt_rounded,
                color: theme.colorScheme.primary,
              ),
              title: const Text(
                'My Services',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('View and manage your listings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyListingsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Preferences section
          _SectionHeader(label: 'Preferences'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
              title: const Text(
                'Push Notifications',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Receive alerts for new listings nearby'),
              secondary: Icon(
                Icons.notifications_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // About section
          _SectionHeader(label: 'About'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'App Version',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.location_city,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    'About Kigali Services',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Find essential services in Kigali'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Kigali Services',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          '© 2024 Kigali City Services Directory',
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'A comprehensive directory for discovering essential services and places of interest across Kigali city.',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<ap.AuthProvider>().signOut();
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool mono;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: mono ? 11 : 14,
            fontFamily: mono ? 'monospace' : null,
            color: valueColor ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
