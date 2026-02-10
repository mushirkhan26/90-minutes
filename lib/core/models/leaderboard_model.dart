class LeaderboardModel {
  final String employeeId;
  final String employeeName;
  final int rank;
  final int totalPoints;
  final int tasksCompleted;
  final int subtasksDone;
  final String? profilePic;

  LeaderboardModel({
    required this.employeeId,
    required this.employeeName,
    required this.rank,
    required this.totalPoints,
    required this.tasksCompleted,
    required this.subtasksDone,
    this.profilePic,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: (json['user'] ?? json['employeeName'])?.toString() ?? 'Unknown',
      rank: json['rank'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      tasksCompleted: json['completedTasks'] ?? json['tasksCompleted'] ?? 0,
      subtasksDone: json['completedSubtasks'] ?? json['subtasksDone'] ?? 0,
      profilePic: json['avatar'] ?? json['profilePic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'rank': rank,
      'totalPoints': totalPoints,
      'tasksCompleted': tasksCompleted,
      'subtasksDone': subtasksDone,
      'profilePic': profilePic,
    };
  }
}

class UserStatsModel {
  final int rank;
  final String percentile;
  final int totalPoints;
  final int tasksCompleted;
  final int subtasksDone;
  final int toNextRank;
  final int nextRank;

  UserStatsModel({
    required this.rank,
    required this.percentile,
    required this.totalPoints,
    required this.tasksCompleted,
    required this.subtasksDone,
    required this.toNextRank,
    required this.nextRank,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    // API returns nested objects: stats and progression
    final stats = json['stats'] ?? {};
    final progression = json['progression'] ?? {};
    
    return UserStatsModel(
      rank: stats['currentRank'] ?? 0,
      percentile: "${stats['percentile'] ?? 0}%",
      totalPoints: stats['totalPoints'] ?? 0,
      tasksCompleted: stats['completedTasks'] ?? 0,
      subtasksDone: stats['completedSubtasks'] ?? 0,
      toNextRank: progression['pointsToNextRank'] ?? 0,
      nextRank: progression['nextRank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'percentile': percentile,
      'totalPoints': totalPoints,
      'tasksCompleted': tasksCompleted,
      'subtasksDone': subtasksDone,
      'toNextRank': toNextRank,
      'nextRank': nextRank,
    };
  }
}
