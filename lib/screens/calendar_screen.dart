import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(2023, 10);
  int _selectedDay = 12;

  // day number -> list of event colors (small squares inside each cell)
  final Map<int, List<Color>> _eventDots = {
    4:  [const Color(0xFF60A5FA)],
    9:  [const Color(0xFF4ADE80)],
    11: [const Color(0xFFFFD600)],
    18: [const Color(0xFFFF4444), const Color(0xFF60A5FA)],
    23: [const Color(0xFF60A5FA)],
    28: [const Color(0xFF4ADE80)],
  };

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
                color: const Color(0xFF334155),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── CALENDAR CARD ────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.fromBorderSide(
                    BorderSide(color: Colors.black, width: 2)),
                boxShadow: [
                  BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0),
                ],
              ),
              child: Column(
                children: [
                  // Month header row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_monthName(_focusedMonth.month).toUpperCase()} ${_focusedMonth.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.black,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        _navButton(Icons.chevron_left, () {
                          setState(() => _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month - 1));
                        }),
                        const SizedBox(width: 8),
                        _navButton(Icons.chevron_right, () {
                          setState(() => _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month + 1));
                        }),
                      ],
                    ),
                  ),
                  // Black divider under header
                  Container(height: 2, color: Colors.black),
                  // Day-of-week labels
                  Container(
                    color: const Color(0xFFF5F0DC),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                          .map((d) => Expanded(
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  // Thin line below labels
                  Container(height: 1.5, color: Colors.black),
                  // Calendar grid (no extra padding — cells touch borders)
                  _buildCalendarGrid(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── AGENDA CARD ─────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.fromBorderSide(
                    BorderSide(color: Colors.black, width: 2)),
                boxShadow: [
                  BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Agenda header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AGENDA',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.black,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'Oct $_selectedDay',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 2, color: Colors.black),

                  // Agenda items (live or default)
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: examsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Column(
                          children: snapshot.data!.map((exam) {
                            return _buildAgendaItem(
                              title: (exam['title'] ?? '')
                                  .toString()
                                  .toUpperCase(),
                              time: (exam['time'] ?? '').toString().trim(),
                              location: exam['location']?.toString(),
                              stripColor: const Color(0xFF60A5FA),
                              isExam: exam['is_urgent'] == true,
                            );
                          }).toList(),
                        );
                      }
                      // Design defaults
                      return Column(
                        children: [
                          _buildAgendaItem(
                            title: 'ADVANCED CALCULUS',
                            time: '09:00 AM – 10:30 AM',
                            stripColor: const Color(0xFF60A5FA),
                          ),
                          Container(height: 1, color: Colors.black12),
                          _buildAgendaItem(
                            title: 'PHYSICS MIDTERM',
                            time: '11:00 AM – 01:00 PM',
                            location: 'Hall B',
                            stripColor: const Color(0xFFFF4444),
                            isExam: true,
                          ),
                          Container(height: 1, color: Colors.black12),
                          _buildAgendaItem(
                            title: 'STUDY GROUP',
                            time: '03:00 PM – 05:00 PM',
                            stripColor: const Color(0xFF4ADE80),
                          ),
                        ],
                      );
                    },
                  ),

                  // ADD EVENT button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Transform.translate(
                      offset: const Offset(-4, -4),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD600),
                          border: Border.fromBorderSide(
                              BorderSide(color: Colors.black, width: 2)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/add_exam'),
                          style: TextButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                          ),
                          child: const Text(
                            '+ ADD EVENT',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  // ─── MONTH NAME ───────────────────────────────────────────────────────────────
  String _monthName(int m) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[m];
  }

  // ─── NAV BUTTON ──────────────────────────────────────────────────────────────
  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }

  // ─── CALENDAR GRID ───────────────────────────────────────────────────────────
  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final startWeekday = firstDay.weekday % 7; // Sun=0
    final prevDays =
        DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;

    final cells = <_CalCell>[];
    for (int i = startWeekday - 1; i >= 0; i--) {
      cells.add(_CalCell(day: prevDays - i, inMonth: false));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(_CalCell(day: d, inMonth: true, events: _eventDots[d]));
    }
    while (cells.length % 7 != 0) {
      cells.add(_CalCell(
          day: cells.length - daysInMonth - startWeekday + 1,
          inMonth: false));
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells.sublist(i, i + 7).map(_buildDayCell).toList(),
        ),
      ));
    }
    return Column(children: rows);
  }

  // ─── DAY CELL ────────────────────────────────────────────────────────────────
  Widget _buildDayCell(_CalCell cell) {
    final isSelected = cell.inMonth && cell.day == _selectedDay;

    final Color bg;
    final Color borderColor;
    final double borderWidth;
    final Color textColor;

    if (!cell.inMonth) {
      bg = const Color(0xFFE8E3D5);       // muted tan for grey-out days
      borderColor = Colors.black12;
      borderWidth = 0.5;
      textColor = Colors.black26;
    } else if (isSelected) {
      bg = const Color(0xFFFFD600);       // yellow selected
      borderColor = Colors.black;
      borderWidth = 2.5;
      textColor = Colors.black;
    } else {
      bg = Colors.white;
      borderColor = Colors.black;
      borderWidth = 1;
      textColor = Colors.black;
    }

    return Expanded(
      child: GestureDetector(
        onTap: cell.inMonth
            ? () => setState(() => _selectedDay = cell.day)
            : null,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date number
              Text(
                '${cell.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: textColor,
                ),
              ),
              // Event color squares at bottom of cell
              if (cell.events != null && cell.events!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: cell.events!
                      .map((c) => Container(
                            width: 7,
                            height: 7,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 1),
                            color: c,
                          ))
                      .toList(),
                )
              else
                const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AGENDA ITEM ─────────────────────────────────────────────────────────────
  Widget _buildAgendaItem({
    required String title,
    required String time,
    String? location,
    required Color stripColor,
    bool isExam = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFBEA),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: stripColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (isExam)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black, width: 1.5),
                            ),
                            child: const Text(
                              'EXAM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.schedule,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(time,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600)),
                    ]),
                    if (location != null) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(location,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600)),
                      ]),
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
}

// ─── DATA CLASS ───────────────────────────────────────────────────────────────
class _CalCell {
  final int day;
  final bool inMonth;
  final List<Color>? events;
  const _CalCell({required this.day, required this.inMonth, this.events});
}
