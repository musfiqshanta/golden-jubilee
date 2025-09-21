import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_details_screen.dart';

class DateFilterScreen extends StatefulWidget {
  const DateFilterScreen({super.key});

  @override
  State<DateFilterScreen> createState() => _DateFilterScreenState();
}

class _DateFilterScreenState extends State<DateFilterScreen> {
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _selectedDate = DateTime.now();
    _loadUsersForDate(_selectedDate!);
  }

  Future<void> _loadUsersForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print(
        '📅 Loading users for date: ${date.toIso8601String().split('T')[0]}',
      );

      // Create date range for the selected date (start and end of day)
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
        59,
        999,
      );

      print(
        '🔍 Searching between: ${startOfDay.toIso8601String()} and ${endOfDay.toIso8601String()}',
      );

      final snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('registrations')
              .get();

      List<Map<String, dynamic>> usersForDate = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final registrationDate =
            data['registrationDate'] ?? data['registration_date'] ?? '';

        if (registrationDate.isNotEmpty) {
          try {
            // Parse the registration date
            DateTime regDate;
            if (registrationDate.contains('T')) {
              // ISO format
              regDate = DateTime.parse(registrationDate);
            } else {
              // Try different date formats
              regDate = DateTime.parse(registrationDate);
            }

            // Check if the registration date falls within the selected day
            if (regDate.isAfter(startOfDay.subtract(const Duration(days: 1))) &&
                regDate.isBefore(endOfDay.add(const Duration(days: 1)))) {
              // More precise check for the exact date
              if (regDate.year == date.year &&
                  regDate.month == date.month &&
                  regDate.day == date.day) {
                data['id'] = doc.id;
                data['documentPath'] = doc.reference.path;
                usersForDate.add(data);
                print(
                  '✅ Found user: ${data['name'] ?? 'Unknown'} - ${regDate.toIso8601String()}',
                );
              }
            }
          } catch (e) {
            print(
              '⚠️ Error parsing date for user ${data['name'] ?? 'Unknown'}: $registrationDate - $e',
            );
          }
        }
      }

      setState(() {
        _filteredUsers = usersForDate;
        _isLoading = false;
      });

      print(
        '✅ Loaded ${usersForDate.length} users for ${date.toIso8601String().split('T')[0]}',
      );
    } catch (e) {
      print('Error loading users for date: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B6914),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadUsersForDate(picked);
    }
  }

  List<Map<String, dynamic>> get _searchFilteredUsers {
    if (_searchQuery.isEmpty) return _filteredUsers;

    return _filteredUsers.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final mobile = (user['mobile'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          mobile.contains(query);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users by Registration Date'),
        backgroundColor: const Color(0xFF8B6914),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              if (_selectedDate != null) {
                _loadUsersForDate(_selectedDate!);
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selection Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Select Registration Date',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.date_range, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : 'Select a date',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _selectedDate != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name, email, or mobile...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.clear),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Users registered on ${_selectedDate != null ? _formatDate(_selectedDate!) : "selected date"}: ${_filteredUsers.length}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'Filtered: ${_searchFilteredUsers.length}',
                    style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
                  ),
              ],
            ),
          ),

          // Users list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchFilteredUsers.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No users registered on this date'
                                : 'No users match your search',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different date',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _searchFilteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _searchFilteredUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? 'No email';
    final mobile = user['mobile'] ?? 'No mobile';
    final totalPayable = user['totalPayable'] ?? 0;
    final paymentStatus = user['paymentStatus'] ?? 'Unknown';
    final registrationDate =
        user['registrationDate'] ?? user['registration_date'] ?? '';
    final spouseCount = user['spouseCount'] ?? 0;
    final childCount = user['childCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(paymentStatus),
          child: Icon(_getStatusIcon(paymentStatus), color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email'),
            Text('Mobile: $mobile'),
            Text('Amount: ৳$totalPayable'),
            Text('Status: $paymentStatus'),
            Text('Guests: ${spouseCount + childCount}'),
            if (registrationDate.isNotEmpty)
              Text('Time: ${_formatTime(registrationDate)}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => UserDetailsScreen(
                    user: user,
                    userType: _getUserType(user),
                  ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getUserType(Map<String, dynamic> user) {
    // Check if it's an online payment using the same logic as other screens
    final paymentData = user['paymentData'];
    if (paymentData != null && paymentData is Map<String, dynamic>) {
      final paymentMethod =
          paymentData['payment_method'] ?? paymentData['paymentMethod'] ?? '';
      final tranId = paymentData['tran_id'] ?? '';
      final valId = paymentData['val_id'] ?? '';
      final status = paymentData['status'] ?? '';
      final storeId = paymentData['store_id'] ?? '';

      if (paymentMethod.toLowerCase().contains('sslcommerz') ||
          paymentMethod.toLowerCase().contains('bkash') ||
          paymentMethod.toLowerCase().contains('mobilebanking') ||
          tranId.isNotEmpty ||
          valId.isNotEmpty ||
          status.toLowerCase() == 'valid' ||
          storeId.isNotEmpty) {
        return 'Online Payment';
      }
    }
    return 'Manual Approval';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
