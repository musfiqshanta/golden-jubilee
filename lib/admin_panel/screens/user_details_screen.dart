import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suborno_joyonti/admin_panel/widgets/admin_drawer.dart';

import '../services/user_service.dart';

class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> user = Get.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () async {
              final updated = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => _EditUserDialog(user: user),
              );
              if (updated != null) {
                await UserService().updateUser(user['uid'], updated);
                Get.snackbar(
                  'User Updated',
                  'User details updated successfully.',
                );
                Get.back();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete/Block',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Delete/Block User'),
                      content: const Text(
                        'Are you sure you want to delete/block this user?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                await UserService().deleteUser(user['uid']);
                Get.snackbar(
                  'User Deleted/Blocked',
                  'User has been deleted/blocked.',
                );
                Get.offAllNamed('/admin/users');
              }
            },
          ),
        ],
      ),
      drawer: const AdminDrawer(selectedRoute: '/admin/users'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              user['displayName'] ?? user['email'] ?? user['uid'] ?? 'Unknown',
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
          ),
          const Divider(),
          ...user.entries.map(
            (entry) => ListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value.toString()),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  const _EditUserDialog({required this.user});

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user['displayName'] ?? '',
    );
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _isAdmin = widget.user['isAdmin'] == true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isAdmin,
                onChanged: (v) => setState(() => _isAdmin = v ?? false),
              ),
              const Text('Admin'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'displayName': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'isAdmin': _isAdmin,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
