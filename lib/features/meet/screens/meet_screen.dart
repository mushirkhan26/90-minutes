import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/meet_model.dart';
import 'package:hrtz_hrms/features/meet/providers/meet_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/navigation/app_routes.dart';
import '../widgets/meet_details_dialog.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

class MeetScreen extends StatefulWidget {
  const MeetScreen({super.key});

  @override
  State<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _currentUserId;
  final ScrollController _timelineScrollController = ScrollController();
  final ScrollController _dateScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetProvider>().fetchUpcomingMeetings();
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    _dateScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    _currentUserId = await SecureStorageService().getEmployeeId();
    if (mounted) setState(() {});
  }

  void _scrollToTime(int hour) {
    if (hour < 9) hour = 9;
    if (hour > 24) hour = 24;

    final int index = hour - 9;
    final double offset = index * 70.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_timelineScrollController.hasClients) {
        _timelineScrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollToSelectedDate() {
    final startDate = DateTime.now().subtract(const Duration(days: 30));
    final difference = _selectedDate.difference(startDate).inDays;
    final double offset =
        (difference * 60.0) - (MediaQuery.of(context).size.width / 2) + 30;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollController.hasClients) {
        _dateScrollController.animateTo(
          offset.clamp(0.0, _dateScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meetProvider = Provider.of<MeetProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(meetProvider),
          _buildDatePicker(),
          Expanded(
            child: meetProvider.state == MeetState.loading
                ? const Center(child: CircularProgressIndicator())
                : _buildMeetingTimeline(meetProvider.meetList),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.pushNamed(AppRoutes.scheduleMeetScreen),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(MeetProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 40, 10, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _showMyCreatedMeetings(provider),
              child: Row(
                children: [
                  const Icon(Icons.groups, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'My Meetings ▾',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${provider.meetList.where((m) {
                            final isCreator = m.createdBy['employeeId'] == _currentUserId;

                            final isParticipant = m.participants.any((p) => p['employeeId'] == _currentUserId);

                            return isCreator || isParticipant;
                          }).length} meetings total',
                          // '${provider.meetList.length} meetings total',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildMonthYearPicker(),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() => _selectedDate = DateTime.now());
                    _scrollToSelectedDate();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMyCreatedMeetings(MeetProvider provider) {
    // final myMeets = provider.meetList
    //     .where((m) => m.createdBy['employeeId'] == _currentUserId)
    //     .toList();
    final myMeets = provider.meetList.where((m) {
      final isCreator = m.createdBy['employeeId'] == _currentUserId;

      final isParticipant = m.participants.any(
        (p) => p['employeeId'] == _currentUserId,
      );

      return isCreator || isParticipant;
    }).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Meetings Created By You",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              if (myMeets.isEmpty)
                const Center(child: Text("No meetings created by you yet."))
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: myMeets.length,
                    itemBuilder: (context, index) {
                      final meet = myMeets[index];
                      final date = DateTime.parse(meet.time).toLocal();
                      return ListTile(
                        leading: const Icon(
                          Icons.event,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          meet.description,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${DateFormat('dd MMM yyyy').format(date)} at ${DateFormat('hh:mm a').format(date)}",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          setState(() => _selectedDate = date);
                          Navigator.pop(context);
                          _scrollToSelectedDate();
                          _scrollToTime(date.hour);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthYearPicker() {
    return PopupMenuButton<DateTime>(
      initialValue: _selectedDate,
      onSelected: (DateTime date) {
        setState(() {
          _selectedDate = DateTime(
            _selectedDate.year,
            date.month,
            _selectedDate.day,
          );
          _scrollToSelectedDate();
        });
      },
      itemBuilder: (context) {
        return List.generate(12, (index) {
          final date = DateTime(_selectedDate.year, index + 1);
          return PopupMenuItem(
            value: date,
            child: Text(DateFormat('MMMM').format(date)),
          );
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final startDate = DateTime.now().subtract(const Duration(days: 30));

    return Container(
      height: 90,
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () {
              _dateScrollController.animateTo(
                _dateScrollController.offset - 120,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              controller: _dateScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 365,
              itemBuilder: (context, index) {
                final date = startDate.add(Duration(days: index));
                bool isSelected =
                    date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _scrollToSelectedDate();
                  },
                  child: Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: isSelected
                        ? const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          )
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.grey,
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: isSelected
                              ? const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                )
                              : null,
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () {
              _dateScrollController.animateTo(
                _dateScrollController.offset + 120,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  // ✅ Updated logic to handle Recurrence (Daily/Weekly) in UI
  Widget _buildMeetingTimeline(List<Meet> meets) {
    if (_currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter meetings to only those created by current user
    // final userMeets = meets.where((m) {
    //   return m.createdBy['employeeId'] == _currentUserId;
    // }).toList();
    final userMeets = meets.where((m) {
      final isCreator = m.createdBy['employeeId'] == _currentUserId;

      final isParticipant = m.participants.any(
        (p) => p['employeeId'] == _currentUserId,
      );

      return isCreator || isParticipant;
    }).toList();

    final dailyMeets = userMeets.where((m) {
      final mDate = DateTime.parse(m.time).toLocal();
      final String recurrence = m.recurrence ?? "One-time meeting";

      // Basic check: Is the meeting on the selected date?
      bool isSameDay =
          mDate.day == _selectedDate.day &&
          mDate.month == _selectedDate.month &&
          mDate.year == _selectedDate.year;

      if (isSameDay) return true;

      // Handle Daily: Show if selected date is after meeting start date
      if (recurrence == "Daily") {
        return _selectedDate.isAfter(mDate);
      }

      // Handle Weekly: Show if selected date is after start date AND same day of week
      if (recurrence == "Weekly") {
        return _selectedDate.isAfter(mDate) &&
            _selectedDate.weekday == mDate.weekday;
      }

      return false;
    }).toList();

    return ListView.builder(
      controller: _timelineScrollController,
      itemCount: 16,
      itemBuilder: (context, index) {
        int hour = 9 + index;
        String timeStr;

        if (hour < 12) {
          timeStr = '$hour AM';
          // ignore: curly_braces_in_flow_control_structures
        } else if (hour == 12)
          timeStr = '12 PM';
        // ignore: curly_braces_in_flow_control_structures
        else if (hour < 24)
          timeStr = '${hour - 12} PM';
        // ignore: curly_braces_in_flow_control_structures
        else
          timeStr = '12 AM';

        final hourMeets = dailyMeets
            .where((m) => DateTime.parse(m.time).toLocal().hour == hour)
            .toList();

        return Container(
          height: 70,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  timeStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: hourMeets
                        .map((m) => _buildMeetingBlock(m))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeetingBlock(Meet meeting) {
    final startTime = DateFormat(
      'hh:mm a',
    ).format(DateTime.parse(meeting.time).toLocal());
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => MeetDetailsDialog(meeting: meeting),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        padding: const EdgeInsets.all(8),
        width: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFFF4081),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              meeting.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$startTime - ${meeting.duration}m',
              style: const TextStyle(color: Colors.white70, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }
}
