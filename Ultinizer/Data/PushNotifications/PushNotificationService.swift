import Foundation
import UIKit
import UserNotifications

@MainActor
protocol PushNotificationServiceProtocol: AnyObject {
    var pendingDeepLinkTaskId: String? { get set }
    func requestPermissionAndRegister() async
    func registerDeviceToken(_ tokenData: Data) async
    func unregisterDevice() async
    func handleNotificationTap(userInfo: [AnyHashable: Any])
}

@Observable
@MainActor
final class PushNotificationService: NSObject, PushNotificationServiceProtocol {
    var pendingDeepLinkTaskId: String?

    private let apiClient: APIClientProtocol
    private var currentDeviceToken: String?

    nonisolated init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
        super.init()
    }

    // MARK: - Permission & Registration

    func requestPermissionAndRegister() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            print("[Push] Permission request failed: \(error)")
        }
    }

    // MARK: - Device Token

    func registerDeviceToken(_ tokenData: Data) async {
        let token = tokenData.map { String(format: "%02x", $0) }.joined()
        currentDeviceToken = token

        do {
            let body = RegisterDeviceBody(token: token, platform: "ios")
            try await apiClient.request(endpoint: .registerDevice, body: body)
            print("[Push] Device token registered with backend")
        } catch {
            print("[Push] Failed to register device token: \(error)")
        }
    }

    func unregisterDevice() async {
        guard let token = currentDeviceToken else { return }
        do {
            let body = UnregisterDeviceBody(token: token)
            try await apiClient.request(endpoint: .unregisterDevice, body: body)
            print("[Push] Device token unregistered from backend")
        } catch {
            print("[Push] Failed to unregister device token: \(error)")
        }
        currentDeviceToken = nil
    }

    // MARK: - Notification Tap Handling

    func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        if let taskId = userInfo["taskId"] as? String {
            pendingDeepLinkTaskId = taskId
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationService: @preconcurrency UNUserNotificationCenterDelegate {
    /// Display notifications while the app is in the foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    /// Handle notification taps
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Task { @MainActor in
            self.handleNotificationTap(userInfo: userInfo)
        }
        completionHandler()
    }
}

// MARK: - Request Bodies

private struct RegisterDeviceBody: Encodable {
    let token: String
    let platform: String
}

private struct UnregisterDeviceBody: Encodable {
    let token: String
}
