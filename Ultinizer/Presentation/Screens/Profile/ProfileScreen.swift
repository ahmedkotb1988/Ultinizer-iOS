import SwiftUI
import PhotosUI

struct ProfileScreen: View {
    @State private var showLogoutAlert = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var biometricEnabled = false
    @State private var biometricType = "Biometric"

    private let authManager: AuthManager
    private let router: AppRouter
    private let container: AppContainer
    private let themeManager: ThemeManager

    @Environment(\.colorScheme) private var colorScheme

    init(authManager: AuthManager, router: AppRouter, container: AppContainer, themeManager: ThemeManager) {
        self.authManager = authManager
        self.router = router
        self.container = container
        self.themeManager = themeManager
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Profile")
                    .font(AppTypography.largeTitle)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, AppSpacing.xxxl)

                // User info card
                CardView {
                    VStack(spacing: AppSpacing.lg) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                AvatarView(
                                    name: authManager.user?.displayName ?? "",
                                    imageURL: avatarURL,
                                    size: .xl
                                )
                                ZStack {
                                    Circle()
                                        .fill(AppColors.magenta500)
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                                .overlay(
                                    Circle().stroke(colorScheme == .dark ? AppColors.gray800 : .white, lineWidth: 2)
                                )
                            }
                        }

                        VStack(spacing: AppSpacing.xxs) {
                            Text(authManager.user?.displayName ?? "")
                                .font(AppTypography.title)
                                .foregroundColor(AppColors.textPrimary)
                            if let role = authManager.user?.roleLabel, !role.isEmpty {
                                Text(role)
                                    .font(AppTypography.label)
                                    .foregroundColor(AppColors.magenta500)
                            }
                            Text(authManager.user?.email ?? "")
                                .font(AppTypography.label)
                                .foregroundColor(AppColors.gray500)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, AppSpacing.xl)

                // Edit profile
                CardView(onTap: { router.navigate(to: .editProfile) }) {
                    HStack {
                        HStack(spacing: AppSpacing.lg) {
                            Image(systemName: "person")
                                .foregroundColor(AppColors.magenta500)
                            Text("Edit Profile")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.gray400)
                            .font(.system(size: 14))
                    }
                }
                .padding(.bottom, AppSpacing.xl)

                // Household
                if let household = authManager.household {
                    householdCard(household)
                        .padding(.bottom, AppSpacing.xl)
                }

                // Theme
                themeCard
                    .padding(.bottom, AppSpacing.xl)

                // Security
                securityCard
                    .padding(.bottom, AppSpacing.xl)

                // Notifications
                CardView(onTap: { router.navigate(to: .notifications) }) {
                    HStack {
                        HStack(spacing: AppSpacing.lg) {
                            Image(systemName: "bell")
                                .foregroundColor(AppColors.magenta500)
                            Text("Notification Preferences")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.gray400)
                            .font(.system(size: 14))
                    }
                }
                .padding(.bottom, AppSpacing.xl)

                // Logout
                AppButton("Sign Out", variant: .danger) {
                    showLogoutAlert = true
                }
                .padding(.top, AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.xl)
            .padding(.bottom, 40)
        }
        .background(AppColors.backgroundSecondary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                Task { await authManager.logout() }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onChange(of: selectedPhoto) { _, newValue in
            if let newValue {
                Task { await uploadAvatar(item: newValue) }
            }
        }
    }

    // MARK: - Subviews

    private func householdCard(_ household: Household) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Household")
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(AppColors.textSecondary)

                Text(household.name)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "key")
                        .foregroundColor(AppColors.magenta500)
                        .font(.system(size: 16))
                    Text("Invite code: \(household.inviteCode)")
                        .font(AppTypography.labelMedium)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(colorScheme == .dark ? AppColors.gray700 : AppColors.gray50)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

                ForEach(household.members) { member in
                    HStack(spacing: AppSpacing.md) {
                        AvatarView(name: member.displayName, size: .sm)
                        Text(member.displayName)
                            .font(AppTypography.label)
                            .foregroundColor(AppColors.textSecondary)
                        if !member.roleLabel.isEmpty {
                            Text("(\(member.roleLabel))")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.gray400)
                        }
                    }
                }
            }
        }
    }

    private var themeCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Appearance")
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: AppSpacing.md) {
                    ForEach(AppThemeMode.allCases, id: \.self) { mode in
                        let icon: String = {
                            switch mode {
                            case .system: return "iphone"
                            case .light: return "sun.max"
                            case .dark: return "moon"
                            }
                        }()
                        let label: String = {
                            switch mode {
                            case .system: return "System"
                            case .light: return "Light"
                            case .dark: return "Dark"
                            }
                        }()
                        let isSelected = themeManager.mode == mode

                        Button(action: { themeManager.setMode(mode) }) {
                            VStack(spacing: AppSpacing.xs) {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                Text(label)
                                    .font(AppTypography.captionMedium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.lg)
                            .foregroundColor(isSelected ? AppColors.magenta500 : AppColors.gray500)
                            .background(
                                isSelected
                                ? (colorScheme == .dark ? AppColors.magenta950 : AppColors.magenta50)
                                : .clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .stroke(
                                        isSelected ? AppColors.magenta500 : (colorScheme == .dark ? AppColors.gray700 : AppColors.gray200),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }
            }
        }
    }

    private var securityCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Security")
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(AppColors.textSecondary)

                HStack {
                    HStack(spacing: AppSpacing.lg) {
                        Image(systemName: biometricType == "Face ID" ? "faceid" : "touchid")
                            .foregroundColor(AppColors.magenta500)
                        Text("\(biometricType) Unlock")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: $biometricEnabled)
                        .tint(AppColors.magenta500)
                        .labelsHidden()
                }

                Divider().foregroundColor(AppColors.borderPrimary)

                Button(action: { router.navigate(to: .changePassword) }) {
                    HStack {
                        HStack(spacing: AppSpacing.lg) {
                            Image(systemName: "lock")
                                .foregroundColor(AppColors.magenta500)
                            Text("Change Password")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.gray400)
                            .font(.system(size: 14))
                    }
                }
            }
        }
    }

    private var avatarURL: URL? {
        guard let urlString = authManager.user?.avatarUrl, !urlString.isEmpty else { return nil }
        return URL(string: container.baseURL.absoluteString + urlString)
    }

    private func uploadAvatar(item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        do {
            _ = try await container.authRepository.uploadAvatar(
                imageData: data,
                fileName: "avatar.jpg",
                mimeType: "image/jpeg"
            )
            await authManager.refreshUser()
        } catch {
            // Silent failure
        }
    }
}
