# Kigali City Services & Places Directory

This is a Flutter mobile application that helps Kigali residents find and navigate to essential services and leisure locations across the city.

**GitHub Repository:** https://github.com/Winnie-Irene/kigali_directory

---

## About

Kigali Directory is a fully backend-connected mobile app built with Flutter and Firebase. Users can browse a real-time directory of places, add their own listings, bookmark favourites, leave reviews, and get directions, all with data stored and synced live through Cloud Firestore.

---

## Features

- Email and password authentication with enforced email verification
- User profiles stored in Firestore, linked to every listing the user creates
- Create, edit, and delete your own listings
- Real-time directory that updates automatically when data changes
- Search listings by name and filter by category
- Detail page with an embedded OpenStreetMap and location marker
- One-tap directions button that launches turn-by-turn navigation
- Bookmark listings to save them for later
- Star ratings and written reviews for each listing
- Settings screen with profile display and notification preference toggle

---

## Known Limitations

- **Verification emails may go to spam.** This is a limitation of Firebase's default sender address (`noreply@[project].firebaseapp.com`). If you do not see the verification email in your inbox, please check your spam or junk folder.
- **OpenStreetMap is used instead of Google Maps.** Google Maps requires a billing-enabled API key which was not available for this project. The directions button opens Google Maps externally, which does not require an API key.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| State Management | Provider |
| Maps | flutter_map (OpenStreetMap) |
| Navigation | url_launcher |
| Sharing | share_plus |

---

## Project Structure

```
lib/
├── main.dart                         # App entry point, Firebase init, Provider setup
├── firebase_options.dart             # Firebase configuration
├── models/
│   ├── listing_model.dart            # Listing data class with Firestore serialization
│   ├── user_model.dart               # User profile data class
│   └── review_model.dart             # Review data class
├── services/
│   ├── auth_service.dart             # All Firebase Auth operations
│   └── listing_service.dart          # All Firestore CRUD operations
├── providers/
│   ├── auth_provider.dart            # Auth state management (ChangeNotifier)
│   └── listing_provider.dart         # Listings state management (ChangeNotifier)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── verify_email_screen.dart
│   ├── directory/
│   │   ├── directory_screen.dart
│   │   └── listing_detail_screen.dart
│   ├── my_listings/
│   │   ├── my_listings_screen.dart
│   │   └── listing_form_screen.dart
│   ├── map/
│   │   └── map_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   ├── bottom_nav.dart               # MainScaffold with BottomNavigationBar
│   └── listing_card.dart             # Reusable listing card widget
└── utils/
    └── constants.dart                # Category list and icon mappings
```

---

## Firestore Database Structure

### `users/{uid}`
| Field | Type | Description |
|---|---|---|
| email | String | User email from Firebase Auth |
| displayName | String | Full name entered at signup |
| username | String | Unique handle chosen at signup |
| bio | String | Optional short bio |
| notificationsEnabled | Boolean | Notification preference toggle |
| totalListings | Number | Count of listings created |
| joinedAt | Timestamp | Account creation time |

### `listings/{listingId}`
| Field | Type | Description |
|---|---|---|
| name | String | Place or service name |
| category | String | One of the predefined categories |
| address | String | Street address in Kigali |
| contactNumber | String | Phone number |
| description | String | Description of the place |
| latitude | Number | Geographic coordinate |
| longitude | Number | Geographic coordinate |
| createdBy | String | UID of the listing creator |
| createdByUsername | String | Username at time of creation |
| timestamp | Timestamp | Creation time, used for sorting |
| avgRating | Number | Calculated average star rating |
| reviewCount | Number | Total number of reviews |
| favouriteCount | Number | Number of users who bookmarked this |

### `reviews/{reviewId}`
| Field | Type | Description |
|---|---|---|
| listingId | String | ID of the listing being reviewed |
| userId | String | UID of the reviewer |
| username | String | Reviewer display name |
| rating | Number | Star rating 1–5 |
| comment | String | Written review text |
| timestamp | Timestamp | Submission time |

### `favourites/{userId}_{listingId}`
| Field | Type | Description |
|---|---|---|
| userId | String | UID of the user |
| listingId | String | ID of the bookmarked listing |
| timestamp | Timestamp | When the bookmark was created |

---

## State Management

The app uses the **Provider** package with two `ChangeNotifier` classes:

**`AuthProvider`** listens to Firebase's `authStateChanges` stream. Whenever auth state changes — login, logout, or email verification — it fetches the user's Firestore profile and notifies all listening widgets to rebuild. The `AuthWrapper` widget watches `AuthProvider` and routes users to the correct screen automatically.

**`ListingProvider`** manages three real-time Firestore streams: all listings for the directory, the current user's listings for the My Listings tab, and the user's bookmarked listings. All three streams are started in `MainScaffold.initState()` so they are active immediately after login regardless of which tab the user visits first.

All Firestore operations go through the service layer (`AuthService`, `ListingService`) and are exposed to the UI through the providers. **No screen widget calls Firebase directly.**

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.createdBy;
      allow update: if request.auth != null;
      allow delete: if request.auth != null && request.auth.uid == resource.data.createdBy;
    }
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    match /favourites/{favouriteId} {
      allow read, write: if request.auth != null;
      allow delete: if request.auth != null;
    }
  }
}
```

---

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/Winnie-Irene/kigali_directory.git
   cd kigali_directory
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. The `google-services.json` file is included in `android/app/` for the Firebase project configuration.

4. Run on an Android emulator or physical device:
   ```bash
   flutter run
   ```

> **Note:** This app must be run on a mobile emulator or physical Android device. It is not designed to run in a browser.