import 'package:flutter/material.dart';
import '../services/role_policy.dart';
import '../models/user_roles.dart';
import '../services/role_policy.dart';
import '../services/role_store.dart';

import '../services/role_policy.dart';
class RoleDropdown extends StatelessWidget {
  const RoleDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserRole>(
      valueListenable: RoleStore.notifier,
      builder: (context, role, _) {
        return DropdownButton<UserRole>(
          value: role,
          underline: const SizedBox(),
          items: UserRole.values
              .map((r) => DropdownMenuItem(value: r, child: Text(r.short)))
              .toList(),
          onChanged: (r) {
            if (r == null) return;
            final meEmail = RoleStore.currentEmail ?? "inconnu@sja.ca";
            final meRoles = RoleStore.currentRoles ?? <UserRole>{};
            final me = CurrentUser(email: meEmail, roles: meRoles);
            if (!RolePolicy.canSwitchTo(targetRole: r, me: me)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(RolePolicy.reasonForDeny(r))),
              );
              return;
            }
            RoleStore.setRole(r);
          },
        );
      },
    );
  }
}