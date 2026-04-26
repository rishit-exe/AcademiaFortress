import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';

class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  Future<void> _deployExam() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.from('exams').insert({
        'title': _titleController.text.trim(),
        'date': _dateController.text.trim(),
        'time': _timeController.text.trim(),
        'location': _locationController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('EXAM DEPLOYED TO MAINFRAME'),
            backgroundColor: Color(0xFFE0FF00),
          ),
        );
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERROR: $e'),
            backgroundColor: const Color(0xFFFF3366),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEPLOY_EXAM'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Define the parameters of your upcoming academic engagement. Accuracy is mandatory.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildInputField(
              label: 'ENGAGEMENT DESIGNATION (NAME)', 
              controller: _titleController,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildInputField(
                  label: 'DATE', 
                  icon: Icons.calendar_today,
                  controller: _dateController,
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField(
                  label: 'TIME', 
                  icon: Icons.access_time,
                  controller: _timeController,
                )),
              ],
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'COORDINATES (LOCATION)', 
              icon: Icons.location_on,
              controller: _locationController,
            ),
            const SizedBox(height: 24),
            _buildInputField(label: 'NOTES / DIRECTIVES', maxLines: 4),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _deployExam,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      'EXECUTE DEPLOYMENT',
                      style: TextStyle(letterSpacing: 2, fontSize: 16),
                    ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Widget _buildInputField({
    required String label, 
    IconData? icon, 
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE0FF00),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
          ),
        ),
      ],
    );
  }
}
