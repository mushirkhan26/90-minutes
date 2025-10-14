import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/core/constants/app_constants.dart';

import '../../../config/navigation/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/utils.dart';

class MeetScreen extends StatefulWidget {
  const MeetScreen({super.key});

  @override
  State<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upcoming Meetings', style: AppTextStyles.black16_700),
        ),
        // body: meetingManagement.isLoading
        //     ? const ShimmerList(itemCount: 10)
        //     : meetingManagement.error != null
        //     ? Center(child: Text(meetingManagement.error!))
        //     : RefreshIndicator(
        //         onRefresh: () => meetingManagement.fetchAllMeetings(),
        //         child: ListView.builder(
        //           itemCount: meetingManagement.meetings.length,
        //           itemBuilder: (context, index) {
        //             final meeting = meetingManagement.meetings[index];
        //             return MeetingTile(
        //               meeting: meeting,
        //               showButtons: meeting.scheduledPerson.email == email,
        //             );
        //           },
        //         ),
        //       ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(12),
            // optional rounded corners
          ),
          child: GestureDetector(
            // height: Utils().height(context) * 0.09,
            // width: Utils().width(context) * 0.24,
            // child: FloatingActionButton(
            onTap: () {
              context.pushNamed(AppRoutes.scheduleMeetScreen);
            },
            child: Image.asset(
              AppConstants.scheduleIcon,
              fit: BoxFit.contain,
              height: Utils().height(context) * 0.09,
              // width: Utils().width(context) * 0.24,
            ),
            // backgroundColor: AppColors.bluePrimary,
            // child: Text(
            //   "Schedule ",
            //   style: AppTextStyles.white8_600.copyWith(fontSize: 13),
            // ),
            // ),
          ),
        ),
      ),
    );
  }
}
