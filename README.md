# DreamHome - Real Estate Mobile App

DreamHome is a comprehensive mobile application designed to provide a complete real estate marketplace for buyers, sellers, and real estate agents. The application aims to simplify the home buying and selling process, providing users with a seamless and intuitive experience.

## 🏠 Features

### 1. Real Estate Listings
- Comprehensive database of properties for sale and rent
- Support for multiple property types (houses, apartments, condos, townhouses, villas, etc.)
- Detailed property information including photos, videos, and virtual tours
- Property status tracking (for sale, for rent, sold, rented, pending, off-market)

### 2. Advanced Search
- Search properties by location, price range, property type, and amenities
- Multiple filter options including bedrooms, bathrooms, size, year built
- Special features filter (pool, garden, garage, etc.)
- Sort by price, distance, size, bedrooms, bathrooms, or date added
- Save search criteria as alerts

### 3. Property Details
- High-quality property photos with gallery view
- Video tours and virtual reality experiences
- Detailed property specifications and amenities
- Interactive maps with property location
- Agent contact information and ratings

### 4. Agent Directory
- Find and connect with local real estate agents
- Agent profiles with ratings, specialties, and contact information
- Filter agents by specialty and location
- Direct messaging and contact options

### 5. Messaging System
- Seamless communication between agents, buyers, and sellers
- Real-time messaging with read receipts
- File and image sharing capabilities
- Property-specific conversation threads

### 6. Favorites and Alerts
- Save favorite properties for easy access
- Set up property alerts based on specific criteria
- Get notified when new matching properties are listed
- Organize favorites with custom categories

### 7. Mortgage Calculator
- Calculate monthly mortgage payments
- Include property taxes, insurance, PMI, and HOA fees
- Loan-to-value ratio and equity calculations
- Affordability analysis based on income

## 🛠 Technical Features

- **Flutter Framework**: Cross-platform mobile development
- **State Management**: Riverpod for reactive state management
- **Maps Integration**: Google Maps for property locations
- **Image Handling**: Cached network images with photo gallery
- **Video Support**: Video player for property tours
- **Local Storage**: SharedPreferences for user data
- **Responsive Design**: Adaptive UI for different screen sizes
- **Modern UI**: Material Design with custom theming

## 📱 Screenshots

<p float="center">
	<img src="screenshot/screenshot_1.png" width="300" />
	<img src="screenshot/screenshot_2.png" width="300" /> 
	<img src="screenshot/screenshot_3.png" width="300" />
	<img src="screenshot/screenshot_4.png" width="300" />
</p>

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android SDK target 34
- iOS target version 15.x

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd dreamhome-real-estate-app
```

2. Install dependencies
```bash
flutter pub get
```

3. Add API keys (see configuration section below)

4. Run the app
```bash
flutter run
```

## ⚙️ Configuration

### API Keys Required

This project requires API keys for full functionality:

#### 1. DTT Endpoint API Key
Add this API key as additional argument to `flutter run`:
```bash
flutter run --dart-define="API_KEY=YOUR_DTT_API_KEY_HERE"
```

#### 2. Google Maps SDK API Key

**Android:**
Add the API key to the `local.properties` file in the `android` folder:
```
MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY_HERE
```

**iOS:**
Add the API key to a new file called `keys.plist` in the `/ios/Runner` folder:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GOOGLE_MAPS_API_KEY</key>
	<string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
</plist>
```

## 📦 Dependencies

### Core Dependencies
- `flutter`: SDK
- `flutter_riverpod`: State management
- `sizer`: Responsive design
- `http`: API communication
- `cached_network_image`: Image caching
- `google_maps_flutter`: Maps integration
- `location`: Location services
- `geolocator`: Geolocation

### Additional Features
- `shared_preferences`: Local storage
- `image_picker`: Image selection
- `video_player`: Video playback
- `photo_view`: Image gallery
- `flutter_local_notifications`: Push notifications
- `intl`: Internationalization
- `uuid`: Unique identifiers
- `firebase_core`: Firebase integration
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_storage`: File storage

## 🏗 Architecture

The app follows a clean architecture pattern with:

- **Models**: Data classes for properties, agents, messages, etc.
- **Providers**: Riverpod providers for state management
- **Screens**: UI screens for different features
- **Components**: Reusable UI components
- **Utils**: Helper functions and constants

## 🎨 UI/UX Features

- **Modern Design**: Clean, intuitive interface
- **Dark/Light Theme**: Adaptive theming support
- **Responsive Layout**: Works on all screen sizes
- **Smooth Animations**: Hero animations and transitions
- **Accessibility**: Screen reader support and accessibility features

## 🔧 Development

### Code Structure
```
lib/
├── application/          # State management providers
├── data/                # API and data layer
├── models/              # Data models
├── ui/
│   ├── components/      # Reusable UI components
│   ├── screens/         # App screens
│   └── theme/           # App theming
└── utils/               # Helper functions
```

### State Management
The app uses Riverpod for state management with providers for:
- Property listings
- Search filters
- Favorites
- Alerts
- User preferences

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For support and questions, please contact the development team or create an issue in the repository.

---

**DreamHome** - Find Your Dream Home Today! 🏡✨


