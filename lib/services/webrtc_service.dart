import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebRTCService {
  static RTCPeerConnection? _peerConnection;
  static MediaStream? _localStream;
  static MediaStream? _remoteStream;

  static final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
  };

  // Initialize local media stream
  static Future<MediaStream?> initializeLocalStream({
    bool video = true,
    bool audio = true,
  }) async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': audio,
        'video': video
            ? {
                'facingMode': 'user',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
              }
            : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );
      return _localStream;
    } catch (e) {
      debugPrint('Error initializing local stream: $e');
      return null;
    }
  }

  // Create peer connection
  static Future<RTCPeerConnection?> initPeerConnection() async {
    try {
      _peerConnection = await createPeerConnection(_configuration);
      return _peerConnection;
    } catch (e) {
      debugPrint('Error creating peer connection: $e');
      return null;
    }
  }

  // Create offer for outgoing call
  static Future<Map<String, dynamic>?> createOffer(String callId) async {
    try {
      if (_peerConnection == null) {
        await initPeerConnection();
      }

      // Add local stream tracks
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
      }

      // Listen for remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
        }
      };

      // Listen for ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        FirebaseFirestore.instance
            .collection('calls')
            .doc(callId)
            .collection('callerCandidates')
            .add(candidate.toMap());
      };

      // Create offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      return offer.toMap();
    } catch (e) {
      debugPrint('Error creating offer: $e');
      return null;
    }
  }

  // Create answer for incoming call
  static Future<Map<String, dynamic>?> createAnswer(
    String callId,
    Map<String, dynamic> offerData,
  ) async {
    try {
      if (_peerConnection == null) {
        await initPeerConnection();
      }

      // Add local stream tracks
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
      }

      // Listen for remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
        }
      };

      // Listen for ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        FirebaseFirestore.instance
            .collection('calls')
            .doc(callId)
            .collection('calleeCandidates')
            .add(candidate.toMap());
      };

      // Set remote description
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offerData['sdp'], offerData['type']),
      );

      // Create answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      return answer.toMap();
    } catch (e) {
      debugPrint('Error creating answer: $e');
      return null;
    }
  }

  // Set remote description (for caller when answer is received)
  static Future<void> setRemoteDescription(
    Map<String, dynamic> answerData,
  ) async {
    try {
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(answerData['sdp'], answerData['type']),
      );
    } catch (e) {
      debugPrint('Error setting remote description: $e');
    }
  }

  // Add ICE candidate
  static Future<void> addIceCandidate(
    Map<String, dynamic> candidateData,
  ) async {
    try {
      RTCIceCandidate candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      );
      await _peerConnection?.addCandidate(candidate);
    } catch (e) {
      debugPrint('Error adding ICE candidate: $e');
    }
  }

  // Toggle camera
  static Future<void> toggleCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().firstWhere(
        (track) => track.kind == 'video',
      );
      await Helper.switchCamera(videoTrack);
    }
  }

  // Toggle microphone
  static void toggleMicrophone(bool enabled) {
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = enabled;
      });
    }
  }

  // Toggle video
  static void toggleVideo(bool enabled) {
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = enabled;
      });
    }
  }

  // Get streams
  static MediaStream? get localStream => _localStream;
  static MediaStream? get remoteStream => _remoteStream;

  // Clean up
  static Future<void> dispose() async {
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
  }
}
