# Cultural Event Management App

A Flutter application for managing cultural events with comprehensive expense tracking functionality.

## Features

### Event Management
- **Add Events**: Create cultural events with details like name, description, date, venue, and organizer
- **View Events**: See all events in an organized list with key information
- **Event Details**: View complete event information and associated expenses

### Expense Tracking
- **Add Expenses**: Track expenses for each event with the following details:
  - Expense title
  - Amount (₹)
  - Vendor name
  - Category (Venue, Food & Beverages, Decoration, Sound & Lighting, Entertainment, Transportation, Marketing, Security, Photography, Others)
  - Date
  - Optional description
- **View Expenses**: See all expenses associated with each event
- **Delete Expenses**: Remove expenses with confirmation dialog
- **Budget Summary**: View total expenses for each event and overall budget

### User Interface
- **Clean Design**: Modern Material Design 3 interface
- **Intuitive Navigation**: Easy-to-use navigation between screens
- **Visual Feedback**: Success/error messages and confirmation dialogs
- **Responsive Layout**: Works on different screen sizes

## App Structure

### Screens
1. **Home Screen**: Dashboard showing events overview and summary
2. **Add Event Screen**: Form to create new events
3. **Event Details Screen**: Detailed view of event with expense management
4. **Add Expense Screen**: Form to add expenses to events

### Models
- **Event**: Represents a cultural event with all its details
- **Expense**: Represents an expense item with vendor and category information
- **ExpenseCategory**: Predefined categories for expenses

### State Management
- Uses Provider pattern for state management
- **EventProvider**: Manages all events and expenses data

## How to Use

1. **Adding an Event**:
   - Tap the "+" button on the home screen
   - Fill in event details (name, description, date, venue, organizer)
   - Tap "Create Event"

2. **Adding Expenses**:
   - Tap on an event from the home screen
   - Tap "Add Expense" button
   - Fill in expense details (title, amount, vendor, category, date)
   - Tap "Add Expense"

3. **Managing Expenses**:
   - View all expenses in the event details screen
   - Delete expenses by tapping the delete icon
   - See budget summary with total expenses

## Technologies Used

- **Flutter**: Cross-platform mobile development framework
- **Provider**: State management solution
- **Material Design 3**: Google's design system for UI components

## Installation

1. Ensure Flutter SDK is installed on your system
2. Clone or download the project
3. Navigate to the project directory
4. Run `flutter pub get` to install dependencies
5. Run `flutter run` to start the app

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.0.5
```

This app provides a complete solution for managing cultural events and tracking their associated expenses, making it perfect for event organizers, cultural committees, and anyone planning cultural activities.
