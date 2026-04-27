// lib/presentation/auth/profile_setup/step5_photos.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rishta_app/core/constants/app_colors.dart';
import 'package:rishta_app/core/constants/app_text_styles.dart';
import 'package:rishta_app/core/widgets/custom_button.dart';
import 'package:rishta_app/core/widgets/loading_overlay.dart';
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

  bool get hasPhoto => url != null && url!.isNotEmpty;

  _PhotoSlot copyWith({String? url, bool? isUploading}) {
    return _PhotoSlot(
      index: index,
      url: url ?? this.url,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 5 — PHOTOS
// ─────────────────────────────────────────────────────────

class Step5Photos extends ConsumerStatefulWidget {
  const Step5Photos({super.key});

  @override
  ConsumerState<Step5Photos> createState() => _Step5PhotosState();
}

class _Step5PhotosState extends ConsumerState<Step5Photos>
    with SingleTickerProviderStateMixin {

  // Max 6 slots in Phase 1-2 (10 in Phase 3)
  static const int _maxSlots = 6;

  late List<_PhotoSlot> _slots;

  // Animation
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _slots = List.generate(_maxSlots, (i) => _PhotoSlot(index: i));
    _setupAnimation();
    _ctrl.forward();
    _loadExistingPhotos();
  }

  void _setupAnimation() {
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  void _loadExistingPhotos() {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    final photos = profile.photoUrls;
    setState(() {
      for (int i = 0; i < photos.length && i < _maxSlots; i++) {
        _slots[i] = _PhotoSlot(index: i, url: photos[i]);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── COMPUTED ──────────────────────────────────────────

  int get _photoCount => _slots.where((s) => s.hasPhoto).length;
  bool get _hasEnoughPhotos => _photoCount >= 1;
  List<String> get _photoUrls =>
      _slots.where((s) => s.hasPhoto).map((s) => s.url!).toList();

  // ── ACTIONS ───────────────────────────────────────────

  void _onSlotTap(int index) {
    HapticFeedback.lightImpact();
    final slot = _slots[index];
    _showPhotoOptions(index, slot.hasPhoto);
  }

  void _showPhotoOptions(int index, bool hasPhoto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhotoOptionsSheet(
        index: index,
        hasPhoto: hasPhoto,
        isMainSlot: index == 0,
        onGallery: () {
          Navigator.pop(context);
          _mockAddPhoto(index, 'gallery');
        },
        onCamera: () {
          Navigator.pop(context);
          _mockAddPhoto(index, 'camera');
        },
        onSetMain: hasPhoto && index != 0
            ? () {
          Navigator.pop(context);
          _setAsMain(index);
        }
            : null,
        onDelete: hasPhoto
            ? () {
          Navigator.pop(context);
          _deletePhoto(index);
        }
            : null,
      ),
    );
  }

  // Mock photo add — Phase 3 mein image_picker use hoga
  void _mockAddPhoto(int index, String source) {
    setState(() {
      _slots[index] = _slots[index].copyWith(isUploading: true);
    });

    // Simulate upload delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      // Mock emoji URL — Phase 3: real Firebase Storage URL
      final mockEmojis = ['👩', '👩‍💼', '👩‍⚕️', '👩‍🔬', '👩‍💻', '👩‍🏫'];
      setState(() {
        _slots[index] = _PhotoSlot(
          index: index,
          url: 'mock_photo_${index}_${DateTime.now().millisecondsSinceEpoch}',
          isUploading: false,
        );
      });
      _showSnack('Photo added! ✓', AppColors.success);
    });
  }

  void _deletePhoto(int index) {
    // Can't delete main photo if it's the only one
    if (index == 0 && _photoCount == 1) {
      _showSnack('Add another photo before removing the main photo.', AppColors.error);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      // Shift remaining photos left
      final updatedSlots = List<_PhotoSlot>.from(_slots);
      updatedSlots[index] = _PhotoSlot(index: index);

      // If main photo deleted, promote next photo
      if (index == 0) {
        for (int i = 1; i < _maxSlots; i++) {
          if (updatedSlots[i].hasPhoto) {
            updatedSlots[0] = _PhotoSlot(index: 0, url: updatedSlots[i].url);
            updatedSlots[i] = _PhotoSlot(index: i);
            break;
          }
        }
      }
      _slots = updatedSlots;
    });
  }

  void _setAsMain(int index) {
    if (!_slots[index].hasPhoto) return;
    HapticFeedback.selectionClick();
    setState(() {
      final mainUrl  = _slots[0].url;
      final thisUrl  = _slots[index].url;
      _slots[0]      = _PhotoSlot(index: 0, url: thisUrl);
      _slots[index]  = _PhotoSlot(index: index, url: mainUrl);
    });
    _showSnack('Main photo updated! ✓', AppColors.success);
  }

  // ── COMPLETE ──────────────────────────────────────────

  Future<void> _complete() async {
    final data = {
      'photoUrls'  : _photoUrls,
      'mainPhotoUrl': _photoUrls.isNotEmpty ? _photoUrls.first : null,
      'setupStep'  : 5,
    };

    final ok = await ref.read(myProfileProvider.notifier).updateProfile(data);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      final error = ref.read(myProfileProvider).error;
      _showSnack(error ?? 'Something went wrong.', AppColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(myProfileProvider).isSaving;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepTitle(),
                          const SizedBox(height: 24),

                          // Photo counter bar
                          _buildPhotoCountBar(),
                          const SizedBox(height: 20),

                          // Main photo (large)
                          _buildMainSlot(),
                          const SizedBox(height: 10),

                          // 5 secondary slots — 3 column grid
                          _buildSecondaryGrid(),
                          const SizedBox(height: 24),

                          // Guidelines card
                          _buildGuidelinesCard(),
                          const SizedBox(height: 16),

                          // Dev mode note
                          _buildDevNote(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom CTA bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(isSaving),
          ),

          if (isSaving)
            const LoadingOverlay(
              message: 'Saving profile...',
              style: LoadingStyle.dots,
            ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────

  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.crimsonGradient,
      ),
      padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
      child: Column(
        children: [
          Row(children: [
            GestureDetector(
              onTap: () => context.go('/setup/step4'),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back_ios_new,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step 5 of 5',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      )),
                  const Text('Profile Photos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            // Last step — no skip, show "Later" instead
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Do it later',
                    style: TextStyle(fontSize: 12, color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(5, (i) {
        final isDone    = i < 4;
        final isCurrent = i == 4;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: (isCurrent || isDone)
                  ? Colors.white
                  : Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // ── STEP TITLE ────────────────────────────────────────

  Widget _buildStepTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📸', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 10),
        Text('Profile Photos', style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          'Profiles with photos get 10× more responses',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  // ── PHOTO COUNT BAR ───────────────────────────────────

  Widget _buildPhotoCountBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        // Dot indicators
        Row(
          children: List.generate(_maxSlots, (i) {
            final filled = i < _photoCount;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 6),
              width: filled ? 14 : 10,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: filled ? AppColors.crimson : AppColors.border,
              ),
            );
          }),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$_photoCount / $_maxSlots photos added',
            style: AppTextStyles.labelSmall.copyWith(
              color: _photoCount >= 3
                  ? AppColors.success
                  : _photoCount >= 1
                  ? AppColors.crimson
                  : AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Quality hint
        if (_photoCount >= 3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 11, color: AppColors.success),
                SizedBox(width: 4),
                Text('Great profile!',
                    style: TextStyle(fontSize: 10, color: AppColors.success,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          )
        else if (_photoCount == 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text('Min 1 required',
                style: TextStyle(fontSize: 10, color: AppColors.crimson,
                    fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }

  // ── MAIN SLOT (large) ─────────────────────────────────

  Widget _buildMainSlot() {
    final slot = _slots[0];
    return GestureDetector(
      onTap: () => _onSlotTap(0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 220,
        decoration: BoxDecoration(
          color: slot.hasPhoto ? AppColors.ivoryDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: slot.hasPhoto ? AppColors.gold : AppColors.crimson.withOpacity(0.4),
            width: slot.hasPhoto ? 2 : 1.5,
          ),
          boxShadow: slot.hasPhoto ? AppColors.goldShadow : AppColors.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Content
              if (slot.isUploading)
                const _UploadingPlaceholder()
              else if (slot.hasPhoto)
                _MockPhotoPreview(index: 0)
              else
                _MainPhotoPlaceholder(),

              // ⭐ Main badge
              if (slot.hasPhoto)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: AppColors.goldShadow,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Main Photo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),

              // Edit overlay
              if (slot.hasPhoto)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.edit_rounded, size: 15, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SECONDARY GRID (5 slots) ──────────────────────────

  Widget _buildSecondaryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: 5, // slots 1-5
      itemBuilder: (_, i) => _buildSecondarySlot(i + 1),
    );
  }

  Widget _buildSecondarySlot(int index) {
    final slot = _slots[index];
    return GestureDetector(
      onTap: () => _onSlotTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: slot.hasPhoto ? AppColors.ivoryDark : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: slot.hasPhoto ? AppColors.border : AppColors.border,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Content
              if (slot.isUploading)
                const _UploadingPlaceholder()
              else if (slot.hasPhoto)
                _MockPhotoPreview(index: index)
              else
                _SecondaryPhotoPlaceholder(number: index + 1),

              // Delete button
              if (slot.hasPhoto)
                Positioned(
                  top: 4, right: 4,
                  child: GestureDetector(
                    onTap: () => _deletePhoto(index),
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.close_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ),

              // "Set as Main" hint on long press slot
              if (slot.hasPhoto)
                Positioned(
                  bottom: 4, left: 4,
                  child: GestureDetector(
                    onTap: () => _setAsMain(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Set Main',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── GUIDELINES CARD ───────────────────────────────────

  Widget _buildGuidelinesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.shield_outlined, size: 16, color: AppColors.crimson),
            const SizedBox(width: 8),
            Text('Photo Guidelines', style: AppTextStyles.labelLarge),
          ]),
          const SizedBox(height: 12),
          ..._guidelines.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: g.$1
                        ? AppColors.successSurface
                        : AppColors.errorSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      g.$1 ? Icons.check_rounded : Icons.close_rounded,
                      size: 10,
                      color: g.$1 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(g.$2,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.inkSoft,
                        height: 1.4,
                      )),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  static const List<(bool, String)> _guidelines = [
    (true,  'Clear face photo — you should be clearly visible'),
    (true,  'Recent photo — taken in the last 2 years'),
    (true,  'Good lighting and decent background'),
    (true,  'Formal or casual — be yourself'),
    (false, 'No group photos — solo photos only'),
    (false, 'No sunglasses or face coverings'),
    (false, 'No explicit or inappropriate content'),
  ];

  // ── DEV NOTE ─────────────────────────────────────────

  Widget _buildDevNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.code_rounded, size: 15, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Dev Mode: Tap any slot to add a mock photo. Real photo upload (Gallery/Camera) will be enabled in Phase 3.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────────

  Widget _buildBottomBar(bool isSaving) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main CTA
          PrimaryButton(
            label: isSaving
                ? 'Setting up...'
                : _photoCount >= 1
                ? 'Complete Profile 🎉'
                : 'Skip & Complete',
            isLoading: isSaving,
            onPressed: isSaving ? null : _complete,
          ),

          // Skip note
          if (_photoCount == 0 && !isSaving) ...[
            const SizedBox(height: 8),
            Text(
              'You can add photos later from your profile',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PHOTO OPTIONS BOTTOM SHEET
// ─────────────────────────────────────────────────────────

class _PhotoOptionsSheet extends StatelessWidget {
  final int index;
  final bool hasPhoto;
  final bool isMainSlot;
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback? onSetMain;
  final VoidCallback? onDelete;

  const _PhotoOptionsSheet({
    required this.index,
    required this.hasPhoto,
    required this.isMainSlot,
    required this.onGallery,
    required this.onCamera,
    this.onSetMain,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad + 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Row(children: [
            Text(
              hasPhoto ? 'Photo Options' : 'Add Photo',
              style: AppTextStyles.h4,
            ),
            if (isMainSlot) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldSurface,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 11, color: AppColors.gold),
                    SizedBox(width: 4),
                    Text('Main Photo',
                        style: TextStyle(fontSize: 10, color: AppColors.gold,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),

          // Options
          _SheetOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            subtitle: 'JPG, PNG • Max 5MB',
            onTap: onGallery,
          ),
          _SheetOption(
            icon: Icons.camera_alt_outlined,
            label: 'Take a Photo',
            subtitle: 'Use camera',
            onTap: onCamera,
          ),

          if (onSetMain != null) ...[
            const Divider(height: 1, color: AppColors.border),
            _SheetOption(
              icon: Icons.star_rounded,
              label: 'Set as Main Photo',
              subtitle: 'This will be your display photo',
              iconColor: AppColors.gold,
              onTap: onSetMain!,
            ),
          ],

          if (onDelete != null) ...[
            const Divider(height: 1, color: AppColors.border),
            _SheetOption(
              icon: Icons.delete_outline_rounded,
              label: 'Remove Photo',
              subtitle: 'This photo will be deleted',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: onDelete!,
            ),
          ],
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor = AppColors.crimson,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 20, color: iconColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: textColor ?? AppColors.ink,
                    )),
                if (subtitle != null)
                  Text(subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.muted,
                      )),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.muted),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PLACEHOLDER WIDGETS
// ─────────────────────────────────────────────────────────

class _MainPhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ivoryDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.add_photo_alternate_outlined,
                  size: 28, color: AppColors.crimson),
            ),
          ),
          const SizedBox(height: 12),
          Text('Add Main Photo',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.crimson)),
          const SizedBox(height: 4),
          Text('Tap to upload your best photo',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _SecondaryPhotoPlaceholder extends StatelessWidget {
  final int number;
  const _SecondaryPhotoPlaceholder({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ivoryDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_rounded, size: 26, color: AppColors.muted),
          const SizedBox(height: 4),
          Text('Photo $number',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

// Mock photo preview — Phase 3 mein CachedNetworkImage hoga
class _MockPhotoPreview extends StatelessWidget {
  final int index;
  const _MockPhotoPreview({required this.index});

  static const _emojis = ['👩', '👩‍💼', '👩‍⚕️', '👩‍🔬', '👩‍💻', '👩‍🏫'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.crimsonSurface,
      child: Center(
        child: Text(
          _emojis[index % _emojis.length],
          style: TextStyle(fontSize: index == 0 ? 72 : 40),
        ),
      ),
    );
  }
}

class _UploadingPlaceholder extends StatelessWidget {
  const _UploadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ivoryDark,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28, height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.crimson,
            ),
          ),
          SizedBox(height: 10),
          Text('Uploading...',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}