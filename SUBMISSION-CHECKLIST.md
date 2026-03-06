# App Store Submission Checklist

## Pre-Submission (Both Platforms)

### Code and Build
- [ ] All features complete and tested
- [ ] No debug logging or development flags in release build
- [ ] API endpoints point to production server (https://ultinizer.cloud)
- [ ] Push notification certificates/keys configured for production
- [ ] App version and build number updated
- [ ] All third-party dependencies up to date
- [ ] No compiler warnings in release build
- [ ] Memory leaks checked with Instruments (iOS) / LeakCanary (Android)
- [ ] Crash-free run verified on physical device

### Legal and Compliance
- [ ] Privacy Policy published at https://ultinizer.cloud/privacy
- [ ] Terms of Service published at https://ultinizer.cloud/terms
- [ ] Support page published at https://ultinizer.cloud/support
- [ ] All three pages accessible and rendering correctly
- [ ] Account deletion feature working (required by both Apple and Google)
- [ ] GDPR section included in privacy policy

### Assets
- [ ] App icon exported in all required sizes
- [ ] Screenshots captured for all required device sizes (see STORE-LISTINGS.md)
- [ ] Screenshots reviewed for quality (no debug UI, clean status bar)
- [ ] Feature graphic created (Google Play, 1024x500px)

### Testing
- [ ] Test on latest OS version (iOS and Android)
- [ ] Test on one older supported OS version
- [ ] Test login, registration, password reset flows
- [ ] Test task CRUD, subtasks, comments, attachments
- [ ] Test push notifications on physical device
- [ ] Test household creation and invite code flow
- [ ] Test account deletion
- [ ] Test dark mode
- [ ] Test offline behavior / poor connectivity
- [ ] Test deep links (if applicable)

---

## Apple App Store Submission

### 1. Apple Developer Account Setup
- [ ] Active Apple Developer Program membership ($99/year)
- [ ] Signing certificates created (distribution)
- [ ] Provisioning profiles created (App Store distribution)
- [ ] Push notification certificate or key configured in Apple Developer portal
- [ ] App ID registered with correct bundle identifier

### 2. App Store Connect - Create App
- [ ] Log in to [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Click "My Apps" then "+" to create a new app
- [ ] Select platform: iOS
- [ ] Enter app name: **Ultinizer**
- [ ] Select primary language: English (U.S.)
- [ ] Select bundle ID (must match Xcode project)
- [ ] Enter SKU (unique identifier, e.g., "com.ultinizer.app")
- [ ] Select full access for user access

### 3. App Store Connect - App Information
- [ ] Set subtitle: **Household Task Manager**
- [ ] Set primary category: **Productivity**
- [ ] Set secondary category: **Lifestyle**
- [ ] Set content rating by completing the questionnaire
- [ ] Enter Privacy Policy URL: **https://ultinizer.cloud/privacy**
- [ ] Set age rating: 4+

### 4. App Store Connect - Pricing and Availability
- [ ] Set price: **Free**
- [ ] Select availability: All territories (or specific territories)
- [ ] Pre-orders: No

### 5. App Store Connect - App Privacy (Data Collection Labels)
- [ ] Complete the App Privacy questionnaire:
  - **Contact Info** (email): Collected, used for App Functionality
  - **Identifiers** (user ID): Collected, used for App Functionality
  - **User Content** (photos, other user content): Collected, used for App Functionality
  - **Data NOT linked to user**: None
  - **Data used to track user**: None
  - **Third-party analytics**: None

### 6. App Store Connect - Version Information
- [ ] Upload screenshots for all required device sizes
  - [ ] iPhone 6.7" display (required)
  - [ ] iPhone 6.1" display (recommended)
  - [ ] iPad screenshots (if supporting iPad)
- [ ] Enter promotional text (see STORE-LISTINGS.md)
- [ ] Enter description (see STORE-LISTINGS.md)
- [ ] Enter keywords (see STORE-LISTINGS.md)
- [ ] Enter support URL: **https://ultinizer.cloud/support**
- [ ] Enter marketing URL (optional): **https://ultinizer.cloud**
- [ ] Add "What's New" text (for updates)

### 7. Build and Upload
- [ ] In Xcode, select "Any iOS Device" as build target
- [ ] Set build configuration to Release
- [ ] Product > Archive
- [ ] In Organizer, click "Distribute App"
- [ ] Select "App Store Connect" distribution
- [ ] Upload the archive
- [ ] Wait for build processing (usually 15-30 minutes)
- [ ] Build appears in App Store Connect under the version

### 8. App Review Information
- [ ] Select the uploaded build
- [ ] Enter App Review contact information
  - Name: Ahmed Kotb
  - Email: support@ultinizer.cloud
- [ ] Enter demo account credentials:
  - Email: **husband@example.com**
  - Password: **password123**
- [ ] Add review notes explaining:
  - The app requires a household to function
  - Demo account has pre-configured household "Our Home"
  - Push notifications require physical device
  - Describe key features to test

### 9. Submit for Review
- [ ] Review all information one final time
- [ ] Click "Add for Review"
- [ ] Click "Submit to App Review"
- [ ] Monitor review status (typical review time: 24-48 hours)

### 10. Post-Submission (Apple)
- [ ] Monitor for review feedback or rejection reasons
- [ ] If rejected, address issues and resubmit
- [ ] Once approved, confirm release timing (immediate or scheduled)
- [ ] Verify app appears in App Store and is downloadable

---

## Google Play Store Submission

### 1. Google Play Console Account Setup
- [ ] Active Google Play Developer account ($25 one-time fee)
- [ ] Account identity verification completed
- [ ] Signing key configured (Google Play App Signing recommended)

### 2. Google Play Console - Create App
- [ ] Log in to [Google Play Console](https://play.google.com/console)
- [ ] Click "Create app"
- [ ] Enter app name: **Ultinizer**
- [ ] Select default language: English (United States)
- [ ] Select app type: App
- [ ] Select free or paid: **Free**
- [ ] Confirm declarations (developer program policies, export laws, etc.)

### 3. Store Listing (Main Store Listing)
- [ ] Enter short description (see STORE-LISTINGS.md)
- [ ] Enter full description (see STORE-LISTINGS.md)
- [ ] Upload app icon (512x512px, 32-bit PNG)
- [ ] Upload feature graphic (1024x500px, JPEG or PNG)
- [ ] Upload phone screenshots (minimum 2, maximum 8)
- [ ] Upload tablet screenshots (optional but recommended)

### 4. App Content (Policy Compliance)
- [ ] **Privacy Policy**: Enter URL **https://ultinizer.cloud/privacy**
- [ ] **Ads**: App does NOT contain ads
- [ ] **App access**: Provide demo credentials
  - Email: **husband@example.com**
  - Password: **password123**
  - Instructions: Account has pre-configured household
- [ ] **Content rating**: Complete IARC questionnaire
  - User interaction: Yes
  - Users can share photos/media: Yes
  - All other categories: No
- [ ] **Target audience**: Not designed for children (not a "Made for Kids" app)
- [ ] **Data safety**: Complete the data safety form
  - Data collected: Email, name, photos, user-generated content
  - Data shared with third parties: None
  - Data encrypted in transit: Yes
  - Users can request data deletion: Yes
  - Link to privacy policy
- [ ] **Government apps**: No
- [ ] **Financial features**: No

### 5. App Integrity
- [ ] Choose signing preference: **Google Play App Signing** (recommended)
- [ ] Upload signing key or let Google manage it

### 6. Build and Upload
- [ ] Generate release AAB (Android App Bundle):
  ```
  ./gradlew bundleRelease
  ```
- [ ] Locate the AAB at `app/build/outputs/bundle/release/app-release.aab`
- [ ] In Play Console, go to Release > Production
- [ ] Click "Create new release"
- [ ] Upload the AAB file
- [ ] Enter release name (version number)
- [ ] Enter release notes ("What's new")
- [ ] Review release and click "Start rollout to Production"

### 7. Pre-Launch Report
- [ ] Wait for Google's automated pre-launch report
- [ ] Review for crashes, accessibility issues, and security vulnerabilities
- [ ] Address any critical findings before proceeding

### 8. Submit for Review
- [ ] Ensure all store listing sections are complete (check for warning icons)
- [ ] Ensure all policy declarations are complete
- [ ] Submit the release for review
- [ ] Monitor review status (typical review time: hours to a few days)

### 9. Post-Submission (Google)
- [ ] Monitor for policy violation notices
- [ ] If rejected, address issues and resubmit
- [ ] Once approved, verify app appears in Play Store
- [ ] Check that the store listing renders correctly
- [ ] Verify the app downloads and installs correctly from the Store

---

## Post-Launch (Both Platforms)

- [ ] Monitor crash reports (Xcode Organizer / Play Console Vitals)
- [ ] Monitor user reviews and respond promptly
- [ ] Set up alerts for negative reviews
- [ ] Verify push notifications work for production users
- [ ] Monitor server health and API response times
- [ ] Plan update cadence for bug fixes and new features
- [ ] Keep privacy policy and terms of service up to date
- [ ] Renew Apple Developer membership before expiration
