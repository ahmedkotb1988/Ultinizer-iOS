import SwiftUI
import PhotosUI
import SafariServices
import AVFoundation

struct ProfileScreen: View {
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showPasswordPrompt = false
    @State private var deletePassword = ""
    @State private var deleteError = ""
    @State private var isDeletingAccount = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var biometricEnabled = false
    @State private var biometricAvailable = false
    @State private var biometricType = "Biometric"
    @State private var biometricLoaded = false
    @State private var safariURL: URL?
    @State private var showPhotoSourceSheet = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showCameraPermissionAlert = false
    @State private var showEditProfile = false
    @State private var showChangePassword = false
    @State private var showNotifications = false

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
                    .accessibilityAddTraits(.isHeader)

                // User info card
                CardView {
                    VStack(spacing: AppSpacing.lg) {
                        Button(action: { showPhotoSourceSheet = true }) {
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
                        .accessibilityLabel("Change profile photo")

                        VStack(spacing: AppSpacing.xxs) {
                            Text(authManager.user?.displayName ?? "")
                                .font(AppTypography.title)
                                .foregroundColor(AppColors.textPrimary)
                                .accessibilityLabel("Display name: \(authManager.user?.displayName ?? "")")
                            if let role = authManager.user?.roleLabel, !role.isEmpty {
                                Text(role)
                                    .font(AppTypography.label)
                                    .foregroundColor(AppColors.magenta500)
                                    .accessibilityLabel("Role: \(role)")
                            }
                            Text(authManager.user?.email ?? "")
                                .font(AppTypography.label)
                                .foregroundColor(AppColors.gray500)
                                .accessibilityLabel("Email: \(authManager.user?.email ?? "")")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, AppSpacing.xl)

                // Edit profile
                CardView(onTap: { showEditProfile = true }) {
                    HStack {
                        HStack(spacing: AppSpacing.lg) {
                            Image(systemName: "person")
                                .foregroundColor(AppColors.magenta500)
                                .accessibilityHidden(true)
                            Text("Edit Profile")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.gray400)
                            .font(.system(size: 14))
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityLabel("Edit Profile")
                .accessibilityAddTraits(.isButton)
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
                CardView(onTap: { showNotifications = true }) {
                    HStack {
                        HStack(spacing: AppSpacing.lg) {
                            Image(systemName: "bell")
                                .foregroundColor(AppColors.magenta500)
                                .accessibilityHidden(true)
                            Text("Notification Preferences")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.gray400)
                            .font(.system(size: 14))
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityLabel("Notification Preferences")
                .accessibilityAddTraits(.isButton)
                .padding(.bottom, AppSpacing.xl)

                // Legal section
                legalCard
                    .padding(.bottom, AppSpacing.xl)

                // Logout
                AppButton("Sign Out", variant: .danger) {
                    showLogoutAlert = true
                }
                .accessibilityLabel("Sign out of your account")
                .padding(.top, AppSpacing.xl)

                // Delete Account
                Button(action: { showDeleteAccountAlert = true }) {
                    HStack {
                        Spacer()
                        Text("Delete Account")
                            .font(AppTypography.labelSemiBold)
                            .foregroundColor(AppColors.red500)
                        Spacer()
                    }
                    .padding(.vertical, AppSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .stroke(AppColors.red500, lineWidth: 1)
                    )
                }
                .accessibilityLabel("Delete your account permanently")
                .padding(.top, AppSpacing.lg)
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
        .alert("Delete Account?", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Account", role: .destructive) {
                showPasswordPrompt = true
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        .alert("Confirm Password", isPresented: $showPasswordPrompt) {
            SecureField("Enter your password", text: $deletePassword)
            Button("Cancel", role: .cancel) {
                deletePassword = ""
                deleteError = ""
            }
            Button("Delete", role: .destructive) {
                Task { await performDeleteAccount() }
            }
        } message: {
            if deleteError.isEmpty {
                Text("Please enter your password to confirm account deletion.")
            } else {
                Text(deleteError)
            }
        }
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
        .onChange(of: selectedPhoto) { _, newValue in
            if let newValue {
                Task { await uploadAvatar(item: newValue) }
            }
        }
        .task {
            let service = BiometricService.shared
            biometricAvailable = await service.isAvailable()
            if let type = await service.biometricTypeString() {
                biometricType = type
            }
            biometricEnabled = container.userDefaultsService.getBool(forKey: UserDefaultsService.Keys.biometricEnabled)
            biometricLoaded = true
        }
        .confirmationDialog("Change Profile Photo", isPresented: $showPhotoSourceSheet, titleVisibility: .visible) {
            Button("Take Photo") {
                Task {
                    let granted = await CameraPermissionHelper.requestAccess()
                    if granted {
                        showCamera = true
                    } else {
                        showCameraPermissionAlert = true
                    }
                }
            }
            Button("Choose from Library") {
                showPhotoPicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                showCamera = false
                guard let data = image.jpegData(compressionQuality: 0.8) else { return }
                Task { await uploadAvatarData(data) }
            } onCancel: {
                showCamera = false
            }
        }
        .alert("Camera Access Required", isPresented: $showCameraPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable camera access in Settings to take profile photos.")
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileScreen(authManager: authManager, updateProfileUseCase: container.updateProfileUseCase)
        }
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordScreen(changePasswordUseCase: container.changePasswordUseCase)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsScreen(container: container, router: router)
        }
    }

    // MARK: - Subviews

    private func householdCard(_ household: Household) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Household")
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(AppColors.textSecondary)
                    .accessibilityAddTraits(.isHeader)

                Text(household.name)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
                    .accessibilityLabel("Household name: \(household.name)")

                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "key")
                        .foregroundColor(AppColors.magenta500)
                        .font(.system(size: 16))
                        .accessibilityHidden(true)
                    Text("Invite code: \(household.inviteCode)")
                        .font(AppTypography.labelMedium)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                    Spacer()
                    ShareLink(item: "Join my household on Ultinizer! Use invite code: \(household.inviteCode)") {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppColors.magenta500)
                            .font(.system(size: 16))
                    }
                    .accessibilityLabel("Share invite code")
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(colorScheme == .dark ? AppColors.gray700 : AppColors.gray50)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Household invite code: \(household.inviteCode)")

                ForEach(household.members) { member in
                    HStack(spacing: AppSpacing.md) {
                        AvatarView(name: member.displayName, size: .sm)
                            .accessibilityHidden(true)
                        Text(member.displayName)
                            .font(AppTypography.label)
                            .foregroundColor(AppColors.textSecondary)
                        if !member.roleLabel.isEmpty {
                            Text("(\(member.roleLabel))")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.gray400)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Member: \(member.displayName)\(member.roleLabel.isEmpty ? "" : ", \(member.roleLabel)")")
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
                    .accessibilityAddTraits(.isHeader)

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
                                    .accessibilityHidden(true)
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
                        .accessibilityLabel("\(label) theme\(isSelected ? ", selected" : "")")
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
                    .accessibilityAddTraits(.isHeader)

                if biometricAvailable {
                    HStack {
                        HStack(spacing: AppSpacing.lg) {
                            Image(systemName: biometricType == "Face ID" ? "faceid" : "touchid")
                                .foregroundColor(AppColors.magenta500)
                                .accessibilityHidden(true)
                            Text("\(biometricType) Unlock")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { biometricEnabled },
                            set: { newValue in
                                guard biometricLoaded else { return }
                                Task {
                                    if newValue {
                                        let success = await BiometricService.shared.authenticate(
                                            reason: "Verify your identity to enable \(biometricType) Unlock"
                                        )
                                        if success {
                                            biometricEnabled = true
                                            container.userDefaultsService.setBool(true, forKey: UserDefaultsService.Keys.biometricEnabled)
                                        }
                                    } else {
                                        biometricEnabled = false
                                        container.userDefaultsService.setBool(false, forKey: UserDefaultsService.Keys.biometricEnabled)
                                    }
                                }
                            }
                        ))
                            .tint(AppColors.magenta500)
                            .labelsHidden()
                            .accessibilityLabel("\(biometricType) Unlock, \(biometricEnabled ? "enabled" : "disabled")")
                    }

                    Divider().foregroundColor(AppColors.borderPrimary)
                }

                Button(action: { showChangePassword = true }) {
                    HStack {
                        HStack(spacing: AppSpacing.lg) {
                            Image(systemName: "lock")
                                .foregroundColor(AppColors.magenta500)
                                .accessibilityHidden(true)
                            Text("Change Password")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.gray400)
                            .font(.system(size: 14))
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityLabel("Change Password")
            }
        }
    }

    private var legalCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Legal")
                    .font(AppTypography.labelSemiBold)
                    .foregroundColor(AppColors.textSecondary)
                    .accessibilityAddTraits(.isHeader)

                legalRow(icon: "doc.text", title: "Privacy Policy", url: "https://ultinizer.cloud/privacy")

                Divider().foregroundColor(AppColors.borderPrimary)

                legalRow(icon: "doc.plaintext", title: "Terms of Service", url: "https://ultinizer.cloud/terms")

                Divider().foregroundColor(AppColors.borderPrimary)

                legalRow(icon: "questionmark.circle", title: "Support", url: "https://ultinizer.cloud/support")
            }
        }
    }

    private func legalRow(icon: String, title: String, url: String) -> some View {
        Button(action: {
            safariURL = URL(string: url)
        }) {
            HStack {
                HStack(spacing: AppSpacing.lg) {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.magenta500)
                        .accessibilityHidden(true)
                    Text(title)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(AppColors.gray400)
                    .font(.system(size: 14))
                    .accessibilityHidden(true)
            }
        }
        .accessibilityLabel("Open \(title)")
    }

    private var avatarURL: URL? {
        guard let urlString = authManager.user?.avatarUrl, !urlString.isEmpty else { return nil }
        let base = container.baseURL.absoluteString + urlString
        let v = authManager.avatarVersion
        return v > 0 ? URL(string: "\(base)?v=\(v)") : URL(string: base)
    }

    private func uploadAvatar(item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        await uploadAvatarData(data)
    }

    private func uploadAvatarData(_ data: Data) async {
        do {
            _ = try await container.authRepository.uploadAvatar(
                imageData: data,
                fileName: "avatar.jpg",
                mimeType: "image/jpeg"
            )
            await authManager.refreshUser()
            authManager.bumpAvatarVersion()
        } catch {
            // Silent failure
        }
    }

    @MainActor
    private func performDeleteAccount() async {
        guard !deletePassword.isEmpty else {
            deleteError = "Password is required"
            showPasswordPrompt = true
            return
        }

        isDeletingAccount = true
        defer { isDeletingAccount = false }

        do {
            try await authManager.deleteAccount(password: deletePassword)
            deletePassword = ""
            deleteError = ""
        } catch let error as APIError {
            deleteError = error.userMessage
            deletePassword = ""
            showPasswordPrompt = true
        } catch {
            deleteError = "Failed to delete account. Please try again."
            deletePassword = ""
            showPasswordPrompt = true
        }
    }
}

// MARK: - Safari View

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
