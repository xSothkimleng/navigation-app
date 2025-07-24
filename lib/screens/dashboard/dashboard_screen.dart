import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentStep = 0;

  // Sample recent activities data
  final List<RecentActivity> recentActivities = [
    RecentActivity(
      userName: 'John',
      action: 'created',
      activityType: 'Email',
      timestamp: '7/24/2025, 2:30:15 PM',
      description:
          'Sent follow-up email to prospect regarding pricing inquiry. Included detailed proposal and timeline for implementation.',
      avatarColor: Colors.blue,
      isCompleted: true,
    ),
    RecentActivity(
      userName: 'Sarah',
      action: 'updated',
      activityType: 'Opportunity',
      timestamp: '7/24/2025, 1:45:22 PM',
      description:
          'Updated opportunity stage to "Proposal Sent". Client showed strong interest in our premium package.',
      avatarColor: Colors.green,
      isCompleted: true,
    ),
    RecentActivity(
      userName: 'Mike',
      action: 'scheduled',
      activityType: 'Call',
      timestamp: '7/24/2025, 11:20:08 AM',
      description:
          'Scheduled follow-up call with decision maker for next Tuesday. Need to prepare technical presentation.',
      avatarColor: Colors.orange,
      isCompleted: true,
    ),
    RecentActivity(
      userName: 'Lisa',
      action: 'created',
      activityType: 'Task',
      timestamp: '7/24/2025, 9:15:45 AM',
      description:
          'Created task to prepare contract documents for the Johnson Industries deal. Deadline: End of week.',
      avatarColor: Colors.purple,
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActivitiesStepper(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesStepper() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentActivities.length,
      itemBuilder: (context, index) {
        final activity = recentActivities[index];
        final bool isLast = index == recentActivities.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline column
              Column(
                children: [
                  // Circle indicator
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getActivityIcon(activity.activityType),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  // Connecting line (if not last item)
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              // Content column
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: _buildActivityCard(activity),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(RecentActivity activity) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and timestamp
            Row(
              children: [
                // User avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: activity.avatarColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      activity.userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User name and action in one line
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text: activity.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' ${activity.action} ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: activity.activityType,
                              style: TextStyle(
                                color: activity.avatarColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Timestamp
                      Text(
                        activity.timestamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Activity description
            Text(
              activity.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'call':
        return Icons.phone;
      case 'opportunity':
        return Icons.business_center;
      case 'task':
        return Icons.task_alt;
      case 'meeting':
        return Icons.event;
      case 'note':
        return Icons.note;
      default:
        return Icons.circle;
    }
  }
}

// Data model for recent activities
class RecentActivity {
  final String userName;
  final String action;
  final String activityType;
  final String timestamp;
  final String description;
  final Color avatarColor;
  final bool isCompleted;

  RecentActivity({
    required this.userName,
    required this.action,
    required this.activityType,
    required this.timestamp,
    required this.description,
    required this.avatarColor,
    required this.isCompleted,
  });
}
