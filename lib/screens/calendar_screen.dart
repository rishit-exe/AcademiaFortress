import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<List<Map<String, dynamic>>> examsStream = 
        Supabase.instance.client.from('exams').stream(primaryKey: ['id']).order('date', ascending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CALENDAR'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthGrid(),
            const SizedBox(height: 32),
            const Text(
              'AGENDA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: examsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE0FF00)));
                }
                final exams = snapshot.data!;
                if (exams.isEmpty) {
                  return const Text('NO EXAMS SCHEDULED', style: TextStyle(color: Colors.white54));
                }
                return Column(
                  children: exams.map((exam) {
                    return _buildAgendaItem(
                      title: exam['title'] ?? 'UNKNOWN',
                      time: '${exam['date'] ?? ''} ${exam['time'] ?? ''}',
                      location: exam['location'],
                      isUrgent: exam['is_urgent'] == true,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildMonthGrid() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF333333)),
        color: const Color(0xFF1A1A1A),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
              return Text(
                day,
                style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  int dayNum = (i * 7) + index - 2;
                  bool isToday = dayNum == 15;
                  bool hasEvent = dayNum == 18 || dayNum == 22;
                  
                  if (dayNum < 1 || dayNum > 31) {
                    return const SizedBox(width: 24);
                  }

                  return Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isToday ? const Color(0xFFE0FF00) : null,
                      border: hasEvent ? Border.all(color: const Color(0xFFFF3366), width: 2) : null,
                    ),
                    child: Text(
                      dayNum.toString(),
                      style: TextStyle(
                        color: isToday ? Colors.black : Colors.white,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildAgendaItem({
    required String title,
    required String time,
    String? location,
    bool isUrgent = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: isUrgent ? const Color(0xFFFF3366) : const Color(0xFF333333)),
        color: const Color(0xFF1A1A1A),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            color: isUrgent ? const Color(0xFFFF3366) : const Color(0xFFE0FF00),
            margin: const EdgeInsets.only(right: 16.0),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                if (location != null && location.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(location, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
