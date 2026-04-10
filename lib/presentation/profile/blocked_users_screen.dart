import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class MockBlockedUser {
  final String id;
  final String name;
  final String emoji;
  final String caste;
  final String city;
  final String blockedAgo;

  const MockBlockedUser({
    required this.id,
    required this.name,
    required this.emoji,
    required this.caste,
    required this.city,
    required this.blockedAgo,
  });
}

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() =>
      _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<MockBlockedUser> _blockedUsers = [
    const MockBlockedUser(
      id: 'b1',
      name: 'Rahul Sharma',
      emoji: '👨‍💻',
      caste: 'Brahmin',
      city: 'Delhi',
      blockedAgo: '2 din pehle',
    ),
    const MockBlockedUser(
      id: 'b2',
      name: 'Amit Gupta',
      emoji: '👨‍💼',
      caste: 'Kayastha',
      city: 'Mumbai',
      blockedAgo: '1 hafte pehle',
    ),
    const MockBlockedUser(
      id: 'b3',
      name: 'Vikram Singh',
      emoji: '👨‍🎓',
      caste: 'Rajput',
      city: 'Jaipur',
      blockedAgo: '2 hafte pehle',
    ),
  ];

  void _showUnblockDialog(MockBlockedUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text("${user.name} ko Unblock Karein?"),
        content: Text(
          "${user.name} aapki profile dekh sakenge aur interest bhej sakte hain.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.crimson,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _blockedUsers
                  .removeWhere((u) => u.id == user.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                  Text("${user.name} unblock ho gaye ✓"),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Unblock Karo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.ivoryDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Blocked Users",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          "${_blockedUsers.length} users blocked",
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  if (_blockedUsers.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.errorSurface,
                        borderRadius:
                        BorderRadius.circular(100),
                        border: Border.all(
                            color: AppColors.error
                                .withOpacity(0.25)),
                      ),
                      child: Text(
                        "${_blockedUsers.length} Blocked",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── INFO BANNER ─────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Blocked users aapki profile nahi dekh sakte aur na hi contact kar sakte hain",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── LIST ────────────────────────────────
            Expanded(
              child: _blockedUsers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Text('🚫',
                        style:
                        TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    const Text(
                      "Koi Blocked User Nahi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Aapne abhi kisi ko block\nnahi kiya hai",
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.muted,
                          height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 16),
                itemCount: _blockedUsers.length,
                itemBuilder: (context, index) {
                  final user = _blockedUsers[index];
                  return Container(
                    margin:
                    const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.border),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration:
                                BoxDecoration(
                                  color: AppColors
                                      .ivoryDark,
                                  borderRadius:
                                  BorderRadius
                                      .circular(14),
                                ),
                                child: Center(
                                  child: ColorFiltered(
                                    colorFilter:
                                    const ColorFilter
                                        .matrix([
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0, 0, 0, 1, 0,
                                    ]),
                                    child: Text(
                                      user.emoji,
                                      style:
                                      const TextStyle(
                                          fontSize:
                                          26),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    AppColors.error,
                                    shape:
                                    BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors
                                            .white,
                                        width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.block_rounded,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${user.caste} • ${user.city}",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color:
                                      AppColors.muted),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .access_time_rounded,
                                      size: 12,
                                      color:
                                      AppColors.muted,
                                    ),
                                    const SizedBox(
                                        width: 4),
                                    Text(
                                      "Blocked ${user.blockedAgo}",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors
                                              .muted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Unblock button
                          GestureDetector(
                            onTap: () =>
                                _showUnblockDialog(user),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                AppColors.crimsonSurface,
                                borderRadius:
                                BorderRadius.circular(
                                    8),
                                border: Border.all(
                                    color: AppColors.crimson
                                        .withOpacity(0.25)),
                              ),
                              child: const Text(
                                "Unblock",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w700,
                                  color: AppColors.crimson,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}