import 'package:flutter/material.dart';
import '../services/countdown_service.dart';
import '../widgets/admin_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CountdownSettingsScreen extends StatefulWidget {
  const CountdownSettingsScreen({super.key});

  @override
  State<CountdownSettingsScreen> createState() => _CountdownSettingsScreenState();
}

class _CountdownSettingsScreenState extends State<CountdownSettingsScreen> {
  final CountdownService _countdownService = CountdownService();
  DateTime? _registrationDeadline;
  DateTime? _jubileeDate;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCountdownDates();
  }

  Future<void> _loadCountdownDates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dates = await _countdownService.getCountdownDates();
      setState(() {
        _registrationDeadline = dates['registrationDeadline'] != null
            ? (dates['registrationDeadline'] as Timestamp).toDate()
            : null;
        _jubileeDate = dates['jubileeDate'] != null
            ? (dates['jubileeDate'] as Timestamp).toDate()
            : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dates: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isRegistration) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isRegistration
          ? (_registrationDeadline ?? DateTime.now().add(const Duration(days: 30)))
          : (_jubileeDate ?? DateTime.now().add(const Duration(days: 100))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isRegistration) {
          _registrationDeadline = picked;
        } else {
          _jubileeDate = picked;
        }
      });
    }
  }

  Future<void> _saveDates() async {
    if (_registrationDeadline == null || _jubileeDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both dates')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _countdownService.updateCountdownDates(
        registrationDeadline: _registrationDeadline!,
        jubileeDate: _jubileeDate!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Countdown dates updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update countdown dates'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }

  Duration _calculateCountdown(DateTime? targetDate) {
    if (targetDate == null) return Duration.zero;
    final now = DateTime.now();
    return targetDate.isAfter(now) ? targetDate.difference(now) : Duration.zero;
  }

  String _formatCountdown(Duration duration) {
    if (duration.inSeconds <= 0) return 'Expired';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    return '${days}d ${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown Settings'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      drawer: const AdminDrawer(selectedRoute: '/admin/countdown-settings'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Countdown Management',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1976D2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Set the dates for registration deadline and jubilee celebration. These dates will be used to display countdown timers on the main page.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Registration Deadline Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event_busy,
                                color: const Color(0xFF1976D2),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Registration Deadline',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1976D2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: const Text('Selected Date'),
                                  subtitle: Text(
                                    _formatDate(_registrationDeadline),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  tileColor: Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () => _selectDate(context, true),
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Select Date'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer, color: Colors.orange.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Countdown: ${_formatCountdown(_calculateCountdown(_registrationDeadline))}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Jubilee Celebration Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.celebration,
                                color: const Color(0xFFD4AF37),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Jubilee Celebration Date',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD4AF37),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: const Text('Selected Date'),
                                  subtitle: Text(
                                    _formatDate(_jubileeDate),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  tileColor: Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () => _selectDate(context, false),
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Select Date'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Countdown: ${_formatCountdown(_calculateCountdown(_jubileeDate))}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveDates,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Saving...'),
                              ],
                            )
                          : const Text(
                              'Save Countdown Dates',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
