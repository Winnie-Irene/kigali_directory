import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final listingProvider = context.watch<ListingProvider>();
    final user = authProvider.firebaseUser;
    final profile = authProvider.userProfile;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F3460), Color(0xFF0D0D1A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Settings',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => _showEditProfileDialog(context, authProvider),
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4ECDC4), Color(0xFF0F3460)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                (profile?.displayName.isNotEmpty == true) ? profile!.displayName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ECDC4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF0D0D1A), width: 2),
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile?.displayName ?? 'Loading...',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.username.isNotEmpty == true ? '@${profile!.username}' : user?.email ?? '',
                      style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14),
                    ),
                    if (profile?.bio.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile!.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF8892B0), fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatChip(Icons.list_alt, '${listingProvider.userListings.length}', 'Listings'),
                        const SizedBox(width: 16),
                        _buildStatChip(Icons.bookmark, '${listingProvider.favouriteListings.length}', 'Saved'),
                        const SizedBox(width: 16),
                        _buildStatChip(
                          user?.emailVerified == true ? Icons.verified : Icons.warning_amber,
                          user?.emailVerified == true ? 'Verified' : 'Unverified',
                          'Status',
                          color: user?.emailVerified == true ? const Color(0xFF4ECDC4) : const Color(0xFFFFE66D),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Account'),
                    _buildSettingsGroup([
                      _buildSettingsTile(
                        icon: Icons.person_outline,
                        iconColor: const Color(0xFF4ECDC4),
                        title: 'Edit Profile',
                        subtitle: 'Update name, username and bio',
                        onTap: () => _showEditProfileDialog(context, authProvider),
                      ),
                      _buildSettingsTile(
                        icon: Icons.lock_outline,
                        iconColor: const Color(0xFF74B9FF),
                        title: 'Change Password',
                        subtitle: 'Update your login password',
                        onTap: () => _showChangePasswordDialog(context, authProvider),
                      ),
                      _buildSettingsTile(
                        icon: Icons.email_outlined,
                        iconColor: const Color(0xFFFFE66D),
                        title: 'Email Address',
                        subtitle: user?.email ?? '',
                        showArrow: false,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Preferences'),
                    _buildSettingsGroup([
                      _buildSwitchTile(
                        icon: Icons.notifications_outlined,
                        iconColor: const Color(0xFFDA77FF),
                        title: 'Location Notifications',
                        subtitle: 'Get notified about nearby services',
                        value: profile?.notificationsEnabled ?? false,
                        onChanged: (v) => authProvider.toggleNotifications(v),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Activity'),
                    _buildSettingsGroup([
                      _buildSettingsTile(
                        icon: Icons.bookmark_outline,
                        iconColor: const Color(0xFF6BCB77),
                        title: 'Saved Places',
                        subtitle: '${listingProvider.favouriteListings.length} saved listings',
                        onTap: () => _showSavedPlaces(context, listingProvider),
                      ),
                      _buildSettingsTile(
                        icon: Icons.history,
                        iconColor: const Color(0xFFFF8C42),
                        title: 'Recently Viewed',
                        subtitle: '${listingProvider.recentlyViewed.length} recent listings',
                        onTap: () => _showRecentlyViewed(context, listingProvider),
                      ),
                      _buildSettingsTile(
                        icon: Icons.list_alt_outlined,
                        iconColor: const Color(0xFF4ECDC4),
                        title: 'My Listings',
                        subtitle: '${listingProvider.userListings.length} listings created',
                        showArrow: false,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Support'),
                    _buildSettingsGroup([
                      _buildSettingsTile(
                        icon: Icons.help_outline,
                        iconColor: const Color(0xFF74B9FF),
                        title: 'Get Help',
                        subtitle: 'FAQs and support resources',
                        onTap: () => _showInfoDialog(context, 'Get Help',
                          'Frequently Asked Questions\n\n'
                          'How do I add a listing?\nGo to My Listings and tap "Add New". Fill in the details including coordinates which you can find by long-pressing a location in Google Maps.\n\n'
                          'How do I find coordinates?\nOpen Google Maps, long press the location you want, and the coordinates will appear at the top of the screen.\n\n'
                          'Can I edit my listings?\nYes. Go to My Listings, tap the edit icon on any of your listings and update the details.\n\n'
                          'How do I report incorrect information?\nTap the listing, leave a review mentioning the issue, or contact us at support@kigalidirectory.rw\n\n'
                          'Contact Support\nsupport@kigalidirectory.rw'),
                      ),
                      _buildSettingsTile(
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF8892B0),
                        title: 'About',
                        subtitle: 'Kigali Directory v1.0.0',
                        onTap: () => _showInfoDialog(context, 'About Kigali Directory',
                          'Kigali Directory is a community-driven platform helping residents and visitors discover essential services, businesses, and places of interest across Kigali, Rwanda.\n\n'
                          'Our mission is to make Kigali more navigable and accessible by creating an open, crowd-sourced directory that grows with the city.\n\n'
                          'Features\n'
                          '• Browse and search thousands of listings\n'
                          '• Add and manage your own listings\n'
                          '• Leave ratings and reviews\n'
                          '• Save your favourite places\n'
                          '• Get directions to any location\n\n'
                          'Version 1.0.0\n'
                          'Built with Flutter & Firebase\n'
                          'Made with ❤️ for Kigali'),
                      ),
                      _buildSettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFFDA77FF),
                        title: 'Privacy Policy',
                        subtitle: 'How we handle your data',
                        onTap: () => _showInfoDialog(context, 'Privacy Policy',
                          'Last updated: March 2026\n\n'
                          'Data We Collect\n'
                          'We collect your name, email address, username, and any listing content you voluntarily submit. We do not collect precise location data unless you explicitly provide coordinates for a listing.\n\n'
                          'How We Use Your Data\n'
                          'Your data is used solely to provide the Kigali Directory service — displaying your profile, attributing your listings, and enabling community features like reviews.\n\n'
                          'Data Storage\n'
                          'All data is stored securely on Google Firebase servers. We apply industry-standard security measures to protect your information.\n\n'
                          'Your Rights\n'
                          'You may update or delete your account and all associated data at any time from the Settings screen.\n\n'
                          'Third Parties\n'
                          'We do not sell, share, or rent your personal data to any third parties.\n\n'
                          'Contact\nprivacy@kigalidirectory.rw'),
                      ),
                      _buildSettingsTile(
                        icon: Icons.gavel_outlined,
                        iconColor: const Color(0xFFFF8C42),
                        title: 'Terms & Legal',
                        subtitle: 'Terms of service and legal info',
                        onTap: () => _showInfoDialog(context, 'Terms of Service',
                          'Last updated: March 2026\n\n'
                          'By using Kigali Directory you agree to the following:\n\n'
                          'Acceptable Use\n'
                          '• Provide accurate and truthful listing information\n'
                          '• Do not post misleading, harmful, or offensive content\n'
                          '• Do not impersonate other individuals or businesses\n'
                          '• Respect the intellectual property of others\n\n'
                          'Listings\n'
                          'You are responsible for the accuracy of listings you create. Kigali Directory reserves the right to remove listings that violate community guidelines or contain false information.\n\n'
                          'Reviews\n'
                          'Reviews must be honest and based on genuine experience. Fake reviews or review manipulation is strictly prohibited.\n\n'
                          'Account Termination\n'
                          'We reserve the right to suspend or terminate accounts that repeatedly violate these terms.\n\n'
                          'Limitation of Liability\n'
                          'Kigali Directory is provided as-is. We are not liable for any inaccuracies in user-submitted content.\n\n'
                          'Contact\nlegal@kigalidirectory.rw'),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Danger Zone'),
                    _buildSettingsGroup([
                      _buildSettingsTile(
                        icon: Icons.logout,
                        iconColor: const Color(0xFFFF6B6B),
                        title: 'Sign Out',
                        subtitle: 'Log out of your account',
                        onTap: () => _confirmSignOut(context, authProvider),
                        showArrow: false,
                      ),
                      _buildSettingsTile(
                        icon: Icons.delete_forever_outlined,
                        iconColor: const Color(0xFFFF6B6B),
                        title: 'Delete Account',
                        subtitle: 'Permanently remove your account',
                        onTap: () => _showDeleteAccountDialog(context, authProvider),
                        showArrow: false,
                        isDestructive: true,
                      ),
                    ]),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Color(0xFF8892B0), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast) const Divider(color: Color(0xFF1F2937), height: 1, indent: 60),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool showArrow = true,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? const Color(0xFFFF6B6B) : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12)),
      trailing: showArrow && onTap != null
          ? const Icon(Icons.chevron_right, color: Color(0xFF8892B0), size: 18)
          : null,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF4ECDC4),
        activeTrackColor: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
        inactiveTrackColor: const Color(0xFF1F2937),
        inactiveThumbColor: const Color(0xFF8892B0),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.userProfile?.displayName ?? '');
    final usernameController = TextEditingController(text: authProvider.userProfile?.username ?? '');
    final bioController = TextEditingController(text: authProvider.userProfile?.bio ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _dialogField(nameController, 'Display Name', Icons.person_outline),
            const SizedBox(height: 12),
            _dialogField(usernameController, 'Username', Icons.alternate_email),
            const SizedBox(height: 12),
            _dialogField(bioController, 'Bio', Icons.notes, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await authProvider.updateProfile(
                    nameController.text.trim(),
                    usernameController.text.trim(),
                    bioController.text.trim(),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated'), backgroundColor: Color(0xFF4ECDC4)),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider authProvider) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Change Password', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _dialogField(currentController, 'Current Password', Icons.lock_outline, obscure: true),
            const SizedBox(height: 12),
            _dialogField(newController, 'New Password', Icons.lock_outlined, obscure: true),
            const SizedBox(height: 12),
            _dialogField(confirmController, 'Confirm New Password', Icons.lock_outlined, obscure: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (newController.text != confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match'), backgroundColor: Color(0xFFE53935)),
                    );
                    return;
                  }
                  final success = await authProvider.changePassword(currentController.text, newController.text);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Password changed successfully' : authProvider.errorMessage ?? 'Failed'),
                        backgroundColor: success ? const Color(0xFF4ECDC4) : const Color(0xFFE53935),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B), size: 24),
            SizedBox(width: 10),
            Text('Delete Account', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.3)),
              ),
              child: const Text(
                'This will permanently delete:\n• Your account and profile\n• All listings you created\n• Your reviews and saved places\n\nThis action cannot be undone.',
                style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter your password to confirm:',
              style: TextStyle(color: Color(0xFF8892B0), fontSize: 13),
            ),
            const SizedBox(height: 8),
            _dialogField(passwordController, 'Your current password', Icons.lock_outline, obscure: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8892B0))),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your password'),
                    backgroundColor: Color(0xFFE53935),
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              _showFinalDeleteConfirmation(context, authProvider, passwordController.text);
            },
            child: const Text('Continue', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context, AuthProvider authProvider, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Are you absolutely sure?', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text(
          'You are about to permanently delete your account. There is no going back after this.',
          style: TextStyle(color: Color(0xFF8892B0), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, keep my account', style: TextStyle(color: Color(0xFF4ECDC4), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await authProvider.deleteAccount(password);
              if (success && context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authProvider.errorMessage ?? 'Incorrect password. Please try again.'),
                    backgroundColor: const Color(0xFFE53935),
                  ),
                );
              }
            },
            child: const Text('Yes, delete my account', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Color(0xFF8892B0))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF8892B0)))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.signOut();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(content, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 13, height: 1.7)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: Color(0xFF4ECDC4)))),
        ],
      ),
    );
  }

  void _showSavedPlaces(BuildContext context, ListingProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Saved Places', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: provider.favouriteListings.isEmpty
                ? const Center(child: Text('No saved places yet', style: TextStyle(color: Color(0xFF8892B0))))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.favouriteListings.length,
                    itemBuilder: (_, i) => ListTile(
                      leading: const Icon(Icons.bookmark, color: Color(0xFF4ECDC4)),
                      title: Text(provider.favouriteListings[i].name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(provider.favouriteListings[i].category, style: const TextStyle(color: Color(0xFF8892B0))),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showRecentlyViewed(BuildContext context, ListingProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Recently Viewed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: provider.recentlyViewed.isEmpty
                ? const Center(child: Text('No recently viewed listings', style: TextStyle(color: Color(0xFF8892B0))))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.recentlyViewed.length,
                    itemBuilder: (_, i) => ListTile(
                      leading: const Icon(Icons.history, color: Color(0xFFFF8C42)),
                      title: Text(provider.recentlyViewed[i].name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(provider.recentlyViewed[i].category, style: const TextStyle(color: Color(0xFF8892B0))),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String hint, IconData icon, {bool obscure = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4A5568)),
        prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
        filled: true,
        fillColor: const Color(0xFF0D0D1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1F2937))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1F2937))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4ECDC4))),
      ),
    );
  }
}