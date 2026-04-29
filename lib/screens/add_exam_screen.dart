import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _titleController    = TextEditingController();
  final _dateController     = TextEditingController();
  final _timeController     = TextEditingController();
  bool _isCritical          = false;
  bool _isLoading           = false;

  Future<void> _deployExam() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('exams').insert({
        'title':     _titleController.text.trim(),
        'date':      _dateController.text.trim(),
        'time':      _timeController.text.trim(),
        'is_urgent': _isCritical,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFFFD600),
            content: const Text(
              'EXAM DEPLOYED TO MAINFRAME',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
            ),
          ),
        );
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFFF4444),
            content: Text('ERROR: $e',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFBEA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: Colors.black, height: 3),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Icon(Icons.menu, color: Colors.black, size: 28),
        ),
        title: const Text(
          'ACADEMIAFORTRESS',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PAGE TITLE ─────────────────────────────────────────
            const Text(
              'DEPLOY EXAM',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 34,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            // Yellow underline
            Container(
              height: 5,
              width: 200,
              color: const Color(0xFFFFD600),
              margin: const EdgeInsets.only(top: 4, bottom: 16),
            ),
            // Subtitle with left black bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 40,
                  color: Colors.black,
                  margin: const EdgeInsets.only(right: 10),
                ),
                const Expanded(
                  child: Text(
                    'Define the parameters of your upcoming academic engagement. Accuracy is mandatory.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── MAIN FORM CARD ─────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Hard shadow layer
                Positioned(
                  left: 8,
                  top: 8,
                  right: -8,
                  bottom: -8,
                  child: Container(color: Colors.black),
                ),
                // Main card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TARGET DESIGNATION
                      _buildLabel('TARGET DESIGNATION (EXAM NAME)'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _titleController,
                        hint: 'e.g. Advanced Quant...',
                        bgColor: Colors.white,
                      ),
                      const SizedBox(height: 22),

                      // EXECUTION DATE
                      _buildLabel('EXECUTION DATE'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _dateController,
                        hint: 'mm/dd/yyyy',
                        bgColor: const Color(0xFFF2F0E4),
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 22),

                      // LAUNCH TIME
                      _buildLabel('LAUNCH TIME'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _timeController,
                        hint: '--:-- --',
                        bgColor: const Color(0xFFF2F0E4),
                        icon: Icons.access_time_outlined,
                      ),
                      const SizedBox(height: 22),

                      // MARK AS CRITICAL PRIORITY
                      GestureDetector(
                        onTap: () => setState(() => _isCritical = !_isCritical),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F0E4),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _isCritical
                                      ? Colors.black
                                      : Colors.white,
                                  border: Border.all(
                                      color: Colors.black, width: 2),
                                ),
                                child: _isCritical
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'MARK AS CRITICAL PRIORITY',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // INITIALIZE EXAM button
                      Transform.translate(
                        offset: const Offset(-6, -6),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD600),
                            border: Border.fromBorderSide(
                                BorderSide(color: Colors.black, width: 3)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(8, 8),
                                  blurRadius: 0),
                            ],
                          ),
                          child: TextButton(
                            onPressed: _isLoading ? null : _deployExam,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.black, strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Black square with white + icon
                                      Container(
                                        width: 26,
                                        height: 26,
                                        color: Colors.black,
                                        child: const Icon(Icons.add,
                                            color: Colors.white, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'INITIALIZE EXAM',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // STATUS: PENDING tilted badge (top-right corner)
                Positioned(
                  top: -10,
                  right: 16,
                  child: Transform.rotate(
                    angle: -0.10, // ~6° CCW
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7DFF8E),
                        border:
                            Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Text(
                        'STATUS: PENDING',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BrutalistBottomNav(currentIndex: 2),
    );
  }

  // ─── LABEL ───────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w900,
        fontSize: 12,
        letterSpacing: 0.8,
      ),
    );
  }

  // ─── TEXT FIELD ──────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color bgColor,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: Colors.black38, fontWeight: FontWeight.w400),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
          suffixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(icon, color: Colors.black, size: 20),
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
      ),
    );
  }
}

// ─── BRUTALIST BOTTOM NAV ────────────────────────────────────────────────────
// Custom bottom nav with yellow highlight for active tab
class _BrutalistBottomNav extends StatelessWidget {
  final int currentIndex;
  const _BrutalistBottomNav({required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    final routes = ['/', '/calendar', '/add_exam'];
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _tab(context, 0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
          _tab(context, 1, Icons.calendar_today_outlined, Icons.calendar_today, 'Calendar'),
          _tab(context, 2, Icons.add_box_outlined, Icons.add_box, 'Add Exam'),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, int index, IconData icon,
      IconData activeIcon, String label) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(context, index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isActive
              ? BoxDecoration(
                  color: const Color(0xFFFFD600),
                  border: Border.all(color: Colors.black, width: 2),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: Colors.black,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight:
                      isActive ? FontWeight.w900 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
