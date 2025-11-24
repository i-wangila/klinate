import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/video_call_screen.dart';

class CallService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initiate a call
  static Future<void> initiateCall({
    required BuildContext context,
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    required bool isVideoCall,
  }) async {
    final callId =
        '${callerId}_${calleeId}_${DateTime.now().millisecondsSinceEpoch}';

    // Navigate to call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          callId: callId,
          callerId: callerId,
          calleeId: calleeId,
          callerName: callerName,
          calleeName: calleeName,
          isOutgoing: true,
          isVideoCall: isVideoCall,
        ),
      ),
    );
  }

  // Listen for incoming calls
  static Stream<QuerySnapshot> listenForIncomingCalls(String userId) {
    return _firestore
        .collection('calls')
        .where('calleeId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .snapshots();
  }

  // Show incoming call dialog
  static void showIncomingCallDialog({
    required BuildContext context,
    required String callId,
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    required bool isVideoCall,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Incoming ${isVideoCall ? 'Video' : 'Voice'} Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                callerName[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              callerName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'is calling you...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Reject call
              await _firestore.collection('calls').doc(callId).update({
                'status': 'rejected',
                'rejectedAt': FieldValue.serverTimestamp(),
              });
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Accept call
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallScreen(
                    callId: callId,
                    callerId: callerId,
                    calleeId: calleeId,
                    callerName: callerName,
                    calleeName: calleeName,
                    isOutgoing: false,
                    isVideoCall: isVideoCall,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
