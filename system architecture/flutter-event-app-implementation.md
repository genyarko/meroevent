# Flutter Event App Implementation Guide
## Single Codebase for Web & Mobile with Flutter

---

## 1. Updated Technology Stack

### Frontend (Flutter-Focused)
```yaml
Flutter Applications:
  Framework: Flutter 3.24+
  Dart: 3.5+
  
  Core Packages:
    State Management: 
      - riverpod: ^2.5.0
      - flutter_bloc: ^8.1.0 (alternative)
    
    Supabase Integration:
      - supabase_flutter: ^2.5.0
      - gotrue: ^2.8.0
    
    UI/UX:
      - flutter_animate: ^4.5.0
      - animations: ^2.0.0
      - google_fonts: ^6.2.0
      - flutter_svg: ^2.0.0
      - cached_network_image: ^3.3.0
    
    Navigation:
      - go_router: ^14.0.0
      - auto_route: ^8.0.0 (alternative)
    
    Forms & Validation:
      - reactive_forms: ^17.0.0
      - flutter_form_builder: ^9.2.0
    
    Maps:
      - flutter_map: ^6.1.0
      - mapbox_maps_flutter: ^2.0.0
      - geolocator: ^11.0.0
    
    Calendar:
      - table_calendar: ^3.1.0
      - syncfusion_flutter_calendar: ^25.0.0
    
    Payments:
      - flutter_stripe: ^10.1.0
      - pay: ^2.0.0 (Apple/Google Pay)
    
    QR Code:
      - qr_flutter: ^4.1.0
      - mobile_scanner: ^5.0.0
      - qr_code_scanner: ^1.0.1
    
    Charts & Analytics:
      - fl_chart: ^0.68.0
      - syncfusion_flutter_charts: ^25.0.0
    
    Platform Specific:
      - flutter_local_notifications: ^17.0.0
      - permission_handler: ^11.3.0
      - share_plus: ^8.0.0
      - url_launcher: ^6.2.0
      - image_picker: ^1.0.0
      
Admin Dashboard:
  Option 1: Flutter Web (same codebase)
  Option 2: Next.js + Ant Design Pro (better for complex admin)
```

---

## 2. Flutter Project Structure

```
flutter_event_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── config/
│   │   │   ├── supabase_config.dart
│   │   │   ├── stripe_config.dart
│   │   │   └── environment.dart
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_dimensions.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── utils/
│   │   │   ├── formatters.dart
│   │   │   ├── validators.dart
│   │   │   └── extensions.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       └── responsive.dart
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── event_remote_datasource.dart
│   │   │   │   ├── ticket_remote_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   └── local/
│   │   │       ├── cache_datasource.dart
│   │   │       └── secure_storage.dart
│   │   ├── models/
│   │   │   ├── event_model.dart
│   │   │   ├── ticket_model.dart
│   │   │   ├── user_model.dart
│   │   │   └── venue_model.dart
│   │   └── repositories/
│   │       ├── event_repository_impl.dart
│   │       ├── ticket_repository_impl.dart
│   │       └── auth_repository_impl.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── event.dart
│   │   │   ├── ticket.dart
│   │   │   ├── user.dart
│   │   │   └── venue.dart
│   │   ├── repositories/
│   │   │   ├── event_repository.dart
│   │   │   ├── ticket_repository.dart
│   │   │   └── auth_repository.dart
│   │   └── usecases/
│   │       ├── events/
│   │       │   ├── get_events_usecase.dart
│   │       │   ├── create_event_usecase.dart
│   │       │   └── search_events_usecase.dart
│   │       └── tickets/
│   │           ├── purchase_ticket_usecase.dart
│   │           └── validate_ticket_usecase.dart
│   │
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── event_provider.dart
│   │   │   └── ticket_provider.dart
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── events/
│   │   │   │   ├── event_list_screen.dart
│   │   │   │   ├── event_detail_screen.dart
│   │   │   │   ├── create_event_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── tickets/
│   │   │   │   ├── ticket_purchase_screen.dart
│   │   │   │   ├── my_tickets_screen.dart
│   │   │   │   ├── ticket_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── widgets/
│   │   │   └── profile/
│   │   │       ├── profile_screen.dart
│   │   │       └── settings_screen.dart
│   │   ├── widgets/
│   │   │   ├── common/
│   │   │   │   ├── app_button.dart
│   │   │   │   ├── app_text_field.dart
│   │   │   │   ├── loading_widget.dart
│   │   │   │   └── error_widget.dart
│   │   │   └── cards/
│   │   │       ├── event_card.dart
│   │   │       ├── ticket_card.dart
│   │   │       └── venue_card.dart
│   │   └── router/
│   │       ├── app_router.dart
│   │       └── route_guards.dart
│   │
│   └── l10n/
│       ├── app_en.arb
│       └── app_es.arb
│
├── web/
│   └── index.html
├── android/
├── ios/
├── windows/
├── macos/
├── linux/
├── test/
├── pubspec.yaml
└── README.md
```

---

## 3. Core Implementation Files

### 3.1 Main App Setup

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/config/environment.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );
  
  // Initialize Stripe
  Stripe.publishableKey = Environment.stripePublishableKey;
  await Stripe.instance.applySettings();
  
  runApp(
    const ProviderScope(
      child: EventApp(),
    ),
  );
}

// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/router/app_router.dart';
import 'core/theme/app_theme.dart';

class EventApp extends ConsumerWidget {
  const EventApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Events App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
    );
  }
}
```

### 3.2 Supabase Integration

```dart
// core/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
  
  static User? get currentUser => client.auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;
  
  static Stream<AuthState> get authStateChanges => 
      client.auth.onAuthStateChange;
}

// data/datasources/remote/event_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event_model.dart';
import '../../../core/config/supabase_config.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents({
    String? category,
    String? search,
    double? latitude,
    double? longitude,
    int? radius,
  });
  
  Future<EventModel> getEventById(String id);
  Future<EventModel> createEvent(EventModel event);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final SupabaseClient _client = SupabaseConfig.client;
  
  @override
  Future<List<EventModel>> getEvents({
    String? category,
    String? search,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    var query = _client
        .from('events')
        .select('*, venues(*), organizer:profiles!organizer_id(*)');
    
    if (category != null) {
      query = query.eq('category', category);
    }
    
    if (search != null && search.isNotEmpty) {
      query = query.textSearch('search_vector', search);
    }
    
    if (latitude != null && longitude != null) {
      // Use PostGIS function for nearby events
      final response = await _client
          .rpc('nearby_events', params: {
            'lat': latitude,
            'lng': longitude,
            'radius_km': radius ?? 10,
          });
      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    }
    
    final response = await query;
    return (response as List)
        .map((json) => EventModel.fromJson(json))
        .toList();
  }
  
  @override
  Future<EventModel> getEventById(String id) async {
    final response = await _client
        .from('events')
        .select('*, venues(*), organizer:profiles!organizer_id(*)')
        .eq('id', id)
        .single();
    
    return EventModel.fromJson(response);
  }
  
  @override
  Future<EventModel> createEvent(EventModel event) async {
    final response = await _client
        .from('events')
        .insert(event.toJson())
        .select()
        .single();
    
    return EventModel.fromJson(response);
  }
  
  @override
  Future<void> updateEvent(EventModel event) async {
    await _client
        .from('events')
        .update(event.toJson())
        .eq('id', event.id);
  }
  
  @override
  Future<void> deleteEvent(String id) async {
    await _client
        .from('events')
        .delete()
        .eq('id', id);
  }
}
```

### 3.3 State Management with Riverpod

```dart
// presentation/providers/event_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/events/get_events_usecase.dart';

// Repository Provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(
    remoteDataSource: EventRemoteDataSourceImpl(),
  );
});

// Use Case Providers
final getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  return GetEventsUseCase(ref.watch(eventRepositoryProvider));
});

// State Notifier for Events
class EventsNotifier extends StateNotifier<AsyncValue<List<Event>>> {
  final GetEventsUseCase _getEventsUseCase;
  
  EventsNotifier(this._getEventsUseCase) : super(const AsyncValue.loading()) {
    loadEvents();
  }
  
  Future<void> loadEvents({
    String? category,
    String? search,
    double? latitude,
    double? longitude,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final events = await _getEventsUseCase.execute(
        category: category,
        search: search,
        latitude: latitude,
        longitude: longitude,
      );
      state = AsyncValue.data(events);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  void filterByCategory(String category) {
    loadEvents(category: category);
  }
  
  void searchEvents(String query) {
    loadEvents(search: query);
  }
  
  void loadNearbyEvents(double lat, double lng) {
    loadEvents(latitude: lat, longitude: lng);
  }
}

// Events Provider
final eventsProvider = 
    StateNotifierProvider<EventsNotifier, AsyncValue<List<Event>>>((ref) {
  return EventsNotifier(ref.watch(getEventsUseCaseProvider));
});

// Selected Event Provider
final selectedEventProvider = FutureProvider.family<Event, String>((ref, id) async {
  final repository = ref.watch(eventRepositoryProvider);
  return await repository.getEventById(id);
});

// User's Events Provider
final userEventsProvider = StreamProvider<List<Event>>((ref) {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return Stream.value([]);
  
  return SupabaseConfig.client
      .from('events')
      .stream(primaryKey: ['id'])
      .eq('organizer_id', userId)
      .map((data) => data.map((json) => Event.fromJson(json)).toList());
});
```

### 3.4 Event List Screen

```dart
// presentation/screens/events/event_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/event_provider.dart';
import '../../widgets/cards/event_card.dart';
import '../../widgets/common/loading_widget.dart';

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  final ScrollController _scrollController = ScrollController();
  String? selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar with Search
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Discover Events'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/events_header.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    ref.read(eventsProvider.notifier).searchEvents(value);
                  },
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5),
            ),
          ),
          
          // Category Filters
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: selectedCategory == null,
                    onTap: () {
                      setState(() => selectedCategory = null);
                      ref.read(eventsProvider.notifier).loadEvents();
                    },
                  ),
                  _CategoryChip(
                    label: 'Concerts',
                    icon: Icons.music_note,
                    selected: selectedCategory == 'concert',
                    onTap: () => _selectCategory('concert'),
                  ),
                  _CategoryChip(
                    label: 'Sports',
                    icon: Icons.sports_soccer,
                    selected: selectedCategory == 'sports',
                    onTap: () => _selectCategory('sports'),
                  ),
                  _CategoryChip(
                    label: 'Conferences',
                    icon: Icons.business,
                    selected: selectedCategory == 'conference',
                    onTap: () => _selectCategory('conference'),
                  ),
                  _CategoryChip(
                    label: 'Workshops',
                    icon: Icons.school,
                    selected: selectedCategory == 'workshop',
                    onTap: () => _selectCategory('workshop'),
                  ),
                ]
                    .animate(interval: 100.ms)
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: 0.2),
              ),
            ),
          ),
          
          // Events Grid
          eventsAsync.when(
            loading: () => const SliverFillRemaining(
              child: LoadingWidget(),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading events',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(error.toString()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(eventsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (events) => events.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text('No events found'),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return EventCard(event: events[index])
                              .animate()
                              .fadeIn(
                                delay: (100 * index).ms,
                                duration: 500.ms,
                              )
                              .slideY(
                                begin: 0.2,
                                duration: 500.ms,
                              );
                        },
                        childCount: events.length,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      
      // Floating Action Button for Creating Events
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/events/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.5, 0.5)),
    );
  }
  
  void _selectCategory(String category) {
    setState(() => selectedCategory = category);
    ref.read(eventsProvider.notifier).filterByCategory(category);
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  
  const _CategoryChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
```

### 3.5 Ticket Purchase with Stripe

```dart
// presentation/screens/tickets/ticket_purchase_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../providers/ticket_provider.dart';

class TicketPurchaseScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String ticketTypeId;
  
  const TicketPurchaseScreen({
    super.key,
    required this.eventId,
    required this.ticketTypeId,
  });

  @override
  ConsumerState<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends ConsumerState<TicketPurchaseScreen> {
  int quantity = 1;
  bool isProcessing = false;
  
  @override
  Widget build(BuildContext context) {
    final ticketTypeAsync = ref.watch(ticketTypeProvider(widget.ticketTypeId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Tickets'),
      ),
      body: ticketTypeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (ticketType) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticketType.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(ticketType.description),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${ticketType.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            '${ticketType.availableQuantity} available',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quantity Selector
              Row(
                children: [
                  const Text('Quantity:'),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: quantity > 1
                        ? () => setState(() => quantity--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$quantity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: quantity < ticketType.maxPurchase
                        ? () => setState(() => quantity++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Order Summary
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Subtotal',
                        value: '\$${(ticketType.price * quantity).toStringAsFixed(2)}',
                      ),
                      const _SummaryRow(
                        label: 'Service Fee',
                        value: '\$5.00',
                      ),
                      const Divider(),
                      _SummaryRow(
                        label: 'Total',
                        value: '\$${(ticketType.price * quantity + 5).toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Purchase Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _handlePurchase,
                  child: isProcessing
                      ? const CircularProgressIndicator()
                      : const Text('Proceed to Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _handlePurchase() async {
    setState(() => isProcessing = true);
    
    try {
      // Create payment intent on backend
      final paymentIntent = await ref
          .read(ticketServiceProvider)
          .createPaymentIntent(
            ticketTypeId: widget.ticketTypeId,
            quantity: quantity,
          );
      
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: 'Event App',
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
        ),
      );
      
      // Show payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      // Payment successful
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/tickets/success',
          arguments: paymentIntent.orderId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final textStyle = isBold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )
        : Theme.of(context).textTheme.bodyLarge;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}
```

### 3.6 QR Code Scanner (Mobile)

```dart
// presentation/screens/tickets/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  bool isProcessing = false;
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ticket'),
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
          ),
          IconButton(
            onPressed: () => controller.switchCamera(),
            icon: const Icon(Icons.camera_front),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!isProcessing) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _validateTicket(barcode.rawValue!);
                    break;
                  }
                }
              }
            },
          ),
          
          // Scanning overlay
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Point camera at QR code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Future<void> _validateTicket(String qrCode) async {
    setState(() => isProcessing = true);
    
    try {
      final result = await ref
          .read(ticketValidationServiceProvider)
          .validateTicket(qrCode);
      
      if (result.isValid) {
        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              title: const Text('Valid Ticket'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ticket: ${result.ticketNumber}'),
                  Text('Name: ${result.attendeeName}'),
                  Text('Type: ${result.ticketType}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => isProcessing = false);
                  },
                  child: const Text('Scan Next'),
                ),
              ],
            ),
          );
        }
      } else {
        // Show error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              icon: const Icon(
                Icons.error,
                color: Colors.red,
                size: 64,
              ),
              title: const Text('Invalid Ticket'),
              content: Text(result.message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => isProcessing = false);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => isProcessing = false);
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    
    final cutoutSize = size.width * 0.7;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );
    
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12))),
      ),
      paint,
    );
    
    // Draw corner indicators
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final cornerLength = 30.0;
    
    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.top + cornerLength)
        ..lineTo(cutoutRect.left, cutoutRect.top)
        ..lineTo(cutoutRect.left + cornerLength, cutoutRect.top),
      cornerPaint,
    );
    
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right - cornerLength, cutoutRect.top)
        ..lineTo(cutoutRect.right, cutoutRect.top)
        ..lineTo(cutoutRect.right, cutoutRect.top + cornerLength),
      cornerPaint,
    );
    
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.bottom - cornerLength)
        ..lineTo(cutoutRect.left, cutoutRect.bottom)
        ..lineTo(cutoutRect.left + cornerLength, cutoutRect.bottom),
      cornerPaint,
    );
    
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right - cornerLength, cutoutRect.bottom)
        ..lineTo(cutoutRect.right, cutoutRect.bottom)
        ..lineTo(cutoutRect.right, cutoutRect.bottom - cornerLength),
      cornerPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## 4. Platform-Specific Configurations

### 4.1 Web Configuration

```dart
// web/index.html additions
<script src="https://js.stripe.com/v3/"></script>
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_KEY"></script>

// lib/main_web.dart
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  usePathUrlStrategy(); // Remove # from URLs
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeWeb();
  runApp(const ProviderScope(child: EventApp()));
}

Future<void> initializeWeb() async {
  // Web-specific initialization
}
```

### 4.2 Mobile Permissions

```yaml
# ios/Runner/Info.plist
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show nearby events</string>

# android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 5. Responsive Design

```dart
// core/theme/responsive.dart
import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    if (size.width >= 1100) {
      return desktop;
    } else if (size.width >= 650 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

// Usage in screens
class EventListResponsive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: EventListMobile(),
      tablet: EventListTablet(),
      desktop: EventListDesktop(),
    );
  }
}
```

---

## 6. Package Dependencies

```yaml
# pubspec.yaml
name: flutter_event_app
description: Modern event app with ticketing

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
    
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # Supabase
  supabase_flutter: ^2.5.0
  
  # Navigation
  go_router: ^14.0.0
  
  # UI/UX
  flutter_animate: ^4.5.0
  animations: ^2.0.0
  google_fonts: ^6.2.0
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  
  # Forms
  reactive_forms: ^17.0.0
  
  # Maps
  flutter_map: ^6.1.0
  geolocator: ^11.0.0
  geocoding: ^3.0.0
  
  # Calendar
  table_calendar: ^3.1.0
  
  # Payments
  flutter_stripe: ^10.1.0
  pay: ^2.0.0
  
  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^5.0.0
  
  # Charts
  fl_chart: ^0.68.0
  
  # Platform
  flutter_local_notifications: ^17.0.0
  permission_handler: ^11.3.0
  share_plus: ^8.0.0
  url_launcher: ^6.2.0
  image_picker: ^1.0.0
  path_provider: ^2.1.0
  
  # Utilities
  intl: ^0.19.0
  collection: ^1.18.0
  equatable: ^2.0.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  dio: ^5.4.0
  
  # Storage
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.2.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
  
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

---

This Flutter implementation provides:
- **Single codebase** for web, iOS, and Android
- **Responsive design** that adapts to all screen sizes
- **Native performance** with platform-specific optimizations
- **Rich animations** using Flutter's animation framework
- **Complete Supabase integration** with real-time features
- **State management** with Riverpod for scalability
- **Full ticketing system** with QR code generation and scanning
- **Stripe payments** integration
- **Offline support** for tickets

The architecture maintains all the backend components from the original design while providing a unified Flutter frontend that can run on all platforms.
