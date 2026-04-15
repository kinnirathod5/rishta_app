// lib/presentation/auth/profile_setup/step5_photos.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/core/widgets/loading_overlay.dart';
import 'package:rishta_app/providers/auth_provider.dart';
import 'package:rishta_app/providers/profile_provider.dart';

// ─────────────────────────────────────────────────────────
// PHOTO SLOT MODEL
// ─────────────────────────────────────────────────────────

class _PhotoSlot {
  final int index;
  final String? url;
  final bool isUploading;

  const _PhotoSlot({
    required this.index,
    this.url,
    this.isUploading = false,
  });

  bool get hasPhoto =>
      url != null && url!.isNotEmpty;

  _PhotoSlot copyWith({
    String? url,
    bool? isUploading,
  }) {
    return _PhotoSlot(
      index: index,
      url: url ?? this.url,
      isUploading:
      isUploading ?? this.isUploading,
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 5 — PHOTOS
// ─────────────────────────────────────────────────────────

class Step5Photos extends ConsumerStatefulWidget {
  const Step5Photos({super.key});

  @override
  ConsumerState<Step5Photos> createState() =>
      _Step5PhotosState();
}

class _Step5PhotosState
    extends ConsumerState<Step5Photos>
    with SingleTickerProviderStateMixin {

  // 6 photo slots
  late List<_PhotoSlot> _slots;

  // Entry animation
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _slots = List.generate(
      6,
          (i) => _PhotoSlot(index: i),
    );
    _setupAnimation();
    _ctrl.forward();
    _loadExistingPhotos();
  }

  void _setupAnimation() {
    _ctrl = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOut));
  }

  void _loadExistingPhotos() {
    final profile =
    ref.read(currentProfileProvider);
    if (profile == null) return;

    final photos = profile.photoUrls;
    setState(() {
      for (int i = 0;
      i < photos.length && i < 6;
      i++) {
        _slots[i] = _PhotoSlot(
          index: i,
          url: photos[i],
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── COMPUTED ──────────────────────────────────────────

  int get _photoCount =>
      _slots.where((s) => s.hasPhoto).length;

  bool get _hasEnoughPhotos => _photoCount >= 1;

  List<String> get _photoUrls =>
      _slots
          .where((s) => s.hasPhoto)
          .map((s) => s.url!)
          .toList();

  double get _profileScore {
    final profile =
    ref.read(currentProfileProvider);
    if (profile == null) return 0;
    return profile.profileScore.toDouble();
  }

  // ── PHOTO ACTIONS ─────────────────────────────────────

  void _onSlotTap(int index) {
    final slot = _slots[index];
    if (slot.hasPhoto) {
      _showPhotoOptions(index);
    } else {
      _showAddPhotoSheet(index);
    }
  }

  void _showAddPhotoSheet(int index) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => _AddPhotoSheet(
        onGallery: () {
          Navigator.pop(context);
          _mockUploadPhoto(index);
        },
        onCamera: () {
          Navigator.pop(context);
          _mockUploadPhoto(index);
        },
      ),
    );
  }

  void _showPhotoOptions(int index) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => _PhotoOptionsSheet(
        isMain: index == 0,
        onSetMain: index != 0
            ? () {
          Navigator.pop(context);
          _setMainPhoto(index);
        }
            : null,
        onReplace: () {
          Navigator.pop(context);
          _mockUploadPhoto(index);
        },
        onDelete: () {
          Navigator.pop(context);
          _deletePhoto(index);
        },
      ),
    );
  }

  // Mock photo upload — Phase 3: image_picker
  Future<void> _mockUploadPhoto(
      int index) async {
    // Set uploading state
    setState(() {
      _slots[index] =
          _slots[index].copyWith(
              isUploading: true);
    });

    // Simulate upload delay
    await Future.delayed(
        const Duration(milliseconds: 1200));

    if (!mounted) return;

    // Mock URL — Phase 3: real upload URL
    const mockEmojis = [
      '👩', '👨', '👩‍💼', '👨‍💼',
      '👩‍🎓', '👨‍🎓',
    ];
    final mockUrl =
        'mock://photo_${index}_'
        '${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _slots[index] = _PhotoSlot(
        index: index,
        url: mockUrl,
        isUploading: false,
      );
    });
  }

  void _setMainPhoto(int index) {
    if (!_slots[index].hasPhoto) return;
    setState(() {
      final current = _slots[0];
      final selected = _slots[index];
      _slots[0] = _PhotoSlot(
          index: 0, url: selected.url);
      _slots[index] = _PhotoSlot(
          index: index, url: current.url);
    });
  }

  void _deletePhoto(int index) {
    setState(() {
      // Shift remaining photos left
      for (int i = index; i < 5; i++) {
        _slots[i] = _PhotoSlot(
          index: i,
          url: _slots[i + 1].url,
        );
      }
      _slots[5] = _PhotoSlot(index: 5);
    });
  }

  // ── COMPLETE PROFILE ──────────────────────────────────

  Future<void> _complete() async {
    final profileId =
        ref.read(currentProfileProvider)?.id;
    final uid = ref.read(currentUidProvider);

    if (profileId == null || uid == null) {
      _showError(
          'Profile not found. Please go back.');
      return;
    }

    final data = {
      'photoUrls': _photoUrls,
      if (_photoUrls.isNotEmpty)
        'mainPhotoUrl': _photoUrls.first,
    };

    bool ok;
    if (_photoUrls.isNotEmpty) {
      ok = await ref
          .read(myProfileProvider.notifier)
          .updateProfile(data);
    } else {
      // Skip photos — mark setup complete
      ok = true;
    }

    if (!mounted) return;

    if (ok) {
      // Mark profile setup complete
      ref
          .read(authProvider.notifier)
          .markSetupComplete(profileId);
      context.go('/home');
    } else {
      final error =
          ref.read(myProfileProvider).error;
      _showError(
          error ?? 'Something went wrong.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving =
        ref.watch(myProfileProvider).isSaving;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProgressBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                        const EdgeInsets
                            .fromLTRB(
                            24, 24,
                            24, 100),
                        physics:
                        const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            _buildStepTitle(),
                            const SizedBox(
                                height: 24),
                            _buildPhotoGrid(),
                            const SizedBox(
                                height: 20),
                            _buildPhotoCount(),
                            const SizedBox(
                                height: 24),
                            _buildTipsCard(),
                            const SizedBox(
                                height: 20),
                            _buildGuidelinesCard(),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomBar(isSaving),
                  ],
                ),
              ),
            ),
          ),
          if (isSaving)
            const LoadingOverlay(
              message: 'Setting up profile...',
              style: LoadingStyle.logo,
            ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.crimson,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () =>
              context.go('/setup/step4'),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Step 5 of 5 — Last Step! 🎉',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white
                      .withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Profile Photos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _complete,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(100),
            ),
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white
                    .withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── PROGRESS BAR ──────────────────────────────────────

  Widget _buildProgressBar() {
    return Container(
      color: AppColors.crimson,
      padding: const EdgeInsets.fromLTRB(
          16, 0, 16, 12),
      child: Row(
        children: List.generate(5, (i) {
          final isDone = i < 4;
          final isCurrent = i == 4;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  right: i < 4 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.white
                    : isCurrent
                    ? Colors.white
                    .withOpacity(0.9)
                    : Colors.white
                    .withOpacity(0.25),
                borderRadius:
                BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── STEP TITLE ────────────────────────────────────────

  Widget _buildStepTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📸',
            style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text('Profile Photos',
            style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          'Profiles with photos get '
              '10x more responses',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  // ── PHOTO GRID ────────────────────────────────────────

  Widget _buildPhotoGrid() {
    return Column(
      children: [
        // Main photo — full width
        _buildMainSlot(),
        const SizedBox(height: 10),
        // 5 smaller photos — 3+2 grid
        GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: 5,
          itemBuilder: (_, i) =>
              _buildPhotoSlot(i + 1),
        ),
      ],
    );
  }

  Widget _buildMainSlot() {
    final slot = _slots[0];
    return GestureDetector(
      onTap: () => _onSlotTap(0),
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 200),
        height: 200,
        decoration: BoxDecoration(
          color: slot.hasPhoto
              ? AppColors.ivoryDark
              : AppColors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: slot.hasPhoto
                ? AppColors.gold
                : AppColors.border,
            width: slot.hasPhoto ? 2 : 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo or placeholder
              if (slot.isUploading)
                const _UploadingPlaceholder()
              else if (slot.hasPhoto)
                _PhotoPreview(url: slot.url!)
              else
                _MainPhotoPlaceholder(),

              // Main badge
              if (slot.hasPhoto)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                        horizontal: 10,
                        vertical: 4),
                    decoration: BoxDecoration(
                      gradient:
                      AppColors.goldGradient,
                      borderRadius:
                      BorderRadius.circular(
                          100),
                    ),
                    child: const Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Main Photo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                            FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Edit overlay on existing photo
              if (slot.hasPhoto)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.ink
                          .withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(int index) {
    final slot = _slots[index];
    return GestureDetector(
      onTap: () => _onSlotTap(index),
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: slot.hasPhoto
              ? AppColors.ivoryDark
              : AppColors.white,
          borderRadius:
          BorderRadius.circular(12),
          border: Border.all(
            color: slot.hasPhoto
                ? AppColors.border
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (slot.isUploading)
                const _UploadingPlaceholder()
              else if (slot.hasPhoto)
                _PhotoPreview(url: slot.url!)
              else
                _SmallPhotoPlaceholder(
                    index: index),

              // Delete button
              if (slot.hasPhoto)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () =>
                        _deletePhoto(index),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PHOTO COUNT ───────────────────────────────────────

  Widget _buildPhotoCount() {
    return Row(
      children: [
        // Count bubbles
        ...List.generate(6, (i) {
          final filled = i < _photoCount;
          return Container(
            margin:
            const EdgeInsets.only(right: 6),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled
                  ? AppColors.crimson
                  : AppColors.border,
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '$_photoCount / 6 photos added',
          style: AppTextStyles.labelSmall
              .copyWith(
            color: _photoCount >= 3
                ? AppColors.success
                : AppColors.muted,
          ),
        ),
        if (_photoCount >= 3) ...[
          const SizedBox(width: 6),
          const Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: AppColors.success,
          ),
        ],
      ],
    );
  }

  // ── TIPS CARD ─────────────────────────────────────────

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(
              Icons.tips_and_updates_rounded,
              size: 16,
              color: AppColors.gold,
            ),
            const SizedBox(width: 8),
            Text(
              'Photo Tips for More Matches',
              style: AppTextStyles.labelMedium
                  .copyWith(
                  color: AppColors.gold),
            ),
          ]),
          const SizedBox(height: 12),
          ..._tips.map((tip) => Padding(
            padding: const EdgeInsets.only(
                bottom: 8),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin:
                  const EdgeInsets.only(
                      right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gold
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      tip['emoji']!,
                      style: const TextStyle(
                          fontSize: 11),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    tip['text']!,
                    style: AppTextStyles
                        .bodySmall
                        .copyWith(
                        color: AppColors
                            .inkSoft),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  static const List<Map<String, String>>
  _tips = [
    {
      'emoji': '😊',
      'text': 'Use a clear, smiling face photo '
          'as your main photo',
    },
    {
      'emoji': '☀️',
      'text': 'Good lighting makes a big '
          'difference — prefer natural light',
    },
    {
      'emoji': '👔',
      'text': 'Add a formal photo and casual '
          'photo both',
    },
    {
      'emoji': '🚫',
      'text': 'Avoid sunglasses, group photos '
          'or blurry images',
    },
  ];

  // ── GUIDELINES CARD ───────────────────────────────────

  Widget _buildGuidelinesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 15,
              color: AppColors.info,
            ),
            const SizedBox(width: 8),
            Text(
              'Photo Guidelines',
              style: AppTextStyles.labelMedium
                  .copyWith(
                  color: AppColors.info),
            ),
          ]),
          const SizedBox(height: 10),
          Text(
            '• Photos are reviewed by our safety team\n'
                '• Face must be clearly visible\n'
                '• No inappropriate or offensive content\n'
                '• Only real, recent photos of yourself',
            style: AppTextStyles.bodySmall
                .copyWith(
                color: AppColors.inkSoft,
                height: 1.7),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────────

  Widget _buildBottomBar(bool isSaving) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 12, 24,
        MediaQuery.of(context).padding.bottom +
            16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
              color: AppColors.border,
              width: 1),
        ),
        boxShadow: AppColors.modalShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress dots
          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final isDone = i < 4;
              final isCurrent = i == 4;
              return Container(
                margin: EdgeInsets.only(
                    right: i < 4 ? 8 : 0),
                width: isCurrent ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (isDone || isCurrent)
                      ? AppColors.crimson
                      : AppColors.border,
                  borderRadius:
                  BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          // Complete button
          GradientButton(
            label: isSaving
                ? 'Setting up...'
                : _photoCount >= 1
                ? 'Complete Profile 🎉'
                : 'Skip & Complete',
            isLoading: isSaving,
            onPressed: isSaving ? null : _complete,
          ),
          if (_photoCount == 0) ...[
            const SizedBox(height: 8),
            Text(
              'You can add photos later '
                  'from your profile',
              style: AppTextStyles.bodySmall
                  .copyWith(
                  color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────

class _MainPhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ivoryDark,
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: 28,
                color: AppColors.crimson,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add Main Photo',
            style: AppTextStyles.labelMedium
                .copyWith(
                color: AppColors.crimson),
          ),
          const SizedBox(height: 4),
          Text(
            'This is your primary photo',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SmallPhotoPlaceholder
    extends StatelessWidget {
  final int index;
  const _SmallPhotoPlaceholder(
      {required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ivoryDark,
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_rounded,
            size: 28,
            color: AppColors.muted,
          ),
          const SizedBox(height: 4),
          Text(
            'Photo ${index + 1}',
            style: AppTextStyles.labelSmall
                .copyWith(
                color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String url;
  const _PhotoPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    // Mock preview — shows emoji placeholder
    // Phase 3: CachedNetworkImage
    final index = url.contains('photo_')
        ? int.tryParse(
        url.split('photo_')[1].split('_')[0]) ??
        0
        : 0;
    const emojis = ['👩', '👨', '👩‍💼', '👨‍💼', '👩‍🎓', '👨‍🎓'];
    return Container(
      color: AppColors.crimsonSurface,
      child: Center(
        child: Text(
          emojis[index % emojis.length],
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}

class _UploadingPlaceholder extends StatefulWidget {
  const _UploadingPlaceholder();

  @override
  State<_UploadingPlaceholder> createState() =>
      _UploadingPlaceholderState();
}

class _UploadingPlaceholderState
    extends State<_UploadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(
        begin: 0.4, end: 0.9)
        .animate(CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        color: AppColors.ivoryDark
            .withOpacity(_anim.value),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.crimson,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BOTTOM SHEETS
// ─────────────────────────────────────────────────────────

class _AddPhotoSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _AddPhotoSheet({
    required this.onGallery,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(),
          const SizedBox(height: 4),
          Text('Add Photo',
              style: AppTextStyles.h4),
          const SizedBox(height: 20),
          _SheetOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            onTap: onGallery,
          ),
          _SheetOption(
            icon: Icons.camera_alt_outlined,
            label: 'Take a Photo',
            onTap: onCamera,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: Text('Cancel',
                  style: AppTextStyles
                      .labelMedium
                      .copyWith(
                      color:
                      AppColors.muted)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoOptionsSheet extends StatelessWidget {
  final bool isMain;
  final VoidCallback? onSetMain;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  const _PhotoOptionsSheet({
    required this.isMain,
    this.onSetMain,
    required this.onReplace,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(),
          const SizedBox(height: 4),
          Text('Photo Options',
              style: AppTextStyles.h4),
          const SizedBox(height: 20),
          if (!isMain && onSetMain != null)
            _SheetOption(
              icon: Icons.star_outline_rounded,
              label: 'Set as Main Photo',
              onTap: onSetMain!,
            ),
          _SheetOption(
            icon: Icons.swap_horiz_rounded,
            label: 'Replace Photo',
            onTap: onReplace,
          ),
          _SheetOption(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Photo',
            onTap: onDelete,
            isDestructive: true,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: Text('Cancel',
                  style: AppTextStyles
                      .labelMedium
                      .copyWith(
                      color:
                      AppColors.muted)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin:
        const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.ivoryDark,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : AppColors.inkSoft;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: AppColors.border,
                width: 0.5),
          ),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.errorSurface
                  : AppColors.ivoryDark,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon,
                  size: 18, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              )),
        ]),
      ),
    );
  }
}