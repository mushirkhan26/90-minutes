import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/leaderboard/provider/leaderboard_provider.dart';
import 'package:provider/provider.dart';

class AdminLeaderboardScreen extends StatefulWidget {
  const AdminLeaderboardScreen({super.key});

  @override
  State<AdminLeaderboardScreen> createState() => _AdminLeaderboardScreenState();
}

class _AdminLeaderboardScreenState extends State<AdminLeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    final stats = provider.userStats;
    final leaderboardList = provider.leaderboard;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Team Leaderboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => provider.refreshData(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: provider.state == LeaderboardState.loading && leaderboardList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.refreshData(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// 🏆 Top Header Banner
                    _buildHeaderBanner(provider),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ⚡ Your Performance Section
                          _buildYourPerformance(stats),

                          const SizedBox(height: 16),

                          /// 📊 Key Metrics Row
                          Row(
                            children: [
                              _buildMiniStatCard("${leaderboardList.length}", "Active Contributors", Icons.people_outline, Colors.teal),
                              const SizedBox(width: 8),
                              _buildMiniStatCard("${stats?.tasksCompleted ?? 0}", "Tasks Completed", Icons.check_circle_outline, Colors.green),
                              const SizedBox(width: 8),
                              _buildMiniStatCard("${stats?.subtasksDone ?? 0}", "Subtasks Done", Icons.adjust, Colors.blue),
                              const SizedBox(width: 8),
                              _buildMiniStatCard("${stats?.totalPoints ?? 0}", "Total Points", Icons.star_border, Colors.amber),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// 🎖️ Top Performers Section (Podium)
                          if (leaderboardList.isNotEmpty)
                            _buildTopPerformersSection(leaderboardList),

                          const SizedBox(height: 20),

                          /// 📜 Full Rankings List
                          _buildFullRankingsSection(leaderboardList),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderBanner(LeaderboardProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Performance Leaderboard",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Track team achievements",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: ['week', 'month', 'all'].map((t) {
                bool isSel = provider.filterType == t;
                String label = t == 'all' ? 'All Time' : t[0].toUpperCase() + t.substring(1);
                return GestureDetector(
                  onTap: () => provider.setFilter(t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF14B8A6) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSel ? Colors.white : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildYourPerformance(stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: Colors.teal, size: 20),
                  SizedBox(width: 8),
                  Text("Your Performance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF14B8A6), borderRadius: BorderRadius.circular(20)),
                child: Text("Rank #${stats?.rank ?? '--'}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPerformanceItem("Total Points", "${stats?.totalPoints ?? 0}", "T: ${stats?.tasksCompleted ?? 0} | S: ${stats?.subtasksDone ?? 0}"),
              _buildPerformanceItem("Percentile", stats?.percentile ?? "Top --%", "Of team users"),
              _buildPerformanceItem("Completed", "${stats?.tasksCompleted ?? 0}", "${stats?.tasksCompleted ?? 0}T | ${stats?.subtasksDone ?? 0}S"),
              _buildPerformanceItem("To Next Rank", "${stats?.toNextRank ?? 0}", "for #${stats?.nextRank ?? '--'}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
      ],
    );
  }

  Widget _buildMiniStatCard(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformersSection(List<dynamic> list) {
    final top3 = list.take(3).toList();
    while (top3.length < 3) {
      top3.add(null);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF14B8A6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text("Top Performers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (top3.length > 1 && top3[1] != null)
                _buildPodiumUser(top3[1].employeeName, "${top3[1].totalPoints}", "${top3[1].tasksCompleted} items", top3[1].employeeName[0], Colors.grey[300]!, 2),
              if (top3.isNotEmpty && top3[0] != null)
                _buildPodiumUser(top3[0].employeeName, "${top3[0].totalPoints}", "${top3[0].tasksCompleted} items", top3[0].employeeName[0], Colors.amber[400]!, 1),
              if (top3.length > 2 && top3[2] != null)
                _buildPodiumUser(top3[2].employeeName, "${top3[2].totalPoints}", "${top3[2].tasksCompleted} items", top3[2].employeeName[0], Colors.orange[300]!, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(String name, String pts, String items, String init, Color medalColor, int rank) {
    double avatarSize = rank == 1 ? 70 : 60;
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: (avatarSize - 4) / 2,
                backgroundColor: const Color(0xFFFACC15),
                child: Text(init, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
            ),
            Positioned(
              top: -15,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: Icon(Icons.military_tech, size: 16, color: rank == 1 ? Colors.white : Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 80,
          child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 4),
                  Text(pts, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Text(items, style: const TextStyle(color: Colors.white70, fontSize: 9)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullRankingsSection(List<dynamic> list) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Text("Full Rankings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            const Center(child: Text("No rankings available"))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = list[index];
                Color medalColor = Colors.grey[400]!;
                if (index == 0) medalColor = Colors.amber[400]!;
                else if (index == 1) medalColor = Colors.grey[300]!;
                else if (index == 2) medalColor = Colors.orange[300]!;
                
                return _buildRankingTile(index + 1, item.employeeName[0], item.employeeName, "${item.totalPoints}", medalColor, item.tasksCompleted, item.subtasksDone);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRankingTile(int rank, String init, String name, String pts, Color medalColor, int t, int s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle),
            child: const Icon(Icons.military_tech, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.teal[400],
            child: Text(init, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 12),
                    const SizedBox(width: 2),
                    Text("${t}T", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(width: 8),
                    const Icon(Icons.adjust, color: Colors.blue, size: 12),
                    const SizedBox(width: 2),
                    Text("${s}S", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(pts, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const Text("points", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}
