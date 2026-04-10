import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';

class IdVerificationScreen extends StatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  State<IdVerificationScreen> createState() =>
      _IdVerificationScreenState();
}

class _IdVerificationScreenState
    extends State<IdVerificationScreen> {
  // ── STATE ──────────────────────────────────────────
  String _selectedDocType = '';
  File? _frontImage;
  File? _backImage;
  File? _selfieImage;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  // ── DOC TYPES ──────────────────────────────────────
  final List<Map<String, dynamic>> _docTypes = [
    {
      'id': 'aadhar',
      'label': 'Aadhar Card',
      'emoji': '🪪',
      'desc': 'Most popular • Instant verify',
      'hasBothSides': true,
    },
    {
      'id': 'pan',
      'label': 'PAN Card',
      'emoji': '💳',
      'desc': 'Income tax document',
      'hasBothSides': false,
    },
    {
      'id': 'passport',
      'label': 'Passport',
      'emoji': '📘',
      'desc': 'International travel document',
      'hasBothSides': true,
    },
    {
      'id': 'driving',
      'label': 'Driving License',
      'emoji': '🚗',
      'desc': 'Motor vehicle document',
      'hasBothSides': true,
    },
    {
      'id': 'voter',
      'label': 'Voter ID',
      'emoji': '🗳️',
      'desc': 'Election commission issued',
      'hasBothSides': true,
    },
  ];

  bool get _hasBothSides {
    final doc = _docTypes.firstWhere(
          (d) => d['id'] == _selectedDocType,
      orElse: () => {'hasBothSides': false},
    );
    return doc['hasBothSides'] as bool;
  }

  bool get _canSubmit {
    if (_selectedDocType.isEmpty) return false;
    if (_frontImage == null) return false;
    if (_hasBothSides && _backImage == null) return false;
    if (_selfieImage == null) return false;
    return true;
  }

  // ── IMAGE PICKER ───────────────────────────────────
  Future<void> _pickImage(
      ImageSource source,
      String type,
      ) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (img != null) {
      setState(() {
        final file = File(img.path);
        if (type == 'front') _frontImage = file;
        if (type == 'back') _backImage = file;
        if (type == 'selfie') _selfieImage = file;
      });
    }
  }

  void _showImageOptions(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.ivoryDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              type == 'selfie'
                  ? "Selfie Kaise Lein?"
                  : "Document Photo Kahan Se?",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  '📷',
                  'Camera',
                  AppColors.infoSurface,
                      () async {
                    Navigator.pop(context);
                    await _pickImage(
                        ImageSource.camera, type);
                  },
                ),
                _buildSourceOption(
                  '🖼️',
                  'Gallery',
                  AppColors.successSurface,
                      () async {
                    Navigator.pop(context);
                    await _pickImage(
                        ImageSource.gallery, type);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(
      String emoji,
      String label,
      Color bgColor,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(emoji,
                  style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  // ── SUBMIT ─────────────────────────────────────────
  Future<void> _submitVerification() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });
  }

  // ── BUILD ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isSubmitted
                  ? _buildSuccessState()
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildBenefitsBanner(),
                    const SizedBox(height: 20),
                    _buildDocTypeSection(),
                    const SizedBox(height: 20),
                    if (_selectedDocType.isNotEmpty) ...[
                      _buildUploadSection(),
                      const SizedBox(height: 20),
                      _buildSelfieSection(),
                      const SizedBox(height: 20),
                      _buildGuidelinesSection(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
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
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ID Verification",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  "Verified badge pao",
                  style: TextStyle(
                      fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          // Verified badge preview
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded,
                    size: 14, color: AppColors.success),
                SizedBox(width: 5),
                Text(
                  'Verified Badge',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BENEFITS BANNER ────────────────────────────────
  Widget _buildBenefitsBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D5C2F), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_rounded,
                  size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Verified Badge Ke Fayde",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBenefitChip('🔝 Profile top pe dikhti'),
              const SizedBox(width: 8),
              _buildBenefitChip('💌 3x zyada interests'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildBenefitChip('✓ Trust badh jaata hai'),
              const SizedBox(width: 8),
              _buildBenefitChip('🛡️ Safe & Secure'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── DOC TYPE SECTION ───────────────────────────────
  Widget _buildDocTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.badge_outlined,
                size: 18, color: AppColors.crimson),
            SizedBox(width: 8),
            Text(
              "Document Chunein",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '*',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Kaunsa government ID use karna chahte ho?",
          style:
          TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        Column(
          children: _docTypes.map((doc) {
            final isSelected = _selectedDocType == doc['id'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDocType = doc['id'] as String;
                  _frontImage = null;
                  _backImage = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.crimsonSurface
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.crimson
                        : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow:
                  isSelected ? AppColors.cardShadow : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.crimson
                            .withOpacity(0.1)
                            : AppColors.ivoryDark,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          doc['emoji'] as String,
                          style:
                          const TextStyle(fontSize: 22),
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
                            doc['label'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.crimson
                                  : AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doc['desc'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Radio indicator
                    AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.crimson
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.crimson,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── UPLOAD SECTION ─────────────────────────────────
  Widget _buildUploadSection() {
    final selectedDoc = _docTypes.firstWhere(
          (d) => d['id'] == _selectedDocType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.upload_file_rounded,
                size: 18, color: AppColors.crimson),
            const SizedBox(width: 8),
            Text(
              "${selectedDoc['label']} Upload Karein",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Front side
        _buildUploadSlot(
          label: _hasBothSides ? "Aage ki Side (Front)" : "Document Photo",
          sublabel: "Front side clearly dikhni chahiye",
          file: _frontImage,
          onTap: () => _showImageOptions('front'),
          onDelete: () => setState(() => _frontImage = null),
        ),

        // Back side (only if needed)
        if (_hasBothSides) ...[
          const SizedBox(height: 12),
          _buildUploadSlot(
            label: "Peeche ki Side (Back)",
            sublabel: "Back side clearly dikhni chahiye",
            file: _backImage,
            onTap: () => _showImageOptions('back'),
            onDelete: () => setState(() => _backImage = null),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadSlot({
    required String label,
    required String sublabel,
    required File? file,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: file != null
              ? AppColors.success.withOpacity(0.4)
              : AppColors.border,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(
                  file != null
                      ? Icons.check_circle_rounded
                      : Icons.image_outlined,
                  size: 16,
                  color: file != null
                      ? AppColors.success
                      : AppColors.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: file != null
                        ? AppColors.success
                        : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),

          // Upload area
          GestureDetector(
            onTap: file == null ? onTap : null,
            child: Container(
              height: 140,
              margin:
              const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: BoxDecoration(
                color: file != null
                    ? Colors.transparent
                    : AppColors.ivory,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: file != null
                      ? Colors.transparent
                      : AppColors.crimson.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: file != null
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(10),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.crimsonSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 22,
                      color: AppColors.crimson,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap karke photo lein",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.crimson,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SELFIE SECTION ─────────────────────────────────
  Widget _buildSelfieSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.face_rounded,
                size: 18, color: AppColors.crimson),
            SizedBox(width: 8),
            Text(
              "Selfie Lein",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '*',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Document ke saath selfie lein",
          style:
          TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _selfieImage != null
                  ? AppColors.success.withOpacity(0.4)
                  : AppColors.border,
            ),
            boxShadow: AppColors.softShadow,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Selfie instructions
              if (_selfieImage == null)
                Container(
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
                          "Document haath mein pakad ke selfie lein — chehra aur document dono clearly dikhne chahiye",
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

              if (_selfieImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selfieImage!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => setState(
                                () => _selfieImage = null),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius:
                          BorderRadius.circular(100),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              "Selfie ready",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // Camera button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => _showImageOptions('selfie'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.crimson, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          size: 18, color: AppColors.crimson),
                      const SizedBox(width: 8),
                      Text(
                        _selfieImage != null
                            ? "Selfie Dobara Lein"
                            : "Selfie Lein",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.crimson,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── GUIDELINES ─────────────────────────────────────
  Widget _buildGuidelinesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.rule_rounded,
                  size: 16, color: AppColors.crimson),
              SizedBox(width: 8),
              Text(
                "Photo Guidelines",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideline(
              true, 'Document clearly visible hona chahiye'),
          _buildGuideline(true, 'Sab text readable ho'),
          _buildGuideline(true, 'Achhi lighting mein photo lein'),
          _buildGuideline(true, 'Original document use karein'),
          _buildGuideline(false, 'Blurry ya dark photo mat lein'),
          _buildGuideline(false, 'Photocopy ya scan use mat karein'),
          _buildGuideline(false, 'Edited photos allowed nahi hain'),
        ],
      ),
    );
  }

  Widget _buildGuideline(bool isGood, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: isGood
                  ? AppColors.successSurface
                  : AppColors.errorSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isGood ? Icons.check_rounded : Icons.close_rounded,
                size: 10,
                color:
                isGood ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.inkSoft,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SUBMIT BUTTON ──────────────────────────────────
  Widget _buildSubmitButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
            _canSubmit && !_isSubmitting ? _submitVerification : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canSubmit
                  ? AppColors.crimson
                  : AppColors.disabled,
              disabledBackgroundColor: AppColors.disabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Submit ho raha hai...",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _canSubmit
                      ? Icons.verified_user_rounded
                      : Icons.lock_outline_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _canSubmit
                      ? "Verification Submit Karein"
                      : "Sab documents upload karein",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Privacy note
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 13, color: AppColors.muted),
            const SizedBox(width: 5),
            Text(
              "Documents secure hain • Sirf verification ke liye",
              style: TextStyle(
                  fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time_rounded,
                size: 13, color: AppColors.muted),
            const SizedBox(width: 5),
            Text(
              "Verification 24-48 ghante mein hoti hai",
              style: TextStyle(
                  fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }

  // ── SUCCESS STATE ──────────────────────────────────
  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success animation container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.successSurface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 3),
              ),
              child: const Center(
                child: Icon(
                  Icons.verified_rounded,
                  size: 52,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Documents Submit Ho Gaye! 🎉",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Aapke documents review mein hain.\n24-48 ghante mein verified badge\naapki profile pe lag jayega.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Status steps
            _buildStatusStep(
                true, '1', 'Documents submitted', 'Abhi hua'),
            _buildStatusStep(
                false, '2', 'Review mein hai', '24-48 ghante'),
            _buildStatusStep(
                false, '3', 'Verified badge milega', 'Jald hi'),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Profile Pe Wapas Jaao",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep(
      bool isDone,
      String step,
      String label,
      String time,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success
                  : AppColors.ivoryDark,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone
                    ? AppColors.success
                    : AppColors.border,
              ),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded,
                  size: 16, color: Colors.white)
                  : Text(
                step,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isDone
                    ? FontWeight.w600
                    : FontWeight.w400,
                color:
                isDone ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: isDone ? AppColors.success : AppColors.muted,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}