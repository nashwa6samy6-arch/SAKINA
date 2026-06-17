import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/notifications/notifications_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/features/profiles/ui/user_profile_screen.dart';

class Myappbar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showProfile;
  final List<Widget>? actions;

  const Myappbar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showProfile = true,
    this.actions,
  });

  @override
  State<Myappbar> createState() => _MyappbarState();

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}

class _MyappbarState extends State<Myappbar> {
  int _unreadCount = 0;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    _fetchAvatar();
  }

  Future<void> _fetchAvatar() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final row = await Supabase.instance.client
          .from('users')
          .select('avatar_url')
          .eq('user_id', userId)
          .maybeSingle();
      final url = row?['avatar_url']?.toString() ?? '';
      if (mounted) setState(() => _avatarUrl = url);
    } catch (_) {}
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('notification')
          .select('notification_id')
          .eq('user_id', userId)
          .eq('is_read', false);

      if (mounted) {
        setState(() => _unreadCount = (response as List).length);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        user?.email?.split('@')[0] ??
        'User';

    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.appbarColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.showBackButton)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.black, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                if (widget.showProfile)
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserProfileScreen(),
                        ),
                      );
                      _fetchAvatar();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFDDD5C8),
                          ),
                          child: ClipOval(
                            child: _avatarUrl.isNotEmpty
                                ? Image.network(
                                    _avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 28,
                                      color: Color(0xFF9A9088),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 28,
                                    color: Color(0xFF9A9088),
                                  ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (widget.title != null)
                  Text(
                    widget.title!,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
            if (widget.actions != null)
              Row(children: widget.actions!)
            else
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                  _fetchUnreadCount();
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications, size: 28),
                    if (_unreadCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.appbarColor,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _unreadCount > 9 ? '9+' : '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}