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
                        onTap: () => _showInfoDialog(context, 'Get Help', 'For support, contact us at support@kigalidirectory.rw or visit our help center at help.kigalidirectory.rw'),
                      ),
                      _buildSettingsTile(
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF8892B0),
                        title: 'About',
                        subtitle: 'Kigali Directory v1.0.0',
                        onTap: () => _showInfoDialog(context, 'About Kigali Directory', 'Kigali Directory is a community-driven platform helping residents and visitors find essential services and places across Kigali, Rwanda.\n\nVersion 1.0.0\nBuilt with Flutter & Firebase'),
                      ),
                      _buildSettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFFDA77FF),
                        title: 'Privacy Policy',
                        subtitle: 'How we handle your data',
                        onTap: () => _showInfoDialog(context, 'Privacy Policy', 'We collect only the information necessary to provide our services. Your data is stored securely on Firebase and is never sold to third parties. You can delete your account at any time.'),
                      ),
                      _buildSettingsTile(
                        icon: Icons.gavel_outlined,
                        iconColor: const Color(0xFFFF8C42),
                        title: 'Terms & Legal',
                        subtitle: 'Terms of service and legal info',
                        onTap: () => _showInfoDialog(context, 'Terms of Service', 'By using Kigali Directory, you agree to provide accurate listing information, respect other users, and not post misleading or harmful content. Listings may be removed for violating community guidelines.'),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 10),
            Text('Delete Account', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will permanently delete your account and all your listings. This cannot be undone.',
              style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
            ),
            const SizedBox(height: 16),
            _dialogField(passwordController, 'Enter password to confirm', Icons.lock_outline, obscure: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8892B0))),
          ),
          TextButton(
            onPressed: () async {
              final success = await authProvider.deleteAccount(passwordController.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (success && context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
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
        content: Text(content, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14, height: 1.6)),
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