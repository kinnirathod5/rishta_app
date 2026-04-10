import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

// ── MOCK DATA CLASSES ──────────────────────────────────────────

enum InterestStatus { pending, accepted, declined, withdrawn }

class MockInterest {
  final String id;
  final String fromName;
  final String fromAge;
  final String fromCaste;
  final String fromCity;
  final String fromProfession;
  final String fromEmoji;
  final bool fromVerified;
  final InterestStatus status;
  final String timeAgo;
  final bool isReceived; // true=received, false=sent

  const MockInterest({
    required this.id,
    required this.fromName,
    required this.fromAge,
    required this.fromCaste,
    required this.fromCity,
    required this.fromProfession,
    required this.fromEmoji,
    required this.fromVerified,
    required this.status,
    required this.timeAgo,
    required this.isReceived,
  });

  MockInterest copyWith({InterestStatus? status}) {
    return MockInterest(
      id: id,
      fromName: fromName,
      fromAge: fromAge,
      fromCaste: fromCaste,
      fromCity: fromCity,
      fromProfession: fromProfession,
      fromEmoji: fromEmoji,
      fromVerified: fromVerified,
      status: status ?? this.status,
      timeAgo: timeAgo,
      isReceived: isReceived,
    );
  }
}

// ── MOCK DATA INSTANCES ────────────────────────────────────────

final List<MockInterest> receivedMockData = [
  const MockInterest(
    id: 'r1', fromName: 'Rahul Sharma',
    fromAge: '29', fromCaste: 'Brahmin',
    fromCity: 'Delhi', fromProfession: 'Engineer',
    fromEmoji: '👨‍💻', fromVerified: true,
    status: InterestStatus.pending,
    timeAgo: '2 ghante pehle', isReceived: true
  ),
  const MockInterest(
    id: 'r2', fromName: 'Amit Gupta',
    fromAge: '31', fromCaste: 'Kayastha',
    fromCity: 'Mumbai', fromProfession: 'Manager',
    fromEmoji: '👨‍💼', fromVerified: false,
    status: InterestStatus.pending,
    timeAgo: '5 ghante pehle', isReceived: true
  ),
  const MockInterest(
    id: 'r3', fromName: 'Vikram Singh',
    fromAge: '28', fromCaste: 'Rajput',
    fromCity: 'Jaipur', fromProfession: 'Doctor',
    fromEmoji: '👨‍⚕️', fromVerified: true,
    status: InterestStatus.pending,
    timeAgo: '1 din pehle', isReceived: true
  ),
  const MockInterest(
    id: 'r4', fromName: 'Arjun Patel',
    fromAge: '30', fromCaste: 'Patel',
    fromCity: 'Ahmedabad', fromProfession: 'CA',
    fromEmoji: '👨‍🏫', fromVerified: true,
    status: InterestStatus.pending,
    timeAgo: '2 din pehle', isReceived: true
  ),
  const MockInterest(
    id: 'r5', fromName: 'Rohan Mehta',
    fromAge: '27', fromCaste: 'Brahmin',
    fromCity: 'Pune', fromProfession: 'Developer',
    fromEmoji: '👨‍🔬', fromVerified: false,
    status: InterestStatus.pending,
    timeAgo: '3 din pehle', isReceived: true
  ),
];

final List<MockInterest> sentMockData = [
  const MockInterest(
    id: 's1', fromName: 'Priya Sharma',
    fromAge: '26', fromCaste: 'Brahmin',
    fromCity: 'Delhi', fromProfession: 'Software Engineer',
    fromEmoji: '👩', fromVerified: true,
    status: InterestStatus.pending,
    timeAgo: '1 ghanta pehle', isReceived: false
  ),
  const MockInterest(
    id: 's2', fromName: 'Anjali Gupta',
    fromAge: '24', fromCaste: 'Kayastha',
    fromCity: 'Mumbai', fromProfession: 'Marketing',
    fromEmoji: '👩‍💼', fromVerified: false,
    status: InterestStatus.accepted,
    timeAgo: '1 din pehle', isReceived: false
  ),
  const MockInterest(
    id: 's3', fromName: 'Meera Singh',
    fromAge: '28', fromCaste: 'Rajput',
    fromCity: 'Jaipur', fromProfession: 'Doctor',
    fromEmoji: '👩‍⚕️', fromVerified: true,
    status: InterestStatus.declined,
    timeAgo: '2 din pehle', isReceived: false
  ),
  const MockInterest(
    id: 's4', fromName: 'Sneha Patel',
    fromAge: '25', fromCaste: 'Patel',
    fromCity: 'Ahmedabad', fromProfession: 'CA',
    fromEmoji: '👩‍🏫', fromVerified: true,
    status: InterestStatus.pending,
    timeAgo: '3 din pehle', isReceived: false
  ),
];

final List<MockInterest> connectedMockData = [
  const MockInterest(
    id: 'c1', fromName: 'Anjali Gupta',
    fromAge: '24', fromCaste: 'Kayastha',
    fromCity: 'Mumbai', fromProfession: 'Marketing',
    fromEmoji: '👩‍💼', fromVerified: false,
    status: InterestStatus.accepted,
    timeAgo: '1 din pehle', isReceived: false
  ),
  const MockInterest(
    id: 'c2', fromName: 'Rahul Sharma',
    fromAge: '29', fromCaste: 'Brahmin',
    fromCity: 'Delhi', fromProfession: 'Engineer',
    fromEmoji: '👨‍💻', fromVerified: true,
    status: InterestStatus.accepted,
    timeAgo: '2 din pehle', isReceived: true
  ),
];

// ── INTERESTS SCREEN ──────────────────────────────────────────

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<MockInterest> _receivedInterests;
  late List<MockInterest> _sentInterests;
  late List<MockInterest> _connectedList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _receivedInterests = List.from(receivedMockData);
    _sentInterests = List.from(sentMockData);
    _connectedList = List.from(connectedMockData);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _acceptInterest(String id) async {
    setState(() {
      final idx = _receivedInterests.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final interest = _receivedInterests[idx].copyWith(status: InterestStatus.accepted);
        _connectedList.insert(0, interest);
        _receivedInterests.removeAt(idx);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Interest accept kar liya! 🎉"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _declineInterest(String id) {
    setState(() {
      _receivedInterests.removeWhere((i) => i.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Interest decline kar diya"),
        backgroundColor: AppColors.inkSoft,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _withdrawInterest(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Interest Wapas Lein?"),
        content: const Text("Kya aap sach mein yeh interest wapas lena chahte ho?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Nahi", style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final idx = _sentInterests.indexWhere((i) => i.id == id);
                if (idx != -1) {
                  _sentInterests[idx] = _sentInterests[idx].copyWith(status: InterestStatus.withdrawn);
                }
              });
            },
            child: const Text("Haan, Wapas Lo", style: TextStyle(color: AppColors.crimson, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPhoneNumber(MockInterest interest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.crimsonSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(interest.fromEmoji, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(interest.fromName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("${interest.fromCaste} • ${interest.fromCity}", style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.ivory,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Phone Number", style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text("+91 98765 43210", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink, letterSpacing: 1)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Copy to clipboard logic
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.ivoryDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Icon(Icons.copy_rounded, size: 16, color: AppColors.muted)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.call_rounded, size: 18),
                        SizedBox(width: 8),
                        Text("Call Karo", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('💬', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text("WhatsApp", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text("Band Karo", style: TextStyle(fontSize: 13, color: AppColors.muted)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _receivedInterests.where((i) => i.status == InterestStatus.pending).length;
    final connectedCount = _connectedList.length;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            _buildTabBar(pendingCount, connectedCount),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReceivedTab(),
                  _buildSentTab(),
                  _buildConnectedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Interests", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
              SizedBox(height: 2),
              Text("Apne rishton ka hisaab", style: TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.crimsonSurface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.crimson.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.favorite_rounded, size: 14, color: AppColors.crimson),
                SizedBox(width: 6),
                Text("5 Naye", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.crimson)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(int pendingCount, int connectedCount) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.crimson,
        unselectedLabelColor: AppColors.muted,
        indicatorColor: AppColors.crimson,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        tabs: [
          Tab(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Text("Aaye"),
                if (pendingCount > 0)
                  Positioned(
                    top: -4,
                    right: -10,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(color: AppColors.crimson, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          "$pendingCount",
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Tab(text: "Bheje (${_sentInterests.length})"),
          Tab(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Text("Connected"),
                if (connectedCount > 0)
                  Positioned(
                    top: -4,
                    right: -14,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(gradient: AppColors.goldGradient, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          "$connectedCount",
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedTab() {
    if (_receivedInterests.isEmpty) {
      return _buildEmptyState('💌', 'Abhi Koi Interest Nahi', 'Jab koi aapko interest bhejega\nyahan dikhega');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _receivedInterests.length,
      itemBuilder: (context, index) => _buildReceivedCard(_receivedInterests[index], index),
    );
  }

  Widget _buildReceivedCard(MockInterest interest, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.crimsonSurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Text(interest.fromEmoji, style: const TextStyle(fontSize: 28))),
                    ),
                    if (interest.fromVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Center(child: Icon(Icons.verified_rounded, size: 10, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(interest.fromName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
                          Text(interest.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("${interest.fromAge} • ${interest.fromCaste} • ${interest.fromCity}", style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.work_outline_rounded, size: 12, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(interest.fromProfession, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text("Aapko interest bheja hai 💌", style: TextStyle(fontSize: 12, color: AppColors.crimson, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.push('/profile/${interest.id}', extra: null); // Extra is null since we don't have full MockProfile here
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.ivoryDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person_outline_rounded, size: 14, color: AppColors.inkSoft),
                          SizedBox(width: 6),
                          Text("Profile Dekho", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _declineInterest(interest.id),
                  child: Container(
                    width: 44,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                    ),
                    child: const Center(child: Icon(Icons.close_rounded, size: 18, color: AppColors.error)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _acceptInterest(interest.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.crimson,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.favorite_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Accept Karo", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentTab() {
    if (_sentInterests.isEmpty) {
      return _buildEmptyState('📤', 'Koi Interest Nahi Bheja', 'Profiles dekho aur interest bhejo');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sentInterests.length,
      itemBuilder: (context, index) => _buildSentCard(_sentInterests[index]),
    );
  }

  Widget _buildSentCard(MockInterest interest) {
    Color borderColor;
    if (interest.status == InterestStatus.accepted) {
      borderColor = AppColors.success.withValues(alpha: 0.3);
    } else if (interest.status == InterestStatus.declined) {
      borderColor = AppColors.error.withValues(alpha: 0.2);
    } else {
      borderColor = AppColors.border;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.crimsonSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(interest.fromEmoji, style: const TextStyle(fontSize: 26))),
                ),
                if (interest.fromVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(child: Icon(Icons.verified_rounded, size: 10, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(interest.fromName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(height: 3),
                  Text("${interest.fromAge} • ${interest.fromCaste} • ${interest.fromCity}", style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  const SizedBox(height: 3),
                  Text(interest.fromProfession, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                  const SizedBox(height: 8),
                  _buildStatusChip(interest.status),
                ],
              ),
            ),
            if (interest.status == InterestStatus.pending)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(interest.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _withdrawInterest(interest.id),
                    child: const Text(
                      "Wapas Lo",
                      style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(InterestStatus status) {
    Color bg;
    Color border;
    Color color;
    String text;

    switch (status) {
      case InterestStatus.pending:
        bg = AppColors.goldSurface;
        border = AppColors.gold.withValues(alpha: 0.3);
        color = AppColors.gold;
        text = "Jawab Ka Intezaar";
        break;
      case InterestStatus.accepted:
        bg = AppColors.successSurface;
        border = AppColors.success.withValues(alpha: 0.3);
        color = AppColors.success;
        text = "✓ Accept Ho Gaya!";
        break;
      case InterestStatus.declined:
        bg = AppColors.errorSurface;
        border = AppColors.error.withValues(alpha: 0.2);
        color = AppColors.error;
        text = "Decline Ho Gaya";
        break;
      case InterestStatus.withdrawn:
        bg = AppColors.ivoryDark;
        border = AppColors.border;
        color = AppColors.muted;
        text = "Wapas Liya";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildConnectedTab() {
    if (_connectedList.isEmpty) {
      return _buildEmptyState('🤝', 'Abhi Koi Connection Nahi', 'Interests accept karo\nconnections banao');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _connectedList.length,
      itemBuilder: (context, index) => _buildConnectedCard(_connectedList[index]),
    );
  }

  Widget _buildConnectedCard(MockInterest interest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.crimsonSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(interest.fromEmoji, style: const TextStyle(fontSize: 28))),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(child: Text('🤝', style: TextStyle(fontSize: 8))),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(interest.fromName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(height: 3),
                  Text("${interest.fromCaste} • ${interest.fromCity}", style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                        const SizedBox(width: 5),
                        Text("Connected ${interest.timeAgo}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () => _showPhoneNumber(interest),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                    ),
                    child: const Center(child: Icon(Icons.call_outlined, size: 18, color: AppColors.success)),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push('/chat/${interest.id}', extra: {
                    'name': interest.fromName,
                    'emoji': interest.fromEmoji,
                    'caste': interest.fromCaste,
                    'city': interest.fromCity,
                  }),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.infoSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                    ),
                    child: const Center(child: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.info)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String emoji, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.crimson,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Profiles Dekhein 💑", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
