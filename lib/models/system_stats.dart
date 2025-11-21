class DailyStats {
  final DateTime date;
  final int newUsers;
  final int newProviders;
  final int appointments;
  final int reviews;

  DailyStats({
    required this.date,
    this.newUsers = 0,
    this.newProviders = 0,
    this.appointments = 0,
    this.reviews = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'newUsers': newUsers,
      'newProviders': newProviders,
      'appointments': appointments,
      'reviews': reviews,
    };
  }

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date']),
      newUsers: json['newUsers'] ?? 0,
      newProviders: json['newProviders'] ?? 0,
      appointments: json['appointments'] ?? 0,
      reviews: json['reviews'] ?? 0,
    );
  }
}

class SystemStats {
  final int totalUsers;
  final int totalPatients;
  final int totalProviders;
  final int activeProviders;
  final int approvedProviders;
  final int pendingProviders;
  final int rejectedProviders;
  final int suspendedProviders;
  final int totalAppointments;
  final int todayAppointments;
  final int totalReviews;
  final DateTime lastUpdated;
  final Map<String, int> providersByType;
  final Map<String, int> appointmentsByStatus;
  final List<DailyStats> dailyStats;

  SystemStats({
    this.totalUsers = 0,
    this.totalPatients = 0,
    this.totalProviders = 0,
    this.activeProviders = 0,
    this.approvedProviders = 0,
    this.pendingProviders = 0,
    this.rejectedProviders = 0,
    this.suspendedProviders = 0,
    this.totalAppointments = 0,
    this.todayAppointments = 0,
    this.totalReviews = 0,
    DateTime? lastUpdated,
    Map<String, int>? providersByType,
    Map<String, int>? appointmentsByStatus,
    List<DailyStats>? dailyStats,
  }) : lastUpdated = lastUpdated ?? DateTime.now(),
       providersByType = providersByType ?? {},
       appointmentsByStatus = appointmentsByStatus ?? {},
       dailyStats = dailyStats ?? [];

  double get averageRating {
    if (totalReviews == 0) return 0.0;
    // This would be calculated from actual review data
    return 4.5; // Placeholder
  }

  int get totalAdmins {
    // This would be calculated from actual admin data
    return 1; // Placeholder
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalPatients': totalPatients,
      'totalProviders': totalProviders,
      'activeProviders': activeProviders,
      'approvedProviders': approvedProviders,
      'pendingProviders': pendingProviders,
      'rejectedProviders': rejectedProviders,
      'suspendedProviders': suspendedProviders,
      'totalAppointments': totalAppointments,
      'todayAppointments': todayAppointments,
      'totalReviews': totalReviews,
      'lastUpdated': lastUpdated.toIso8601String(),
      'providersByType': providersByType,
      'appointmentsByStatus': appointmentsByStatus,
      'dailyStats': dailyStats.map((s) => s.toJson()).toList(),
    };
  }

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalPatients: json['totalPatients'] ?? 0,
      totalProviders: json['totalProviders'] ?? 0,
      activeProviders: json['activeProviders'] ?? 0,
      approvedProviders: json['approvedProviders'] ?? 0,
      pendingProviders: json['pendingProviders'] ?? 0,
      rejectedProviders: json['rejectedProviders'] ?? 0,
      suspendedProviders: json['suspendedProviders'] ?? 0,
      totalAppointments: json['totalAppointments'] ?? 0,
      todayAppointments: json['todayAppointments'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
      providersByType: Map<String, int>.from(json['providersByType'] ?? {}),
      appointmentsByStatus: Map<String, int>.from(
        json['appointmentsByStatus'] ?? {},
      ),
      dailyStats:
          (json['dailyStats'] as List?)
              ?.map((s) => DailyStats.fromJson(s))
              .toList() ??
          [],
    );
  }

  SystemStats copyWith({
    int? totalUsers,
    int? totalPatients,
    int? totalProviders,
    int? activeProviders,
    int? pendingProviders,
    int? rejectedProviders,
    int? suspendedProviders,
    int? totalAppointments,
    int? todayAppointments,
    int? totalReviews,
    DateTime? lastUpdated,
    Map<String, int>? providersByType,
    Map<String, int>? appointmentsByStatus,
    List<DailyStats>? dailyStats,
  }) {
    return SystemStats(
      totalUsers: totalUsers ?? this.totalUsers,
      totalPatients: totalPatients ?? this.totalPatients,
      totalProviders: totalProviders ?? this.totalProviders,
      activeProviders: activeProviders ?? this.activeProviders,
      pendingProviders: pendingProviders ?? this.pendingProviders,
      rejectedProviders: rejectedProviders ?? this.rejectedProviders,
      suspendedProviders: suspendedProviders ?? this.suspendedProviders,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      totalReviews: totalReviews ?? this.totalReviews,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      providersByType: providersByType ?? this.providersByType,
      appointmentsByStatus: appointmentsByStatus ?? this.appointmentsByStatus,
      dailyStats: dailyStats ?? this.dailyStats,
    );
  }
}
