# Data Models

This directory contains data models for JSON serialization using `json_serializable`.

## Code Generation

The `.g.dart` files (e.g., `event_model.g.dart`) are generated automatically by `build_runner`.

### Generate Code

Run the following command to generate the serialization code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Watch Mode (Recommended during development)

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

This will automatically regenerate files when you make changes to the models.

## Model Structure

Each model includes:
- JSON serialization annotations
- `fromJson` factory constructor
- `toJson` method
- `toEntity` method (converts to domain entity)
- `fromEntity` factory (converts from domain entity)

## Usage

```dart
// From JSON
final eventModel = EventModel.fromJson(jsonData);
final event = eventModel.toEntity();

// To JSON
final model = EventModel.fromEntity(event);
final json = model.toJson();
```
