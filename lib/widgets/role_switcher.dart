import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

class RoleSwitcher extends StatelessWidget {
  final Function(UserRole) onRoleChanged;

  const RoleSwitcher({super.key, required this.onRoleChanged});

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;

    if (user == null || !user.hasMultipleRoles) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<UserRole>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getRoleIcon(user.currentRole),
              size: 20,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 8),
            Text(
              user.currentRole.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.blue[700]),
          ],
        ),
      ),
      itemBuilder: (context) {
        return user.roles.map((role) {
          final isCurrentRole = role == user.currentRole;
          return PopupMenuItem<UserRole>(
            value: role,
            child: Row(
              children: [
                Icon(
                  _getRoleIcon(role),
                  size: 20,
                  color: isCurrentRole ? Colors.blue[700] : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Text(
                  role.displayName,
                  style: TextStyle(
                    fontWeight: isCurrentRole
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isCurrentRole ? Colors.blue[700] : Colors.black,
                  ),
                ),
                if (isCurrentRole) ...[
                  const Spacer(),
                  Icon(Icons.check, size: 18, color: Colors.blue[700]),
                ],
              ],
            ),
          );
        }).toList();
      },
      onSelected: (role) async {
        if (role != user.currentRole) {
          final success = await UserService.switchRole(role);
          if (success) {
            onRoleChanged(role);
          }
        }
      },
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return Icons.person;
      case UserRole.doctor:
        return Icons.medical_services;
      case UserRole.nurse:
        return Icons.healing;
      case UserRole.therapist:
        return Icons.psychology;
      case UserRole.nutritionist:
        return Icons.restaurant;
      case UserRole.homecare:
        return Icons.home_work;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}
