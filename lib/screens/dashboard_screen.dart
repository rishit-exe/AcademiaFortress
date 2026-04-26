import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<List<Map<String, dynamic>>> examsStream = Supabase
        .instance.client
        .from('exams')
        .stream(primaryKey: ['id']).order('date', ascending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFFEFBEA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black, height: 1),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Icon(Icons.menu, color: Colors.black, size: 28),
        ),
        title: const Text(
          'AcademiaFortress',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NEXT UP SECTION ---
            _buildSectionHeader('NEXT UP'),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: examsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD600)));
                }
                final exams = snapshot.data!;
                if (exams.isEmpty) {
                  return _buildNextUpCard(
                    month: 'OCT',
                    day: '24',
                    time: '09:00 AM',
                    title: 'DATA STRUCTURES & ALGORITHMS FINAL',
                    tags: [
                      _buildTag('COMPUTER SCIENCE', const Color(0xFF5CFFA5)),
                      const SizedBox(width: 8),
                      _buildTag('⚠️ HIGH WEIGHT', Colors.white, borderColor: Colors.red, textColor: Colors.red),
                    ],
                  );
                }
                final next = exams.first;
                final dateStr = next['date'] ?? 'OCT 24';
                final parts = dateStr.toString().split(' ');
                return _buildNextUpCard(
                  month: parts.isNotEmpty ? parts[0].toUpperCase() : 'OCT',
                  day: parts.length > 1 ? parts[1] : '24',
                  time: next['time'] ?? '09:00 AM',
                  title: (next['title'] ?? 'UNKNOWN').toString().toUpperCase(),
                  tags: [
                    _buildTag('COMPUTER SCIENCE', const Color(0xFF5CFFA5)),
                    const SizedBox(width: 8),
                    _buildTag('⚠️ HIGH WEIGHT', Colors.white, borderColor: Colors.red, textColor: Colors.red),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // --- UPCOMING SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSectionHeader('UPCOMING'),
                const Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: examsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final exams = snapshot.data!;
                final upcoming = exams.length > 1 ? exams.skip(1).take(3).toList() : [
                  {'title': 'LINEAR ALGEBRA MIDTERM', 'date': 'NOV 02', 'time': '10:00', 'tag': 'MATHEMATICS', 'tagColor': 0xFFD8B4FE},
                  {'title': 'QUANTUM MECHANICS I',   'date': 'NOV 15', 'time': '10:00', 'tag': 'PHYSICS',     'tagColor': 0xFFFCA5A5},
                ];
                return Column(
                  children: upcoming.map((exam) {
                    final dateStr = (exam['date'] ?? '').toString();
                    final parts = dateStr.split(' ');
                    final month = parts.isNotEmpty ? parts[0].toUpperCase() : 'NOV';
                    final day   = parts.length > 1 ? parts[1] : '01';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildUpcomingCard(
                        dateLabel: '$month $day',
                        title: (exam['title'] ?? '').toString().toUpperCase(),
                        time: (exam['time'] ?? '').toString(),
                        tagLabel: (exam['tag'] ?? 'COURSE').toString(),
                        tagColor: Color(exam['tagColor'] as int? ?? 0xFFD8B4FE),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 28),

            // --- BATTLE STATS ---
            _buildSectionHeader('BATTLE STATS'),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: examsStream,
              builder: (context, snapshot) {
                final total = snapshot.hasData ? snapshot.data!.length : 4;
                return _buildBattleStats(examsLeft: total, studyHrs: 12);
              },
            ),

            const SizedBox(height: 28),

            // --- TARGETS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('TARGETS'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTarget(label: 'REVIEW CH 4-6', completed: false),
            const SizedBox(height: 8),
            _buildTarget(label: 'SUBMIT CS PROJECT', completed: true),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  // ─── SECTION HEADER ──────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        Container(height: 3, width: 60, color: Colors.black, margin: const EdgeInsets.only(top: 3)),
      ],
    );
  }

  // ─── NEXT UP CARD ─────────────────────────────────────────────────────────────
  Widget _buildNextUpCard({
    required String month,
    required String day,
    required String time,
    required String title,
    required List<Widget> tags,
  }) {
    return Transform.translate(
      offset: const Offset(-4, -4),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFD600),
          border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 3)),
          boxShadow: [
            BoxShadow(color: Colors.black, offset: Offset(8, 8), blurRadius: 0),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: date box + tags
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text(
                          month,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: Text(
                          time,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Tags column
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Main title
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // Button
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: const Text(
                'START PREP ->',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAG CHIP ─────────────────────────────────────────────────────────────────
  Widget _buildTag(String label, Color bg, {Color borderColor = Colors.black, Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─── UPCOMING CARD ───────────────────────────────────────────────────────────
  Widget _buildUpcomingCard({
    required String dateLabel,
    required String title,
    required String time,
    required String tagLabel,
    required Color tagColor,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE5E0D0),
        border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date strip
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              dateLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTag(tagLabel, tagColor),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BATTLE STATS ────────────────────────────────────────────────────────────
  Widget _buildBattleStats({required int examsLeft, required int studyHrs}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      '$examsLeft',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'EXAMS LEFT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 2, color: Colors.black),
            Expanded(
              child: Container(
                color: const Color(0xFFFFD600),
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      '$studyHrs',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'STUDY HRS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TARGET ITEM ─────────────────────────────────────────────────────────────
  Widget _buildTarget({required String label, required bool completed}) {
    return Container(
      decoration: BoxDecoration(
        color: completed ? Colors.black : const Color(0xFFFEFBEA),
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: completed ? Colors.black : Colors.transparent,
              border: Border.all(color: completed ? Colors.white : Colors.black, width: 2),
            ),
            child: completed
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: completed ? Colors.white : Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.5,
              decoration: completed ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
