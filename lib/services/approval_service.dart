import 'package:flutter/foundation.dart';
import '../models/provider_profile.dart';
import '../models/user_profile.dart';
import '../models/document.dart';
import '../models/message.dart';
import 'provider_service.dart';
import 'document_service.dart';
import 'audit_service.dart';
import 'user_service.dart';
import 'message_service.dart';

class ApprovalService {
  // Approve provider
  static Future<bool> approveProvider(String providerId, String adminId) async {
    try {
      final provider = ProviderService.getProviderById(providerId);
      if (provider == null) {
        if (kDebugMode) {
          print('Provider not found: $providerId');
        }
        return false;
      }

      // Update provider status to approved
      final success = await ProviderService.updateProviderStatus(
        providerId,
        ProviderStatus.approved,
      );

      if (success) {
        // Add provider role to user so they can access provider dashboard
        final users = UserService.getAllUsers();
        final user = users.firstWhere(
          (u) => u.id == provider.userId,
          orElse: () => throw Exception('User not found'),
        );

        // Add the provider role if they don't have it
        if (!user.hasRole(provider.providerType)) {
          await UserService.addRole(provider.providerType);

          if (kDebugMode) {
            print(
              'Added ${provider.providerType.displayName} role to user ${user.name}',
            );
          }
        }

        // Log the approval action
        await AuditService.logProviderApproval(adminId, providerId);

        // Send approval notification to provider
        await MessageService.addSystemNotification(
          '🎉 Congratulations! Your Business Account Has Been Approved!\n\n'
          'Welcome to Klinate Healthcare Network! Your application has been approved and you can now offer healthcare services online.\n\n'
          '✨ Your Business Account Features:\n\n'
          '📊 Business Dashboard\n'
          '• View your performance metrics and statistics\n'
          '• Track appointments and patient interactions\n'
          '• Monitor your ratings and reviews\n\n'
          '📅 Appointment Management\n'
          '• Receive and manage patient appointments\n'
          '• Set your availability schedule\n'
          '• Accept or decline appointment requests\n\n'
          '👥 Patient Management\n'
          '• View your patient list\n'
          '• Access patient details and history\n'
          '• Communicate directly with patients\n\n'
          '💬 Messaging & Communication\n'
          '• Dedicated provider inbox\n'
          '• Real-time chat with patients\n'
          '• Respond to appointment requests\n\n'
          '📈 Analytics & Reports\n'
          '• Track your performance metrics\n'
          '• View appointment statistics\n'
          '• Monitor patient satisfaction\n\n'
          '⚙️ Account Management\n'
          '• Update your profile and services\n'
          '• Manage your availability\n'
          '• Control notification preferences\n\n'
          'To get started, switch to your Business Dashboard using the role switcher in the navigation bar.\n\n'
          'Thank you for joining Klinate! We look forward to serving patients together.',
          MessageType.system,
        );

        if (kDebugMode) {
          print('Provider approved: $providerId by admin: $adminId');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error approving provider: $e');
      }
      return false;
    }
  }

  // Reject provider
  static Future<bool> rejectProvider(
    String providerId,
    String adminId,
    String reason,
  ) async {
    try {
      final provider = ProviderService.getProviderById(providerId);
      if (provider == null) {
        if (kDebugMode) {
          print('Provider not found: $providerId');
        }
        return false;
      }

      // Update provider status to rejected
      final success = await ProviderService.updateProviderStatus(
        providerId,
        ProviderStatus.rejected,
      );

      if (success) {
        // Remove provider role from user since they were rejected
        final users = UserService.getAllUsers();
        final user = users.firstWhere(
          (u) => u.id == provider.userId,
          orElse: () => throw Exception('User not found'),
        );

        // Remove the provider role if they have it
        if (user.hasRole(provider.providerType)) {
          await UserService.removeRole(provider.providerType);

          if (kDebugMode) {
            print(
              'Removed ${provider.providerType.displayName} role from user ${user.name}',
            );
          }
        }

        // Log the rejection action with reason
        await AuditService.logProviderRejection(adminId, providerId, reason);

        // Send rejection notification to provider
        await MessageService.addSystemNotification(
          '❌ Application Status Update\n\n'
          'We regret to inform you that your application to provide healthcare services on Klinate has not been approved at this time.\n\n'
          'Reason: $reason\n\n'
          'If you believe this was an error or would like to reapply with additional information, please contact our support team.\n\n'
          'Thank you for your interest in joining Klinate.',
          MessageType.system,
        );

        if (kDebugMode) {
          print('Provider rejected: $providerId by admin: $adminId');
          print('Reason: $reason');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error rejecting provider: $e');
      }
      return false;
    }
  }

  // Suspend provider
  static Future<bool> suspendProvider(
    String providerId,
    String adminId,
    String reason,
  ) async {
    try {
      final provider = ProviderService.getProviderById(providerId);
      if (provider == null) {
        if (kDebugMode) {
          print('Provider not found: $providerId');
        }
        return false;
      }

      // Update provider status to suspended
      final success = await ProviderService.updateProviderStatus(
        providerId,
        ProviderStatus.suspended,
      );

      if (success) {
        // Log the suspension action
        await AuditService.logProviderSuspension(adminId, providerId, reason);

        if (kDebugMode) {
          print('Provider suspended: $providerId by admin: $adminId');
          print('Reason: $reason');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error suspending provider: $e');
      }
      return false;
    }
  }

  // Reactivate provider
  static Future<bool> reactivateProvider(
    String providerId,
    String adminId,
  ) async {
    try {
      final provider = ProviderService.getProviderById(providerId);
      if (provider == null) {
        if (kDebugMode) {
          print('Provider not found: $providerId');
        }
        return false;
      }

      // Update provider status to approved
      final success = await ProviderService.updateProviderStatus(
        providerId,
        ProviderStatus.approved,
      );

      if (success) {
        // Log the reactivation action
        await AuditService.logProviderReactivation(adminId, providerId);

        if (kDebugMode) {
          print('Provider reactivated: $providerId by admin: $adminId');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error reactivating provider: $e');
      }
      return false;
    }
  }

  // Approve document
  static Future<bool> approveDocument(String documentId, String adminId) async {
    try {
      final document = DocumentService.getDocumentById(documentId);
      if (document == null) {
        if (kDebugMode) {
          print('Document not found: $documentId');
        }
        return false;
      }

      // Update document status to approved
      final success = await DocumentService.updateDocumentStatus(
        documentId,
        DocumentStatus.approved,
      );

      if (success) {
        // Log the document approval
        await AuditService.logDocumentApproval(adminId, documentId);

        if (kDebugMode) {
          print('Document approved: $documentId by admin: $adminId');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error approving document: $e');
      }
      return false;
    }
  }

  // Reject document
  static Future<bool> rejectDocument(
    String documentId,
    String adminId,
    String reason,
  ) async {
    try {
      final document = DocumentService.getDocumentById(documentId);
      if (document == null) {
        if (kDebugMode) {
          print('Document not found: $documentId');
        }
        return false;
      }

      // Update document status to rejected
      final success = await DocumentService.updateDocumentStatus(
        documentId,
        DocumentStatus.rejected,
        rejectionReason: reason,
      );

      if (success) {
        // Log the document rejection
        await AuditService.logDocumentRejection(adminId, documentId, reason);

        if (kDebugMode) {
          print('Document rejected: $documentId by admin: $adminId');
          print('Reason: $reason');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error rejecting document: $e');
      }
      return false;
    }
  }

  // Bulk approve providers
  static Future<Map<String, bool>> bulkApproveProviders(
    List<String> providerIds,
    String adminId,
  ) async {
    final results = <String, bool>{};

    for (final providerId in providerIds) {
      final success = await approveProvider(providerId, adminId);
      results[providerId] = success;
    }

    if (kDebugMode) {
      final successCount = results.values.where((v) => v).length;
      print('Bulk approval: $successCount/${providerIds.length} succeeded');
    }

    return results;
  }

  // Bulk reject providers
  static Future<Map<String, bool>> bulkRejectProviders(
    List<String> providerIds,
    String adminId,
    String reason,
  ) async {
    final results = <String, bool>{};

    for (final providerId in providerIds) {
      final success = await rejectProvider(providerId, adminId, reason);
      results[providerId] = success;
    }

    if (kDebugMode) {
      final successCount = results.values.where((v) => v).length;
      print('Bulk rejection: $successCount/${providerIds.length} succeeded');
    }

    return results;
  }

  // Get pending providers
  static List<ProviderProfile> getPendingProviders() {
    return ProviderService.getProvidersByStatus(ProviderStatus.pending);
  }

  // Get recently approved providers
  static List<ProviderProfile> getRecentlyApproved({int limit = 10}) {
    final approved = ProviderService.getProvidersByStatus(
      ProviderStatus.approved,
    );

    // Sort by updated date (most recent first)
    approved.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return approved.take(limit).toList();
  }

  // Get recently rejected providers
  static List<ProviderProfile> getRecentlyRejected({int limit = 10}) {
    final rejected = ProviderService.getProvidersByStatus(
      ProviderStatus.rejected,
    );

    // Sort by updated date (most recent first)
    rejected.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return rejected.take(limit).toList();
  }

  // Get providers by status with search
  static List<ProviderProfile> searchProviders({
    ProviderStatus? status,
    String? searchQuery,
  }) {
    List<ProviderProfile> providers;

    if (status != null) {
      providers = ProviderService.getProvidersByStatus(status);
    } else {
      providers = ProviderService.getAllProviders();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      providers = providers.where((p) {
        final name = ProviderService.getProviderDisplayName(p.id);
        final email = ProviderService.getProviderEmail(p.id);
        return name.toLowerCase().contains(query) ||
            email.toLowerCase().contains(query) ||
            (p.specialization?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return providers;
  }

  // Get pending providers count
  static int getPendingProvidersCount() {
    return getPendingProviders().length;
  }

  // Check if provider has pending documents
  // TODO: Implement this feature after:
  // 1. Adding userId/providerId field to Document model
  // 2. Adding getDocumentsByProviderId method to DocumentService
  // 3. Linking documents to providers during upload
  // static bool hasPendingDocuments(String providerId) {
  //   final documents = DocumentService.getDocumentsByProviderId(providerId);
  //   return documents.any((doc) => doc.status == DocumentStatus.pending);
  // }

  // Get provider approval statistics
  static Map<String, int> getApprovalStats() {
    final allProviders = ProviderService.getAllProviders();

    return {
      'pending': allProviders
          .where((p) => p.status == ProviderStatus.pending)
          .length,
      'approved': allProviders
          .where((p) => p.status == ProviderStatus.approved)
          .length,
      'rejected': allProviders
          .where((p) => p.status == ProviderStatus.rejected)
          .length,
      'suspended': allProviders
          .where((p) => p.status == ProviderStatus.suspended)
          .length,
    };
  }
}
