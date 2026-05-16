# Goal Connect - Scout & Player Network

Goal Connect is a Flutter mobile application that bridges the gap between football players and scouts. It enables players to showcase their talent through video highlights and allows scouts to discover, analyze, and connect with emerging talent globally.

## 📱 Features

### For Players
- **User Profile Management**
  - Full name, bio, position, and statistics display
  - Profile image upload
  - Player stats (goals, assists, matches played)
  - Ability ratings (pace, shooting, passing, dribbling, defending, physical)
  
- **Highlight Management**
  - Upload video highlights with captions
  - View personal highlight gallery
  - Track video views and likes
  - Privacy controls (public/private)

- **Messaging System**
  - Real-time chat with scouts via Socket.IO
  - Message history
  - Unread message tracking
  - Online status indicator

- **Performance Insights**
  - View performance analytics
  - Track follower counts
  - Monitor engagement metrics

### For Scouts
- **Player Discovery**
  - Browse player catalog with filtering
  - Search by position, location, and stats
  - View featured players
  - Save favorite players


- **Video Analysis**
  - Watch player highlight videos
  - Like and comment on highlights

- **Outreach**
  - Initiate conversations with players
  - Send direct messages
  - Manage conversations
  - Real-time messaging

### General Features
- **Authentication**
  - Secure user registration and login
  - Role-based access (Player/Scout)
  - Session management
  - Auto-login functionality

- **Onboarding**
  - 3-step introduction screens
  - Feature explanations
  - User role selection

- **Offline Support**
  - Internet connection detection
  - Offline indicator
  - Local data caching
  - Auto-reconnection

- **Theme Support**
  - Dark and light modes
  - Persistent theme preference

## 🏗️ Architecture

Goal Connect follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/           # API constants
│   ├── error/               # Error handling & failures
│   ├── theme/               # Theme configuration
│   └── widgets/             # Reusable widgets
├── features/
│   ├── auth/                # Authentication
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── onboarding/          # Intro screens
│   ├── highlights/          # Video highlights
│   ├── chat/                # Messaging system
│   ├── profile/             # Player profiles
│   └── connection/          # Internet detection
├── injection_container.dart # Dependency injection
└── main.dart
```

### Design Pattern: BLoC
- **BLoC (Business Logic Component)** pattern for state management
- Clean separation between UI and business logic
- Reactive data streams with StreamBuilder and BlocBuilder

### Data Flow
1. **UI Layer** - Flutter widgets, BLoC consumers
2. **Presentation Layer** - BLoCs, Events, States
3. **Domain Layer** - Use cases, Entities, Repositories (abstract)
4. **Data Layer** - Repositories (implementation), Data sources, Models

## 🛠️ Technology Stack

- **Framework**: Flutter 3.10.3+
- **Language**: Dart
- **State Management**: Flutter BLoC 9.1.1
- **Networking**: Dio 5.9.2
- **Real-time**: Socket.IO Client 3.1.4
- **Database**: SharedPreferences, Hive (local caching)
- **Security**: Flutter Secure Storage 10.0.0
- **Animation**: Lottie 3.1.2
- **Video**: Video Player 2.11.1, Camera 0.11.1
- **Media**: Image Picker 1.2.1
- **Functional**: Dartz (Either monad)

## 📦 Dependencies

```yaml
flutter_bloc: ^9.1.1           # State management
dio: ^5.9.2                    # HTTP client
socket_io_client: ^3.1.4       # Real-time messaging
video_player: ^2.11.1          # Video playback
camera: ^0.11.1                # Camera access
image_picker: ^1.2.1           # Image selection
lottie: ^3.1.2                 # Animations
flutter_secure_storage: ^10.0.0 # Secure storage
shared_preferences: ^2.5.4     # Preferences
get_it: ^9.2.1                 # Service locator
dartz: ^0.10.1                 # Functional programming
equatable: ^2.0.8              # Value equality
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.3 or higher
- Android SDK (for Android development)
- Xcode (for iOS development)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Goal-Connect/goal-connect-mobile.git
   cd goal-connect-mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment**
   - Create `.env` file with API endpoints
   - Configure API constants in `lib/core/constants/api_constants.dart`

4. **Generate necessary files** (if using code generation)
   ```bash
   flutter pub run build_runner build
   ```

5. **Run the app**
   ```bash
   # Development
   flutter run

   # Release
   flutter run --release
   ```

## 🔐 Authentication

### Login Flow
1. User enters email/password
2. API validates credentials
3. Server returns JWT token and user data
4. Token stored in secure storage
5. User auto-logged in on app restart

### Roles
- **Player** - Content creator, can upload videos
- **Scout** - Content consumer, can initiate chats
- **Academy** - Team account, view-only access
- **Admin** - System administrator

## 💬 Real-time Messaging

### Socket.IO Integration
- **Host**: Configured in `ChatSocketService`
- **Events**: 
  - `send_message` - Send direct message
  - `receive_message` - Receive incoming message
  - `typing` - Show typing indicator
  - `online` - User online status

### Message Features
- Real-time delivery via Socket.IO
- HTTP fallback if socket unavailable
- Message history persistence
- Unread count tracking
- Conversation threading

## 📸 Video Upload & Playback

### Upload Features
- Multi-format support (MP4, MOV, AVI)
- Progress tracking
- Thumbnail generation
- Privacy controls
- Video validation

### Playback
- Video Player widget integration
- Play/pause controls
- Fullscreen mode
- Progress seeking
- Loop capability

## 🎨 UI/UX

### Theme System
- **Brazilian Flag Colors**:
  - Green (#00C278)
  - Gold (#FFD700)
  - Red (#DA291C)
  - Dark background with white text

### Typography
- **Headings**: Bold, high contrast
- **Body**: Clear, readable fonts
- **Letter spacing**: Refined for readability

### Components
- Custom glass-morphism containers
- Animated transitions
- Loading indicators
- Error states with retry
- Empty states with helpful messages

## 🧪 Testing

### Test Types
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for features

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/auth_test.dart

# Generate coverage report
flutter test --coverage
```

## 📝 Project Structure

### Key Files

**Authentication**
- `lib/features/auth/presentation/bloc/auth_bloc.dart` - Auth state management
- `lib/features/auth/domain/usecases/` - Auth use cases

**Chat System**
- `lib/features/chat/data/services/chat_socket_service.dart` - Socket.IO service
- `lib/features/chat/presentation/pages/conversation_page.dart` - Chat UI

**Highlights**
- `lib/features/highlights/presentation/pages/single_highlight_page.dart` - Video page
- `lib/features/highlights/presentation/widgets/video_feed_item.dart` - Video player

**Profile**
- `lib/features/profile/presentation/pages/player_profile_page.dart` - Player profile
- `lib/features/auth/presentation/pages/current_user_profile_page.dart` - Current user profile

## 🔗 API Integration

### Base URL
```
https://goalconnect-backend-repo-2.onrender.com
```

### Key Endpoints

**Authentication**
- `POST /auth/login` - User login
- `POST /auth/register` - New registration
- `GET /auth/me` - Current user info

**Videos**
- `GET /videos/feed` - Video feed
- `POST /videos` - Upload video
- `GET /videos/:id` - Video details
- `POST /videos/:id/like` - Like video

**Players**
- `GET /players` - Player list
- `GET /players/:id` - Player details
- `GET /players/:id/highlights` - Player videos

**Messages**
- `GET /messages/:userId` - Chat history
- `POST /messages` - Send message

## 🐛 Error Handling

### Failure Types
- **AuthFailure** - Authentication errors (401)
- **ChatFailure** - Chat/messaging errors
- **ServerFailure** - Server errors (500+)
- **CacheFailure** - Local storage errors
- **ApiFailure** - General API errors

### Error Recovery
- Retry buttons on failed states
- Auto-retry with exponential backoff
- Graceful degradation
- User-friendly error messages

## 🔄 State Management

### BLoC Events & States

**Authentication**
- Events: `CheckAuthStatus`, `LoginEvent`, `LogoutEvent`, `RegisterEvent`
- States: `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthError`

**Chat**
- Events: `GetConversationsEvent`, `GetMessagesEvent`, `SendMessageEvent`
- States: `ChatInitial`, `ChatLoading`, `ConversationsLoaded`, `MessagesLoaded`, `ChatError`

**Highlights**
- Events: `GetPlayerHighlightsEvent`, `UploadHighlightEvent`, `ToggleLikeEvent`
- States: `HighlightLoading`, `HighlightLoaded`, `HighlightError`

## 🎯 Key Features Implementation

### Auto-Login
- Reads cached user on app startup
- Restores session without login
- Handles token expiry gracefully

### Internet Connectivity
- Real-time connection detection
- Offline indicator card
- Graceful API fallbacks
- Reconnection handling

### Video Overlay
- Player name display
- Position badge
- Location chip
- Like count
- Verified badge

### Player Profile
- Full stats display
- Ability hexagon visualization
- Match record cards
- Player info grid
- Highlight gallery

## 📄 License

This project is proprietary and owned by Goal Connect.

## 📧 Contact & Support

For issues, feature requests, or support:
- Email: support@goalconnect.app
- GitHub Issues: [Goal Connect Issues](https://github.com/Goal-Connect/goal-connect-mobile/issues)

## 👥 Contributors

- Development Team at Goal Connect

## 🗺️ Roadmap

### Upcoming Features
- [ ] Live streaming support
- [ ] Advanced analytics dashboard
- [ ] AI-powered player recommendations
- [ ] Video comparison tool
- [ ] Payment integration
- [ ] Multi-language support
- [ ] Offline mode enhancements
- [ ] Push notifications

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Library](https://bloclibrary.dev/)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [Socket.IO Documentation](https://socket.io/docs/)

---

**Last Updated**: May 2026
**Version**: 1.0.0
