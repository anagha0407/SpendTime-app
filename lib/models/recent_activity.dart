/// Plain model for a single recent activity entry.
class RecentActivity {
  final String title;
  final String category;
  final Duration duration;
  final String timeAgo; // e.g. "2h ago" — stored as text for now (mock data)

  const RecentActivity({
    required this.title,
    required this.category,
    required this.duration,
    required this.timeAgo,
  });
}