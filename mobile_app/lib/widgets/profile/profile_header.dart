import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Profile Header Widget
/// Shows user avatar, name, and UUID
class ProfileHeader extends StatelessWidget {
  final String userName;
  final String? userUUID;
  final VoidCallback? onEdit;

  const ProfileHeader({
    Key? key,
    required this.userName,
    this.userUUID,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initials = userName
        .split(' ')
        .map((str) => str[0])
        .join()
        .toUpperCase()
        .substring(0, 2);

    return Container(
      padding: EdgeInsets.all(ThemeConfig.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConfig.primaryColor,
            ThemeConfig.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMd),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ThemeConfig.lg),
              // Name and UUID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (userUUID != null) ...[
                      SizedBox(height: ThemeConfig.xs),
                      Text(
                        'ID: ${userUUID!.substring(0, 8)}...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: Colors.white),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
