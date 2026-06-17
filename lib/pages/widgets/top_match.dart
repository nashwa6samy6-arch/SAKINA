import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:sakina/features/home/bloc/home_bloc.dart';
import 'package:sakina/features/ai_match/screens/ai_match_screen.dart';
import 'package:sakina/features/profiles/ui/roommate_request_screen.dart';

class TopMatch extends StatelessWidget {
  final List<TenantMatch> matches;
  const TopMatch({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.themeColor,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Matches',
                style: TextStyle(
                  color: const Color(0xFF120A00),
                  fontSize: 24.sp,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  letterSpacing: -0.60,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiMatchScreen()),
                ),
                child: Text(
                  'SEE ALL',
                  style: TextStyle(
                    color: const Color(0xFF4C463C),
                    fontSize: 12.sp,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    letterSpacing: 1.20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _TopMatchCard(match: matches.first),
        ],
      ),
    );
  }
}

class _TopMatchCard extends StatelessWidget {
  final TenantMatch match;
  const _TopMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBeig,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7E0B6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  match.university?.isNotEmpty == true
                      ? match.university!.toUpperCase()
                      : 'SAKINA MATCH',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7A6F65),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${match.matchScore}% MATCH',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF7E0B6),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 44.r,
                backgroundColor: const Color(0xFFD8D0C0),
                backgroundImage: match.avatarUrl?.isNotEmpty == true
                    ? NetworkImage(match.avatarUrl!)
                    : null,
                child: match.avatarUrl == null || match.avatarUrl!.isEmpty
                    ? Icon(Icons.person, size: 40.r, color: Colors.white54)
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    if (match.tags.isNotEmpty)
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: match.tags.map(_buildTag).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Text(
            match.bio?.isNotEmpty == true ? match.bio! : 'No bio added yet.',
            style: TextStyle(
              color: const Color(0xFF4C463C),
              fontSize: 14.sp,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
              height: 1.63,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoommateRequestScreen(
                    userId: match.userId,
                    matchPercentage: '${match.matchScore}%',
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C1C1C),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('View Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                          letterSpacing: 0.35)),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, size: 16.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE8E5),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEAE8E5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF4C463C),
          fontSize: 10.sp,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w400,
          height: 1.50,
          letterSpacing: 0.50,
        ),
      ),
    );
  }
}