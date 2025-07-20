import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import '../services/user_service.dart';
import 'package:get/get.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await UserService().fetchAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers =
          _allUsers.where((user) {
            final name = (user['displayName'] ?? '').toLowerCase();
            final email = (user['email'] ?? '').toLowerCase();
            return name.contains(query) || email.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      drawer: const AdminDrawer(selectedRoute: '/admin/users'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search users',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator())),
            if (_error != null)
              Expanded(child: Center(child: Text('Error: \\$_error'))),
            if (!_isLoading && _error == null)
              Expanded(
                child:
                    _filteredUsers.isEmpty
                        ? const Center(child: Text('No users found.'))
                        : ListView.separated(
                          itemCount: _filteredUsers.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(
                                user['displayName'] ??
                                    user['email'] ??
                                    user['uid'] ??
                                    'Unknown',
                              ),
                              subtitle: Text(user['email'] ?? ''),
                              trailing:
                                  user['isAdmin'] == true
                                      ? const Chip(
                                        label: Text(
                                          'Admin',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.blue,
                                      )
                                      : null,
                              onTap: () {
                                Get.toNamed(
                                  '/admin/user-details',
                                  arguments: user,
                                );
                              },
                            );
                          },
                        ),
              ),
          ],
        ),
      ),
    );
  }
}
