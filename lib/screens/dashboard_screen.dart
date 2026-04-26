import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<List<Map<String, dynamic>>> examsStream = 
        Supabase.instance.client.from('exams').stream(primaryKey: ['id']).order('date', ascending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACADEMIA_FORTRESS'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('NEXT UP'),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: examsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE0FF00)));
                }
                final exams = snapshot.data!;
                if (exams.isEmpty) {
                  return _buildCard(title: 'No exams deployed', isHighlight: true);
                }
                final nextUp = exams.first;
                return _buildCard(
                  title: nextUp['title'] ?? 'UNKNOWN',
                  subtitle: '${nextUp['date'] ?? ''} ${nextUp['time'] ?? ''}',
                  isHighlight: true,
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('UPCOMING'),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: examsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final exams = snapshot.data!;
                if (exams.length <= 1) {
                  return const Text('NO OTHER UPCOMING EXAMS', style: TextStyle(color: Colors.white54));
                }
                return Column(
                  children: exams.skip(1).take(3).map((exam) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildCard(
                        title: exam['title'] ?? 'UNKNOWN',
                        subtitle: '${exam['date'] ?? ''} ${exam['time'] ?? ''}',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('BATTLE STATS'),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: examsStream,
              builder: (context, snapshot) {
                int totalExams = snapshot.hasData ? snapshot.data!.length : 0;
                return _buildStats(totalExams);
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('TARGETS'),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFFE0FF00)),
                  onPressed: () {},
                ),
              ],
            ),
            _buildTargetItem('Review Ch 4-6', true),
            _buildTargetItem('Submit CS Project', false),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildCard({required String title, String? subtitle, bool isHighlight = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFE0FF00) : const Color(0xFF1A1A1A),
        border: Border.all(color: isHighlight ? const Color(0xFFE0FF00) : const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.black : Colors.white,
            ),
          ),
          if (subtitle != null && subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isHighlight ? Colors.black87 : Colors.white54,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStats(int totalExams) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              children: [
                Text(
                  totalExams.toString(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE0FF00)),
                ),
                const Text('EXAMS', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: const Column(
              children: [
                Text(
                  '85%',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFF3366)),
                ),
                Text('WIN RATE', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetItem(String title, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
          color: isCompleted ? const Color(0xFFE0FF00) : Colors.white54,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.white54 : Colors.white,
          ),
        ),
      ),
    );
  }
}
