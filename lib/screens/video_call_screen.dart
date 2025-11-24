import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/webrtc_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final String callerId;
  final String calleeId;
  final String callerName;
  final String calleeName;
  final bool isOutgoing;
  final bool isVideoCall;

  const VideoCallScreen({
    super.key,
    required this.callId,
    required this.callerId,
    required this.calleeId,
    required this.callerName,
    required this.calleeName,
    required this.isOutgoing,
    this.isVideoCall = true,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  bool _isCallConnected = false;
  bool _isCallEnded = false;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    // Request permissions
    await _requestPermissions();

    // Keep screen awake during call
    WakelockPlus.enable();

    // Initialize renderers
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // Initialize local stream
    final localStream = await WebRTCService.initializeLocalStream(
      video: widget.isVideoCall,
      audio: true,
    );

    if (localStream != null) {
      setState(() {
        _localRenderer.srcObject = localStream;
      });
    }

    if (widget.isOutgoing) {
      await _makeCall();
    } else {
      await _answerCall();
    }

    _listenForRemoteStream();
  }

  Future<void> _requestPermissions() async {
    final permissions = [Permission.camera, Permission.microphone];

    await permissions.request();
  }

  Future<void> _makeCall() async {
    // Create call document
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .set({
          'callerId': widget.callerId,
          'callerName': widget.callerName,
          'calleeId': widget.calleeId,
          'calleeName': widget.calleeName,
          'isVideoCall': widget.isVideoCall,
          'status': 'ringing',
          'createdAt': FieldValue.serverTimestamp(),
        });

    // Create offer
    final offer = await WebRTCService.createOffer(widget.callId);

    if (offer != null) {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.callId)
          .update({'offer': offer});
    }

    // Listen for answer
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            if (data?['answer'] != null && !_isCallConnected) {
              WebRTCService.setRemoteDescription(data!['answer']);
              setState(() {
                _isCallConnected = true;
              });
            }
            if (data?['status'] == 'ended') {
              _endCall();
            }
          }
        });

    // Listen for ICE candidates from callee
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .collection('calleeCandidates')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              WebRTCService.addIceCandidate(change.doc.data()!);
            }
          }
        });
  }

  Future<void> _answerCall() async {
    // Get call data
    final callDoc = await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .get();

    if (!callDoc.exists) return;

    final callData = callDoc.data()!;
    final offer = callData['offer'];

    if (offer != null) {
      // Create answer
      final answer = await WebRTCService.createAnswer(widget.callId, offer);

      if (answer != null) {
        await FirebaseFirestore.instance
            .collection('calls')
            .doc(widget.callId)
            .update({'answer': answer, 'status': 'connected'});

        setState(() {
          _isCallConnected = true;
        });
      }
    }

    // Listen for ICE candidates from caller
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .collection('callerCandidates')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              WebRTCService.addIceCandidate(change.doc.data()!);
            }
          }
        });

    // Listen for call end
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            if (data?['status'] == 'ended') {
              _endCall();
            }
          }
        });
  }

  void _listenForRemoteStream() {
    // Poll for remote stream
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _isCallEnded) return;

      final remoteStream = WebRTCService.remoteStream;
      if (remoteStream != null && _remoteRenderer.srcObject == null) {
        setState(() {
          _remoteRenderer.srcObject = remoteStream;
        });
      } else {
        _listenForRemoteStream();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      WebRTCService.toggleMicrophone(!_isMuted);
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
      WebRTCService.toggleVideo(_isVideoEnabled);
    });
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    await WebRTCService.toggleCamera();
  }

  Future<void> _endCall() async {
    if (_isCallEnded) return;

    // Set flag immediately to prevent multiple calls
    setState(() {
      _isCallEnded = true;
    });

    // Update Firestore in background (don't wait)
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .update({'status': 'ended', 'endedAt': FieldValue.serverTimestamp()})
        .catchError((e) => debugPrint('Error updating call status: $e'));

    // Clean up resources
    try {
      await WebRTCService.dispose();
    } catch (e) {
      debugPrint('Error disposing WebRTC: $e');
    }

    try {
      await _localRenderer.dispose();
    } catch (e) {
      debugPrint('Error disposing local renderer: $e');
    }

    try {
      await _remoteRenderer.dispose();
    } catch (e) {
      debugPrint('Error disposing remote renderer: $e');
    }

    try {
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('Error disabling wakelock: $e');
    }

    // Navigate back immediately
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    if (!_isCallEnded) {
      // Clean up without async operations in dispose
      WebRTCService.dispose();
      _localRenderer.dispose();
      _remoteRenderer.dispose();
      WakelockPlus.disable();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _endCall();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Remote video (full screen)
              if (widget.isVideoCall)
                Positioned.fill(
                  child: _remoteRenderer.srcObject != null
                      ? RTCVideoView(_remoteRenderer, mirror: false)
                      : Container(
                          color: Colors.grey[900],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[700],
                                  child: Text(
                                    widget.isOutgoing
                                        ? widget.calleeName[0].toUpperCase()
                                        : widget.callerName[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  widget.isOutgoing
                                      ? widget.calleeName
                                      : widget.callerName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _isCallConnected
                                      ? 'Connected'
                                      : 'Connecting...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),

              // Local video (small preview)
              if (widget.isVideoCall && _localRenderer.srcObject != null)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: RTCVideoView(_localRenderer, mirror: true),
                    ),
                  ),
                ),

              // Controls
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute button
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      onPressed: _toggleMute,
                      color: _isMuted ? Colors.red : Colors.white,
                    ),

                    // Video toggle (only for video calls)
                    if (widget.isVideoCall)
                      _buildControlButton(
                        icon: _isVideoEnabled
                            ? Icons.videocam
                            : Icons.videocam_off,
                        onPressed: _toggleVideo,
                        color: _isVideoEnabled ? Colors.white : Colors.red,
                      ),

                    // End call button
                    _buildControlButton(
                      icon: Icons.call_end,
                      onPressed: _endCall,
                      color: Colors.red,
                      size: 60,
                    ),

                    // Switch camera (only for video calls)
                    if (widget.isVideoCall)
                      _buildControlButton(
                        icon: Icons.flip_camera_ios,
                        onPressed: _switchCamera,
                        color: Colors.white,
                      ),

                    // Speaker button
                    _buildControlButton(
                      icon: Icons.volume_up,
                      onPressed: () {},
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              // Call info
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.isVideoCall ? Icons.videocam : Icons.call,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCallConnected ? 'Connected' : 'Connecting...',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double size = 50,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: size * 0.5),
        ),
      ),
    );
  }
}
