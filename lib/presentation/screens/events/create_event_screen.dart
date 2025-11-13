import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/ticket.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/ticket_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Basic Info
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  String? _selectedCategory;

  // Location
  final _locationController = TextEditingController();
  final _venueController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  // Date & Time
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  // Ticketing
  bool _isFree = false;
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _maxTicketsController = TextEditingController(text: '10');

  // Additional
  final _imageUrlController = TextEditingController();
  final _ageRestrictionController = TextEditingController();
  final _dressCodeController = TextEditingController();

  final List<String> _categories = [
    'Music',
    'Sports',
    'Arts',
    'Food',
    'Technology',
    'Business',
    'Education',
    'Entertainment',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _locationController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _maxTicketsController.dispose();
    _imageUrlController.dispose();
    _ageRestrictionController.dispose();
    _dressCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
          ),

          // Step indicator
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Step ${_currentStep + 1} of 5',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoStep(),
                  _buildLocationStep(),
                  _buildDateTimeStep(),
                  _buildTicketingStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
          ),

          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0)
                    const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: FilledButton(
                      onPressed: _currentStep == 4 ? _submitEvent : _nextStep,
                      child: Text(_currentStep == 4 ? 'Create Event' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Event Title *',
              hintText: 'Give your event a catchy title',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an event title';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          // Short Description
          TextFormField(
            controller: _shortDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Short Description *',
              hintText: 'Brief description for listings',
            ),
            maxLength: 200,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a short description';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Full Description *',
              hintText: 'Describe your event in detail',
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          // Category
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category *',
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          // Image URL (for now, later we'll add image picker)
          TextFormField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: 'Event Image URL',
              hintText: 'https://example.com/image.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location Name *',
              hintText: 'e.g., Central Park',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a location';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          TextFormField(
            controller: _venueController,
            decoration: const InputDecoration(
              labelText: 'Venue',
              hintText: 'Specific venue name',
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Street Address',
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City *',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a city';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State/Province',
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              Expanded(
                child: TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date & Time',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Start Date
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Start Date *'),
            subtitle: Text(_startDate != null
                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                : 'Not selected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _startDate = date;
                });
              }
            },
          ),
          const Divider(),

          // Start Time
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: const Text('Start Time *'),
            subtitle: Text(_startTime != null
                ? _startTime!.format(context)
                : 'Not selected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _startTime = time;
                });
              }
            },
          ),
          const Divider(),

          const SizedBox(height: AppDimensions.spacingLarge),

          // End Date
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('End Date *'),
            subtitle: Text(_endDate != null
                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                : 'Not selected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _endDate ?? _startDate ?? DateTime.now(),
                firstDate: _startDate ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _endDate = date;
                });
              }
            },
          ),
          const Divider(),

          // End Time
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: const Text('End Time *'),
            subtitle: Text(_endTime != null
                ? _endTime!.format(context)
                : 'Not selected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _endTime = time;
                });
              }
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTicketingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticketing',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Free Event'),
            subtitle: const Text('No tickets required'),
            value: _isFree,
            onChanged: (value) {
              setState(() {
                _isFree = value;
              });
            },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          if (!_isFree) ...[
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Ticket Price *',
                prefixText: '\$ ',
                hintText: '0.00',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (!_isFree && (value == null || value.isEmpty)) {
                  return 'Please enter a price';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
          ],

          TextFormField(
            controller: _capacityController,
            decoration: const InputDecoration(
              labelText: 'Event Capacity',
              hintText: 'Maximum number of attendees',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          TextFormField(
            controller: _maxTicketsController,
            decoration: const InputDecoration(
              labelText: 'Max Tickets Per Purchase',
              hintText: 'Maximum tickets one person can buy',
              helperText: 'Default: 10 tickets',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final num = int.tryParse(value);
                if (num == null || num < 1) {
                  return 'Please enter a valid number';
                }
                if (num > 50) {
                  return 'Maximum allowed is 50 tickets';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          TextFormField(
            controller: _ageRestrictionController,
            decoration: const InputDecoration(
              labelText: 'Age Restriction',
              hintText: 'e.g., 18+, All ages',
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          TextFormField(
            controller: _dressCodeController,
            decoration: const InputDecoration(
              labelText: 'Dress Code',
              hintText: 'e.g., Casual, Formal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Publish',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleController.text,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(_shortDescriptionController.text),
                  const Divider(height: 32),

                  _buildReviewRow(Icons.category, 'Category', _selectedCategory ?? 'Not set'),
                  _buildReviewRow(Icons.location_on, 'Location', _locationController.text),
                  _buildReviewRow(Icons.calendar_today, 'Date',
                    _startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Not set'),
                  _buildReviewRow(Icons.confirmation_number, 'Price',
                    _isFree ? 'FREE' : '\$${_priceController.text}'),
                  if (_capacityController.text.isNotEmpty)
                    _buildReviewRow(Icons.people, 'Capacity', _capacityController.text),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLarge),

          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: AppDimensions.spacingSmall),
                  Expanded(
                    child: Text(
                      'Your event will be published immediately and visible to all users.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppDimensions.spacingSmall),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep == 2) {
        // Validate date/time selection
        if (_startDate == null || _startTime == null || _endDate == null || _endTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select all dates and times')),
          );
          return;
        }
      }

      setState(() {
        _currentStep++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    // Combine date and time
    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    // Create event entity
    final event = Event(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      shortDescription: _shortDescriptionController.text,
      category: _selectedCategory,
      organizerId: user.id,
      organizerName: user.displayName,
      organizerEmail: user.email,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      venue: _venueController.text.isEmpty ? null : _venueController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      state: _stateController.text.isEmpty ? null : _stateController.text,
      country: _countryController.text.isEmpty ? null : _countryController.text,
      timezone: DateTime.now().timeZoneName,
      startDatetime: startDateTime,
      endDatetime: endDateTime,
      isFree: _isFree,
      minPrice: _isFree ? null : double.tryParse(_priceController.text),
      capacity: int.tryParse(_capacityController.text),
      maxTicketsPerPurchase: int.tryParse(_maxTicketsController.text) ?? 10,
      imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      coverImageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      ageRestriction: _ageRestrictionController.text.isEmpty ? null : _ageRestrictionController.text,
      dressCode: _dressCodeController.text.isEmpty ? null : _dressCodeController.text,
      status: 'published',
      isPublished: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      publishedAt: DateTime.now(),
    );

    // Create event using use case
    final useCase = ref.read(createEventUseCaseProvider);
    final result = await useCase(event);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (createdEvent) async {
        // Automatically create a default ticket type for the event
        await _createDefaultTicketType(createdEvent);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
        context.go('/events/${createdEvent.id}');
      },
    );
  }

  /// Creates a default ticket type for the event
  Future<void> _createDefaultTicketType(Event event) async {
    try {
      final ticketRepository = ref.read(ticketRepositoryProvider);

      // Create ticket type based on event settings
      final ticketType = TicketType(
        id: '', // Will be generated by database
        eventId: event.id,
        name: event.isFree ? 'Free Admission' : 'General Admission',
        description: event.isFree
            ? 'Free entry to the event'
            : 'Standard ticket for event admission',
        price: event.minPrice ?? 0.0,
        totalQuantity: event.capacity ?? 1000,
        availableQuantity: event.capacity ?? 1000,
        minPurchase: 1,
        maxPurchase: event.maxTicketsPerPurchase,
        saleStartDate: DateTime.now(),
        saleEndDate: event.endDatetime,
        isTransferable: true,
        isRefundable: true,
        requiresApproval: false,
        displayOrder: 0,
        status: 'active',
        createdAt: DateTime.now(),
      );

      final result = await ticketRepository.createTicketType(ticketType);

      result.fold(
        (failure) {
          // Log error but don't block event creation
          print('⚠️ Warning: Failed to create default ticket type: ${failure.message}');
        },
        (createdTicketType) {
          print('✅ Successfully created default ticket type: ${createdTicketType.name}');
        },
      );
    } catch (e) {
      // Log error but don't block event creation
      print('⚠️ Error creating default ticket type: $e');
    }
  }
}
