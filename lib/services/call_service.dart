import 'dart:async';

enum CallType { voice, video }

enum CallStatus { connecting, connected, ended, failed }

class CallService {
  static final Map<String, CallSession> _activeCalls = {};
  static final StreamController<CallSession?> _callStateController =
      StreamController<CallSession?>.broadcast();

  // Get call state stream
  static Stream<CallSession?> get callStateStream =>
      _callStateController.stream;

  // Start a call
  static Future<CallSession> startCall({
    required String providerId,
    required String providerName,
    required CallType callType,
    required String patientId,
    required String patientName,
  }) async {
    final callId = 'call_${DateTime.now().millisecondsSinceEpoch}';

    final callSession = CallSession(
      callId: callId,
      providerId: providerId,
      providerName: providerName,
      patientId: patientId,
      patientName: patientName,
      callType: callType,
      status: CallStatus.connecting,
      startTime: DateTime.now(),
    );

    _activeCalls[callId] = callSession;
    _callStateController.add(callSession);

    // Simulate connection process
    Timer(const Duration(seconds: 3), () {
      if (_activeCalls.containsKey(callId)) {
        _activeCalls[callId] = callSession.copyWith(
          status: CallStatus.connected,
        );
        _callStateController.add(_activeCalls[callId]);
      }
    });

    return callSession;
  }

  // End a call
  static void endCall(String callId) {
    if (_activeCalls.containsKey(callId)) {
      final endedCall = _activeCalls[callId]!.copyWith(
        status: CallStatus.ended,
        endTime: DateTime.now(),
      );
      _activeCalls.remove(callId);
      _callStateController.add(endedCall);
    }
  }

  // Get active call
  static CallSession? getActiveCall() {
    return _activeCalls.values.isNotEmpty ? _activeCalls.values.first : null;
  }

  // Check if there's an active call
  static bool hasActiveCall() {
    return _activeCalls.isNotEmpty;
  }
}

class CallSession {
  final String callId;
  final String providerId;
  final String providerName;
  final String patientId;
  final String patientName;
  final CallType callType;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isMuted;
  final bool isVideoEnabled;

  CallSession({
    required this.callId,
    required this.providerId,
    required this.providerName,
    required this.patientId,
    required this.patientName,
    required this.callType,
    required this.status,
    required this.startTime,
    this.endTime,
    this.isMuted = false,
    this.isVideoEnabled = true,
  });

  CallSession copyWith({
    String? callId,
    String? providerId,
    String? providerName,
    String? patientId,
    String? patientName,
    CallType? callType,
    CallStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    bool? isMuted,
    bool? isVideoEnabled,
  }) {
    return CallSession(
      callId: callId ?? this.callId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
    );
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get formattedDuration {
    final duration = this.duration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
