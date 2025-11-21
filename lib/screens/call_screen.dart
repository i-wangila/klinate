import 'package:flutter/material.dart';
import 'dart:async';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final CallSession callSession;

  const CallScreen({super.key, required this.callSession});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late CallSession _currentCall;
  Timer? _durationTimer;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;

  @override
  void initState() {
    super.initState();
    _currentCall = widget.callSession;
    _startDurationTimer();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Update duration display
        });
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildCallHeader(),
            Expanded(child: _buildCallContent()),
            _buildCallControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCallHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            _currentCall.status == CallStatus.connecting
                ? 'Connecting...'
                : _currentCall.callType == CallType.video
                ? 'Video Call'
                : 'Voice Call',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentCall.providerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentCall.status == CallStatus.connected
                ? _currentCall.formattedDuration
                : 'Healthcare Provider',
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCallContent() {
    if (_currentCall.callType == CallType.video) {
      return _buildVideoCallContent();
    } else {
      return _buildVoiceCallContent();
    }
  }

  Widget _buildVideoCallContent() {
    return Stack(
      children: [
        // Main video (provider's video)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isVideoEnabled
              ? _buildVideoPlaceholder('Provider Video', Colors.blue[700]!)
              : _buildAvatarPlaceholder(_currentCall.providerName),
        ),
        // Small video (user's video)
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: _buildVideoPlaceholder('You', Colors.green[700]!),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceCallContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: Colors.blue[700],
            child: Text(
              _getInitials(_currentCall.providerName),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isMuted ? 'Muted' : 'Unmuted',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.8), color],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              color: Colors.white.withValues(alpha: 0.7),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.blue[700],
        child: Text(
          _getInitials(name),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            color: _isMuted ? Colors.red : Colors.grey[700]!,
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
          ),

          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            color: Colors.red,
            size: 60,
            onPressed: _endCall,
          ),

          // Video/Speaker button
          if (_currentCall.callType == CallType.video)
            _buildControlButton(
              icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              color: _isVideoEnabled ? Colors.grey[700]! : Colors.red,
              onPressed: () {
                setState(() {
                  _isVideoEnabled = !_isVideoEnabled;
                });
              },
            )
          else
            _buildControlButton(
              icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              color: _isSpeakerOn ? Colors.blue : Colors.grey[700]!,
              onPressed: () {
                setState(() {
                  _isSpeakerOn = !_isSpeakerOn;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: size * 0.4),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return parts[0][0].toUpperCase();
    }
  }

  void _endCall() {
    CallService.endCall(_currentCall.callId);
    Navigator.of(context).pop();
  }
}
