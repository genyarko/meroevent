# Flutter Event App - Best Practices & Optimization Guide
## Performance, Testing, and Deployment Strategies

---

## 1. Flutter Web Optimization

### Build Configuration

```dart
// web/index.html - Optimized loading
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Modern Event & Ticketing Platform">
  
  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Events">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>
  
  <title>Events App</title>
  <link rel="manifest" href="manifest.json">
  
  <!-- Loading indicator -->
  <style>
    .loading {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    .spinner {
      border: 3px solid #f3f3f3;
      border-top: 3px solid #3498db;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <div class="loading" id="loading">
    <div class="spinner"></div>
  </div>
  
  <script>
    // Service Worker for PWA
    if ('serviceWorker' in navigator) {
      window.addEventListener('flutter-first-frame', function () {
        navigator.serviceWorker.register('flutter_service_worker.js');
      });
    }
    
    // Remove loading indicator when Flutter is ready
    window.addEventListener('flutter-first-frame', function () {
      document.getElementById('loading').remove();
    });
  </script>
  
  <!-- Stripe -->
  <script src="https://js.stripe.com/v3/" async></script>
  
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

### Web-Specific Optimizations

```dart
// lib/core/platform/web_optimization.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

class WebOptimization {
  static void initialize() {
    if (kIsWeb) {
      // Use path URL strategy (removes # from URLs)
      usePathUrlStrategy();
      
      // Optimize for web rendering
      _configureWebRenderer();
    }
  }
  
  static void _configureWebRenderer() {
    // Force CanvasKit for better performance on desktop browsers
    // Force HTML renderer for better text rendering on mobile browsers
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      // Use HTML renderer for mobile web
      // Add --web-renderer html to build command
    } else {
      // Use CanvasKit for desktop web
      // Add --web-renderer canvaskit to build command
    }
  }
}

// Build commands
// flutter build web --release --web-renderer canvaskit --tree-shake-icons
// flutter build web --release --web-renderer html --tree-shake-icons
```

---

## 2. Mobile Performance Optimization

### Image Caching Strategy

```dart
// lib/core/services/image_cache_service.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheService {
  static final customCacheManager = CacheManager(
    Config(
      'eventImageCache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
    ),
  );
  
  static Widget cachedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: customCacheManager,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => const _ImagePlaceholder(),
      errorWidget: (context, url, error) => const _ErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }
  
  // Preload images for better UX
  static Future<void> preloadImages(List<String> urls) async {
    for (final url in urls) {
      await customCacheManager.downloadFile(url);
    }
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
```

### List Performance

```dart
// lib/presentation/widgets/optimized_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OptimizedEventList extends ConsumerWidget {
  final List<Event> events;
  
  const OptimizedEventList({super.key, required this.events});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      cacheExtent: 500, // Cache 500 pixels before/after viewport
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Use AutomaticKeepAliveClientMixin for expensive widgets
              return _EventListItem(
                key: ValueKey(events[index].id),
                event: events[index],
              );
            },
            childCount: events.length,
            // Find child index for better scrolling performance
            findChildIndexCallback: (Key key) {
              final ValueKey valueKey = key as ValueKey;
              final String id = valueKey.value as String;
              return events.indexWhere((event) => event.id == id);
            },
          ),
        ),
      ],
    );
  }
}

// For very large lists, use pagination
class PaginatedEventList extends ConsumerStatefulWidget {
  const PaginatedEventList({super.key});
  
  @override
  ConsumerState<PaginatedEventList> createState() => _PaginatedEventListState();
}

class _PaginatedEventListState extends ConsumerState<PaginatedEventList> {
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_isLoadingMore) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (currentScroll >= maxScroll * 0.9) {
      _loadMore();
    }
  }
  
  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    
    await ref.read(eventsProvider.notifier).loadMoreEvents(
      page: ++_currentPage,
      pageSize: _pageSize,
    );
    
    setState(() => _isLoadingMore = false);
  }
  
  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    
    return ListView.builder(
      controller: _scrollController,
      itemCount: events.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == events.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return EventCard(event: events[index]);
      },
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 3. State Management Best Practices

### Riverpod Architecture

```dart
// lib/presentation/providers/base_state_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_state_notifier.freezed.dart';

@freezed
class BaseState<T> with _$BaseState<T> {
  const factory BaseState.initial() = _Initial;
  const factory BaseState.loading() = _Loading;
  const factory BaseState.loaded(T data) = _Loaded<T>;
  const factory BaseState.error(String message) = _Error;
}

abstract class BaseStateNotifier<T> extends StateNotifier<BaseState<T>> {
  BaseStateNotifier() : super(const BaseState.initial());
  
  Future<void> performAction(Future<T> Function() action) async {
    state = const BaseState.loading();
    try {
      final result = await action();
      state = BaseState.loaded(result);
    } catch (e) {
      state = BaseState.error(e.toString());
    }
  }
}

// Usage example
class EventDetailNotifier extends BaseStateNotifier<Event> {
  final EventRepository _repository;
  
  EventDetailNotifier(this._repository) : super();
  
  Future<void> loadEvent(String id) async {
    await performAction(() => _repository.getEventById(id));
  }
  
  Future<void> updateEvent(Event event) async {
    await performAction(() async {
      await _repository.updateEvent(event);
      return event;
    });
  }
}
```

### Provider Organization

```dart
// lib/presentation/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// Use Riverpod Generator for better type safety
@riverpod
class EventList extends _$EventList {
  @override
  Future<List<Event>> build() async {
    final repository = ref.watch(eventRepositoryProvider);
    return repository.getEvents();
  }
  
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
  
  Future<void> addEvent(Event event) async {
    final repository = ref.watch(eventRepositoryProvider);
    await repository.createEvent(event);
    ref.invalidateSelf();
  }
}

// Filtered events with caching
@riverpod
Future<List<Event>> filteredEvents(
  FilteredEventsRef ref, {
  String? category,
  String? search,
}) async {
  final events = await ref.watch(eventListProvider.future);
  
  return events.where((event) {
    if (category != null && event.category != category) return false;
    if (search != null && !event.title.contains(search)) return false;
    return true;
  }).toList();
}

// Family provider for event details
@riverpod
Future<Event> eventDetail(EventDetailRef ref, String id) async {
  final repository = ref.watch(eventRepositoryProvider);
  
  // Cache for 5 minutes
  ref.keepAlive();
  Timer(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });
  
  return repository.getEventById(id);
}
```

---

## 4. Testing Strategy

### Unit Tests

```dart
// test/domain/usecases/purchase_ticket_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([TicketRepository, PaymentService])
import 'purchase_ticket_test.mocks.dart';

void main() {
  late PurchaseTicketUseCase useCase;
  late MockTicketRepository mockRepository;
  late MockPaymentService mockPaymentService;
  
  setUp(() {
    mockRepository = MockTicketRepository();
    mockPaymentService = MockPaymentService();
    useCase = PurchaseTicketUseCase(mockRepository, mockPaymentService);
  });
  
  group('PurchaseTicketUseCase', () {
    test('should purchase ticket successfully', () async {
      // Arrange
      const ticketTypeId = 'ticket-123';
      const quantity = 2;
      final expectedOrder = TicketOrder(
        id: 'order-123',
        ticketTypeId: ticketTypeId,
        quantity: quantity,
        totalAmount: 100.0,
      );
      
      when(mockRepository.checkAvailability(ticketTypeId, quantity))
          .thenAnswer((_) async => true);
      when(mockPaymentService.processPayment(any))
          .thenAnswer((_) async => PaymentResult.success('payment-123'));
      when(mockRepository.createOrder(any))
          .thenAnswer((_) async => expectedOrder);
      
      // Act
      final result = await useCase.execute(
        ticketTypeId: ticketTypeId,
        quantity: quantity,
      );
      
      // Assert
      expect(result, equals(expectedOrder));
      verify(mockRepository.checkAvailability(ticketTypeId, quantity)).called(1);
      verify(mockPaymentService.processPayment(any)).called(1);
      verify(mockRepository.createOrder(any)).called(1);
    });
    
    test('should throw exception when tickets unavailable', () async {
      // Arrange
      when(mockRepository.checkAvailability(any, any))
          .thenAnswer((_) async => false);
      
      // Act & Assert
      expect(
        () => useCase.execute(ticketTypeId: 'ticket-123', quantity: 5),
        throwsA(isA<TicketsUnavailableException>()),
      );
    });
  });
}
```

### Widget Tests

```dart
// test/presentation/widgets/event_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  group('EventCard', () {
    testWidgets('displays event information correctly', (tester) async {
      // Arrange
      final event = Event(
        id: '1',
        title: 'Flutter Conference',
        startDateTime: DateTime(2024, 6, 15, 10, 0),
        location: 'San Francisco',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );
      
      // Act
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: EventCard(event: event),
              ),
            ),
          ),
        );
      });
      
      // Assert
      expect(find.text('Flutter Conference'), findsOneWidget);
      expect(find.text('San Francisco'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
    });
    
    testWidgets('navigates to detail on tap', (tester) async {
      // Arrange
      final event = Event(id: '1', title: 'Test Event');
      final navigatorKey = GlobalKey<NavigatorState>();
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: Scaffold(body: EventCard(event: event)),
            routes: {
              '/events/1': (_) => const Text('Event Detail'),
            },
          ),
        ),
      );
      
      await tester.tap(find.byType(EventCard));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Event Detail'), findsOneWidget);
    });
  });
}
```

### Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_event_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('End-to-end test', () {
    testWidgets('complete ticket purchase flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to events
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      
      // Select first event
      await tester.tap(find.byType(EventCard).first);
      await tester.pumpAndSettle();
      
      // Buy tickets
      await tester.tap(find.text('Buy Tickets'));
      await tester.pumpAndSettle();
      
      // Select quantity
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();
      
      // Proceed to payment
      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();
      
      // Verify on payment screen
      expect(find.text('Payment'), findsOneWidget);
    });
  });
}
```

---

## 5. Deployment Configuration

### Android Release

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.eventapp"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

// Enable R8 for better optimization
android.enableR8=true
```

### iOS Release

```ruby
# ios/Podfile
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      
      # Optimize for size
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
      config.build_settings['GCC_OPTIMIZATION_LEVEL'] = 's'
    end
  end
end
```

### CI/CD with GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy Event App

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Check formatting
        run: dart format --set-exit-if-changed .
      
      - name: Analyze
        run: flutter analyze

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
      
      - name: Archive
        run: |
          cd ios
          xcodebuild -workspace Runner.xcworkspace \
            -scheme Runner \
            -sdk iphoneos \
            -configuration Release \
            -archivePath Runner.xcarchive \
            archive

  build-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Build Web
        run: flutter build web --release --web-renderer canvaskit
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          working-directory: ./build/web
```

---

## 6. Monitoring & Analytics

### Error Tracking with Sentry

```dart
// lib/core/monitoring/sentry_service.dart
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static Future<void> initialize() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = 'YOUR_SENTRY_DSN';
        options.environment = kDebugMode ? 'development' : 'production';
        options.tracesSampleRate = 1.0;
        options.attachScreenshot = true;
        options.attachViewHierarchy = true;
        
        // Performance monitoring
        options.enableAutoPerformanceTracing = true;
      },
    );
  }
  
  static void captureException(dynamic exception, {dynamic stackTrace}) {
    Sentry.captureException(exception, stackTrace: stackTrace);
  }
  
  static void addBreadcrumb(String message, {Map<String, dynamic>? data}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        data: data,
        timestamp: DateTime.now(),
      ),
    );
  }
}

// Usage in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SentryService.initialize();
  
  runApp(
    SentryWidget(
      child: ProviderScope(
        observers: [ErrorLoggingObserver()],
        child: const EventApp(),
      ),
    ),
  );
}
```

### Analytics with PostHog

```dart
// lib/core/analytics/analytics_service.dart
import 'package:posthog_flutter/posthog_flutter.dart';

class AnalyticsService {
  static final Posthog _posthog = Posthog();
  
  static Future<void> initialize() async {
    await _posthog.setup(
      apiKey: 'YOUR_POSTHOG_API_KEY',
      host: 'https://app.posthog.com',
    );
    
    // Enable session recording for web
    if (kIsWeb) {
      await _posthog.startSessionRecording();
    }
  }
  
  static void trackEvent(String eventName, {Map<String, dynamic>? properties}) {
    _posthog.capture(
      eventName: eventName,
      properties: properties ?? {},
    );
  }
  
  static void identifyUser(String userId, {Map<String, dynamic>? properties}) {
    _posthog.identify(
      userId: userId,
      userProperties: properties,
    );
  }
  
  static void trackScreen(String screenName) {
    _posthog.screen(
      screenName: screenName,
    );
  }
}

// Track key events
AnalyticsService.trackEvent('ticket_purchased', {
  'event_id': eventId,
  'quantity': quantity,
  'total_amount': amount,
  'payment_method': paymentMethod,
});
```

---

## 7. Common Pitfalls & Solutions

### Memory Leaks Prevention

```dart
// Always dispose controllers and listeners
class _EventDetailScreenState extends State<EventDetailScreen> {
  late final StreamSubscription _subscription;
  late final ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _subscription = eventStream.listen((event) {
      // Handle event
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}

// Use AutoDisposeProvider for Riverpod
final temporaryDataProvider = Provider.autoDispose<String>((ref) {
  // This will be disposed when no longer used
  return 'temporary data';
});
```

### Platform-Specific Code

```dart
// lib/core/platform/platform_service.dart
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class PlatformService {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  static T select<T>({
    required T mobile,
    required T web,
    T? desktop,
  }) {
    if (isWeb) return web;
    if (isDesktop) return desktop ?? web;
    return mobile;
  }
}

// Usage
final apiUrl = PlatformService.select(
  mobile: 'https://api.example.com',
  web: 'https://cors-proxy.example.com/api',
);
```

---

This Flutter implementation guide provides comprehensive best practices for building a high-performance, cross-platform event app with a single codebase. The architecture ensures optimal performance across web, iOS, and Android while maintaining code quality and testability.
