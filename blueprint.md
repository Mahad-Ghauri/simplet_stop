# SimpeltStop App Blueprint

## Project Overview
SimpeltStop is a Flutter-based mobile application designed to help users quit nicotine. The app provides educational content, audio boosters, progress tracking, and a craving timer to support users on their quitting journey.

## Detailed MVP Features

1. **Onboarding Flow:** A three-slide introduction to the app's purpose and features, shown only to first-time users.
2. **Authentication (Login / Register):** Email/password authentication using Firebase Auth, with optional Google/Apple login.
3. **Audio Player System:** Educational content and sequential audio/video boosters with background and locked-screen playback support using `just_audio` and `audio_service`. Progress is tracked to unlock content.
4. **Payment Integration (External Stripe):** Integration with Stripe Checkout via an external link to unlock premium content. Payment status is stored in the user's profile.
5. **Progress Tracking:** Visual progress bars to show pages read, audio/videos listened, and days since quitting. Progress is persisted using Firebase.
6. **Basic User Dashboard:** A dashboard with sections for Overview, Journey, Triggers, and Profile.
7. **Craving Timer:** A button to start a timer or play calming audio during cravings.

## Plan for Current Implementation

1. **Create `blueprint.md`:** Document the MVP features and the plan (Completed).
2. **Set up Firebase:** Add dependencies and initialize Firebase.
3. **Implement Onboarding:** Create screens and logic.
4. **Implement Authentication:** Create screens and integrate Firebase Auth.
5. **Implement Audio Player System:** Add dependencies, create service, and implement content unlocking logic.
6. **Implement Payment Integration:** Implement payment confirmation flow and update user profile.
7. **Implement Progress Tracking:** Create progress bar widget and integrate Firestore for data persistence.
8. **Build Basic User Dashboard:** Create dashboard structure and integrate features as they are developed.
9. **Implement Craving Timer:** Create craving timer feature.
10. **Structure the App:** Organize code according to the suggested structure.

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user_model.dart
│   ├── progress_model.dart
│   ├── audio_content_model.dart
│   └── payment_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── audio_service.dart
│   ├── payment_service.dart
│   └── storage_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── progress_provider.dart
│   ├── audio_provider.dart
│   └── payment_provider.dart
├── screens/
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   └── onboarding_page.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── overview_tab.dart
│   │   ├── journey_tab.dart
│   │   ├── triggers_tab.dart
│   │   └── profile_tab.dart
│   ├── audio/
│   │   ├── audio_player_screen.dart
│   │   └── audio_list_screen.dart
│   ├── payment/
│   │   └── payment_screen.dart
│   └── craving/
│       └── craving_timer_screen.dart
├── widgets/
│   ├── common/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_widget.dart
│   │   └── progress_bar.dart
│   ├── onboarding/
│   │   └── onboarding_slide.dart
│   ├── dashboard/
│   │   ├── dashboard_card.dart
│   │   └── stats_widget.dart
│   └── audio/
│       ├── audio_player_controls.dart
│       └── audio_progress_indicator.dart
├── utils/
│   ├── constants.dart
│   ├── theme.dart
│   ├── validators.dart
│   └── helpers.dart
└── routes/
    └── app_routes.dart
```

## Dependencies Required

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_auth: ^6.0.0
  firebase_core: ^4.0.0
  cloud_firestore: ^6.0.0
  provider: ^6.1.5
  http: ^1.4.0
  intl: ^0.20.2
  google_fonts: ^6.3.0
  just_audio: ^0.9.40
  audio_service: ^0.18.15
  shared_preferences: ^2.3.3
  url_launcher: ^6.3.1
  flutter_svg: ^2.0.12
```

## Implementation Status

- [x] Project setup and Firebase configuration
- [ ] Onboarding flow
- [ ] Authentication system
- [ ] Audio player system
- [ ] Payment integration
- [ ] Progress tracking
- [ ] User dashboard
- [ ] Craving timer
- [ ] App structure and navigation