# DreamHome - Flutter Real Estate App

A comprehensive mobile real estate marketplace designed for buyers, sellers, and real estate agents. Built with Flutter for iOS and Android.

## Features

### 1. Real Estate Listings 🏠
- Comprehensive database of properties for sale and rent
- Beautiful card-based UI showing property images, prices, and key details
- Hero animations for smooth transitions

### 2. Advanced Search 🔍
- Search properties by location (city, zip code)
- Filter by price range
- Sort by multiple criteria:
  - Price
  - Distance from your location
  - Number of bathrooms
  - Number of bedrooms
  - Surface area

### 3. Property Details 📋
- High-quality property photos with caching
- Detailed property information:
  - Price, bedrooms, bathrooms, size
  - Full description
  - Distance from your location
- Interactive Google Maps integration
- Tap-to-navigate to property location
- Add/remove properties from favorites

### 4. Agent Directory 👥
- Browse professional real estate agents
- View agent profiles with:
  - Specialty areas
  - Rating and properties sold
  - Professional bio
  - Contact information
- Direct call, email, or message agents

### 5. Messaging System 💬
- Real-time messaging with agents
- Property-specific conversations
- Conversation history
- Unread message indicators
- Beautiful chat interface

### 6. Favorites & Alerts ⭐
- Save favorite properties for quick access
- Visual indicators for favorited properties
- Dedicated favorites screen
- One-tap add/remove from favorites

### 7. Mortgage Calculator 💰
- Calculate monthly mortgage payments
- Input:
  - Home price
  - Down payment
  - Interest rate
  - Loan term
- Display:
  - Monthly payment
  - Total payment over loan term
  - Total interest paid
  - Estimated closing costs (3% of home price)
- Payment breakdown visualization

## Technical Details

- **Android SDK target**: 34
- **iOS target version**: 15.x
- **State Management**: Riverpod
- **Architecture**: Provider pattern with clean separation of concerns

## Project Structure

```
lib/
├── application/          # State providers and business logic
│   ├── favorites_provider.dart
│   ├── list_agents_provider.dart
│   ├── list_houses_provider.dart
│   ├── messages_provider.dart
│   └── ...
├── models/              # Data models
│   ├── agent_model.dart
│   ├── favorite_model.dart
│   ├── house_model.dart
│   ├── message_model.dart
│   └── ...
├── ui/
│   ├── components/      # Reusable UI components
│   ├── screens/         # App screens
│   │   ├── overview_screen.dart
│   │   ├── detail_screen.dart
│   │   ├── agents_screen.dart
│   │   ├── agent_profile_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── messages_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── mortgage_calculator_screen.dart
│   │   └── about_screen.dart
│   └── theme/           # App theming
└── utils/               # Helper functions
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode for platform-specific builds
- API keys (see below)

### Adding API Keys

This project requires 2 API keys:
- Key for DTT endpoint (property data)
- Key for Google Maps SDK Android / iOS

#### API Key: DTT Endpoint
Add this API key as an additional argument to `flutter run`:
```bash
flutter run --dart-define="API_KEY=YOUR_KEY_HERE"
```

#### API Key: Google Maps SDK

**Android:**
Add the API key to the `local.properties` file in the `android` folder:
```
MAPS_API_KEY=YOUR_API_KEY_HERE
```

**iOS:**
Add the API key to a new file called `keys.plist` in the `/ios/Runner` folder:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GOOGLE_MAPS_API_KEY</key>
	<string>YOUR_API_KEY_HERE</string>
</dict>
</plist>
```

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd flutter_real_estate
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run --dart-define="API_KEY=YOUR_KEY_HERE"
```

## Dependencies

- `flutter_riverpod` - State management
- `http` - API calls
- `cached_network_image` - Image caching
- `google_maps_flutter` - Maps integration
- `geolocator` & `location` - Location services
- `url_launcher` - Phone & email functionality
- `flutter_svg` - SVG icon support
- `sizer` - Responsive sizing
- `intl` - Date/time formatting

## Screenshots

<p float="center">
	<img src="screenshot/screenshot_1.png" width="300" />
	<img src="screenshot/screenshot_2.png" width="300" /> 
	<img src="screenshot/screenshot_3.png" width="300" />
	<img src="screenshot/screenshot_4.png" width="300" />
</p>

## License

This project is part of the DTT assessment.
