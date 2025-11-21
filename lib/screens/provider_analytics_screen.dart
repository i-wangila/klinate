import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/appointment_service.dart';
import '../services/user_service.dart';
import '../models/appointment.dart';

class ProviderAnalyticsScreen extends StatefulWidget {
  const ProviderAnalyticsScreen({super.key});

  @override
  State<ProviderAnalyticsScreen> createState() =>
      _ProviderAnalyticsScreenState();
}

class _ProviderAnalyticsScreenState extends State<ProviderAnalyticsScreen> {
  String _selectedPeriod = '7 Days';
  bool _isLoading = true;
  StreamSubscription<void>? _appointmentSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Listen to appointment changes and refresh automatically
    _appointmentSubscription = AppointmentService.appointmentChanges.listen((
      _,
    ) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild with updated data
        });
      }
    });
  }

  @override
  void dispose() {
    _appointmentSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await AppointmentService.loadAppointments();
    setState(() => _isLoading = false);
  }

  // Get real appointment data
  Map<String, dynamic> get _analyticsData {
    final currentUser = UserService.currentUser;
    if (currentUser == null) return _getStaticData();

    // Get appointments excluding those where patient is also a provider
    final allAppointments =
        AppointmentService.getPatientAppointmentsForProvider(currentUser.email);

    final now = DateTime.now();
    final startDate = _selectedPeriod == '7 Days'
        ? now.subtract(const Duration(days: 7))
        : _selectedPeriod == '30 Days'
        ? now.subtract(const Duration(days: 30))
        : now.subtract(const Duration(days: 90));

    final periodAppointments = allAppointments.where((apt) {
      return apt.dateTime.isAfter(startDate);
    }).toList();

    final total = periodAppointments.length;
    final upcoming = periodAppointments
        .where(
          (apt) =>
              apt.status == AppointmentStatus.scheduled &&
              apt.dateTime.isAfter(now),
        )
        .length;
    final completed = periodAppointments
        .where((apt) => apt.status == AppointmentStatus.completed)
        .length;
    final followUp = periodAppointments
        .where((apt) => apt.description.toLowerCase().contains('follow'))
        .length;

    final bookedPercentage = total > 0 ? upcoming / (total + 5) : 0.0;

    return {
      'total': total,
      'upcoming': upcoming,
      'completed': completed,
      'followUp': followUp,
      'bookedPercentage': bookedPercentage,
      'weeklyData': _generateWeeklyData(periodAppointments),
    };
  }

  List<List<double>> _generateWeeklyData(List<Appointment> appointments) {
    if (_selectedPeriod == '7 Days') {
      return List.generate(7, (index) {
        final day = DateTime.now().subtract(Duration(days: 6 - index));
        final dayAppointments = appointments.where((apt) {
          return apt.dateTime.day == day.day &&
              apt.dateTime.month == day.month &&
              apt.dateTime.year == day.year;
        }).toList();

        return [
          dayAppointments
              .where((apt) => apt.status == AppointmentStatus.scheduled)
              .length
              .toDouble(),
          dayAppointments
              .where((apt) => apt.status == AppointmentStatus.completed)
              .length
              .toDouble(),
          dayAppointments
              .where((apt) => apt.status == AppointmentStatus.cancelled)
              .length
              .toDouble(),
        ];
      });
    }
    return [
      [0, 0, 0],
    ];
  }

  // Fallback static data
  Map<String, dynamic> _getStaticData() {
    switch (_selectedPeriod) {
      case '7 Days':
        return {
          'total': 20,
          'upcoming': 5,
          'completed': 10,
          'followUp': 5,
          'bookedPercentage': 0.7,
          'weeklyData': [
            [10, 0, 0], // Monday
            [15, 0, 0], // Tuesday
            [0, 15, 28], // Wednesday
            [0, 0, 8], // Thursday
            [0, 0, 15], // Friday
            [0, 20, 35], // Saturday
            [5, 0, 0], // Sunday
          ],
        };
      case '30 Days':
        return {
          'total': 85,
          'upcoming': 20,
          'completed': 50,
          'followUp': 15,
          'bookedPercentage': 0.85,
          'weeklyData': [
            [15, 5, 10], // Week 1
            [20, 8, 15], // Week 2
            [10, 12, 20], // Week 3
            [5, 10, 25], // Week 4
          ],
        };
      case '90 Days':
        return {
          'total': 250,
          'upcoming': 60,
          'completed': 150,
          'followUp': 40,
          'bookedPercentage': 0.92,
          'weeklyData': [
            [25, 15, 30], // Month 1
            [30, 20, 40], // Month 2
            [35, 25, 50], // Month 3
          ],
        };
      default:
        return {
          'total': 20,
          'upcoming': 5,
          'completed': 10,
          'followUp': 5,
          'bookedPercentage': 0.7,
          'weeklyData': [
            [10, 0, 0],
            [15, 0, 0],
            [0, 15, 28],
            [0, 0, 8],
            [0, 0, 15],
            [0, 20, 35],
            [5, 0, 0],
          ],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Analytics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildBookedAppointmentsCard(),
                    const SizedBox(height: 32),
                    _buildDashboardSection(),
                    const SizedBox(height: 32),
                    _buildAppointmentsAnalytics(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBookedAppointmentsCard() {
    final percentage = _analyticsData['bookedPercentage'];
    final percentageText = '${(percentage * 100).toInt()}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booked Appointments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 0.8 ? Colors.green : Colors.blue,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                percentageText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: percentage > 0.8 ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            DropdownButton<String>(
              value: _selectedPeriod,
              underline: const SizedBox(),
              items: ['7 Days', '30 Days', '90 Days']
                  .map(
                    (period) =>
                        DropdownMenuItem(value: period, child: Text(period)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPeriod = value);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildStatCard(
          icon: Icons.event_note,
          iconColor: Colors.blue,
          label: 'Total Appointments',
          value: '${_analyticsData['total']}',
          onTap: () => _showAppointmentsList('total'),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          icon: Icons.calendar_today,
          iconColor: Colors.red,
          label: 'Upcoming Appointments',
          value: '${_analyticsData['upcoming']}',
          onTap: () => _showAppointmentsList('upcoming'),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          icon: Icons.check_circle,
          iconColor: Colors.green,
          label: 'Completed Appointments',
          value: '${_analyticsData['completed']}',
          onTap: () => _showAppointmentsList('completed'),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          icon: Icons.follow_the_signs,
          iconColor: Colors.orange,
          label: 'Follow-Up Appointments',
          value: '${_analyticsData['followUp']}',
          onTap: () => _showAppointmentsList('followUp'),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Appointments Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              _selectedPeriod,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildLegendItem(Colors.red, 'Upcoming'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.orange, 'Follow-Up'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.green, 'Completed'),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 40,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      List<String> labels;
                      switch (_selectedPeriod) {
                        case '7 Days':
                          labels = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                          break;
                        case '30 Days':
                          labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                          break;
                        case '90 Days':
                          labels = ['Month 1', 'Month 2', 'Month 3'];
                          break;
                        default:
                          labels = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                      }
                      if (value.toInt() >= 0 && value.toInt() < labels.length) {
                        return Text(
                          labels[value.toInt()],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: _getBarGroups(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    final data = _analyticsData['weeklyData'] as List;
    final chartData = data
        .map((item) => (item as List).cast<num>().toList())
        .toList();

    return List.generate(chartData.length, (index) {
      final values = chartData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY:
                values[0].toDouble() +
                values[1].toDouble() +
                values[2].toDouble(),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            rodStackItems: [
              if (values[0] > 0)
                BarChartRodStackItem(0, values[0].toDouble(), Colors.red),
              if (values[1] > 0)
                BarChartRodStackItem(
                  values[0].toDouble(),
                  values[0].toDouble() + values[1].toDouble(),
                  Colors.orange,
                ),
              if (values[2] > 0)
                BarChartRodStackItem(
                  values[0].toDouble() + values[1].toDouble(),
                  values[0].toDouble() +
                      values[1].toDouble() +
                      values[2].toDouble(),
                  Colors.green,
                ),
            ],
          ),
        ],
      );
    });
  }

  // Get filtered appointments based on category
  List<Appointment> _getFilteredAppointments(String category) {
    final currentUser = UserService.currentUser;
    if (currentUser == null) return [];

    // Get appointments excluding those where patient is also a provider
    final allAppointments =
        AppointmentService.getPatientAppointmentsForProvider(currentUser.email);

    final now = DateTime.now();
    final startDate = _selectedPeriod == '7 Days'
        ? now.subtract(const Duration(days: 7))
        : _selectedPeriod == '30 Days'
        ? now.subtract(const Duration(days: 30))
        : now.subtract(const Duration(days: 90));

    final periodAppointments = allAppointments.where((apt) {
      return apt.dateTime.isAfter(startDate);
    }).toList();

    switch (category) {
      case 'total':
        periodAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        return periodAppointments;
      case 'upcoming':
        return periodAppointments
            .where(
              (apt) =>
                  apt.status == AppointmentStatus.scheduled &&
                  apt.dateTime.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      case 'completed':
        return periodAppointments
            .where((apt) => apt.status == AppointmentStatus.completed)
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      case 'followUp':
        return periodAppointments
            .where((apt) => apt.description.toLowerCase().contains('follow'))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      default:
        return [];
    }
  }

  // Show appointments list in a bottom sheet
  void _showAppointmentsList(String category) {
    final appointments = _getFilteredAppointments(category);

    String title;
    switch (category) {
      case 'total':
        title = 'All Appointments';
        break;
      case 'upcoming':
        title = 'Upcoming Appointments';
        break;
      case 'completed':
        title = 'Completed Appointments';
        break;
      case 'followUp':
        title = 'Follow-Up Appointments';
        break;
      default:
        title = 'Appointments';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAFAFA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Text(
                      '${appointments.length} ${appointments.length == 1 ? 'appointment' : 'appointments'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF666666)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: appointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No appointments found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isUpcoming =
        appointment.dateTime.isAfter(DateTime.now()) &&
        appointment.status == AppointmentStatus.scheduled;
    final isCompleted = appointment.status == AppointmentStatus.completed;
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isCancelled) {
      statusColor = Colors.grey;
      statusText = 'Cancelled';
      statusIcon = Icons.cancel;
    } else if (isCompleted) {
      statusColor = Colors.green;
      statusText = 'Completed';
      statusIcon = Icons.check_circle;
    } else if (isUpcoming) {
      statusColor = Colors.blue;
      statusText = 'Upcoming';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.orange;
      statusText = 'Past';
      statusIcon = Icons.history;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.patientName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 15, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                _formatDate(appointment.dateTime),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.access_time, size: 15, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                _formatTime(appointment.dateTime),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _getCommunicationIcon(appointment.communicationType),
                size: 15,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 8),
              Text(
                _getCommunicationLabel(appointment.communicationType),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          if (appointment.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              appointment.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            appointment.amount.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  IconData _getCommunicationIcon(CommunicationType type) {
    switch (type) {
      case CommunicationType.video:
        return Icons.videocam;
      case CommunicationType.voice:
        return Icons.phone;
      case CommunicationType.inPerson:
        return Icons.person;
      case CommunicationType.chat:
        return Icons.chat;
    }
  }

  String _getCommunicationLabel(CommunicationType type) {
    switch (type) {
      case CommunicationType.video:
        return 'Video Call';
      case CommunicationType.voice:
        return 'Voice Call';
      case CommunicationType.inPerson:
        return 'In-Person';
      case CommunicationType.chat:
        return 'Chat';
    }
  }
}
