import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SelectUserWithSearch extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final Function(Map<String, dynamic>) onUserSelected;
  final  Map<String, dynamic>? selectedUser;

  const SelectUserWithSearch({
    super.key,
    required this.users,
    required this.onUserSelected,
    required this.selectedUser,
  });

  @override
  State<SelectUserWithSearch> createState() => _SelectUserWithSearchState();
}

class _SelectUserWithSearchState extends State<SelectUserWithSearch> {
  String? selectedUserId; // State to track the selected user
  String searchValue = '';

  @override
  void initState() {
    super.initState();
    // Initialize the selectedUserId with the passed-in selectedUser
    selectedUserId = widget.selectedUser?['id'].toString();
  }

  Map<String, Map<String, dynamic>> get filteredUsers => {
        for (final user in widget.users)
          if (user['name']
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()) ||
              user['email']
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()))
            user['id'].toString(): user
      };

  @override
  Widget build(BuildContext context) {
    return ShadSelect<String>.withSearch(
      minWidth: MediaQuery.of(context).size.width - 60,
      placeholder: const Text('Select'),
      onSearchChanged: (value) => setState(() => searchValue = value),
      searchPlaceholder: const Text('Search by name or email'),
      options: [
        if (filteredUsers.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('No users found'),
          ),
        ...widget.users.map(
          (user) {
            return Offstage(
              offstage: !filteredUsers.containsKey(user['id'].toString()),
              child: ShadOption(
                value: user['id'].toString(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name']),
                    Text(
                      user['email'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
      selectedOptionBuilder: (context, value) {
        // Find the currently selected user and display their name
        final selectedUser = widget.users.firstWhere(
          (user) => user['id'].toString() == value,
          orElse: () => {},
        );
        return Text(selectedUser['name'] ?? 'Select');
      },
      onChanged: (value) {
        if (value != null) {
          final selectedUser = widget.users.firstWhere(
            (user) => user['id'].toString() == value,
          );
          setState(() {
            selectedUserId = value; // Update the selected user ID
          });
          widget.onUserSelected(selectedUser); // Trigger the callback
        }
      },
      initialValue: selectedUserId, // Bind the selected user ID
    );
  }
}
