import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, auth)),
              SliverToBoxAdapter(child: _buildStats(context)),
              SliverToBoxAdapter(child: _buildMenuSection(context, auth)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFF9A3C)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)],
                ),
                child: Center(
                  child: Text(
                    auth.isLoggedIn ? auth.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.isLoggedIn ? auth.displayName : 'Guest User',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.isLoggedIn ? (auth.email ?? '') : 'Sign in to your account',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                    ),
                    if (!auth.isLoggedIn)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () => context.push('/login'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Sign In →',
                              style: TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _StatItem(value: '${cart.totalItems}', label: 'Cart', icon: Icons.shopping_bag_outlined),
          _buildDivider(),
          _StatItem(value: '${wishlist.items.length}', label: 'Wishlist', icon: Icons.favorite_outline),
          _buildDivider(),
          const _StatItem(value: '0', label: 'Orders', icon: Icons.receipt_outlined),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 40, color: const Color(0xFFF0F0F0));

  Widget _buildMenuSection(BuildContext context, AuthProvider auth) {
    final items = [
      _MenuItem(
        icon: Icons.person_outline_rounded,
        label: 'Edit Profile',
        subtitle: 'Update your information',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.receipt_long_outlined,
        label: 'My Orders',
        subtitle: 'Track your purchases',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.location_on_outlined,
        label: 'Shipping Address',
        subtitle: 'Manage delivery addresses',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.payment_outlined,
        label: 'Payment Methods',
        subtitle: 'Cards & wallets',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        subtitle: 'Manage your preferences',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.help_outline_rounded,
        label: 'Help & Support',
        subtitle: 'FAQs and contact us',
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                ...items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.icon, color: const Color(0xFFFF6B6B), size: 20),
                        ),
                        title: Text(
                          item.label,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                        ),
                        subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
                        onTap: item.onTap,
                      ),
                      if (i < items.length - 1)
                        const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 66),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (auth.isLoggedIn)
            GestureDetector(
              onTap: () {
                auth.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Signed out successfully'),
                    backgroundColor: const Color(0xFF333333),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF6B6B), size: 24),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.subtitle, required this.onTap});
}
