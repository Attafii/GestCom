# GestCom - Flutter Windows Desktop Application

A modern business management system built with Flutter for Windows desktop.

## Features

- **Client Management**: Complete CRUD operations for client data
- **Responsive Design**: Optimized for Windows desktop with resizable layouts
- **State Management**: Powered by Riverpod for efficient state handling
- **Local Database**: Hive for fast, local data storage
- **Professional UI**: Material Design 3 with custom color scheme

## Tech Stack

- **Framework**: Flutter 3.19+
- **Language**: Dart 3.x
- **State Management**: Riverpod
- **Database**: Hive with TypeAdapters
- **UI Components**: DataTable2 for advanced tables
- **Platform**: Windows Desktop

## Getting Started

### Prerequisites

- Flutter SDK 3.19 or later
- Windows 10/11
- VS Code with Flutter extension

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd gestcom
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (TypeAdapters & Riverpod providers)**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```
   
   Or run the batch file:
   ```bash
   generate.bat
   ```

4. **Enable Windows desktop**
   ```bash
   flutter config --enable-windows-desktop
   ```

5. **Run the application**
   ```bash
   flutter run -d windows
   ```

## Project Structure

```
lib/
├── main.dart                     # Application entry point
├── app/
│   └── app.dart                 # Main app configuration
├── core/
│   └── constants/               # App colors, strings, themes
├── data/
│   ├── models/                  # Hive models with TypeAdapters
│   └── repositories/            # Data access layer
├── features/
│   ├── client/                  # Client management feature
│   │   ├── application/         # Riverpod providers
│   │   └── presentation/        # UI screens and widgets
│   ├── home/                    # Main navigation and layout
│   └── navigation/              # Side navigation drawer
└── services/                    # External services (PDF, Excel)
```

## Features Implemented

### ✅ Client Management
- **Add Client**: Form dialog with validation
- **Edit Client**: Update existing client data
- **Delete Client**: Confirmation dialog with safe deletion
- **Search**: Real-time search by name, matricule fiscal, phone, email
- **Data Table**: Responsive table with sorting and pagination
- **Validation**: Email format, phone format, unique matricule fiscal

### ✅ Navigation
- **Side Drawer**: Responsive navigation with all modules
- **Page Routing**: Clean navigation between features
- **Professional UI**: Consistent design throughout the app

### ✅ Data Persistence
- **Hive Database**: Local storage with TypeAdapters
- **Repository Pattern**: Clean data access layer
- **State Management**: Riverpod for reactive UI updates

## UI Guidelines

- **Primary Color**: Blue (#1976D2) - Headers and primary buttons
- **Success Color**: Green (#388E3C) - Validation and success actions
- **Error Color**: Red (#D32F2F) - Errors and deletion actions
- **Background**: Light grey (#F5F5F5) for comfortable viewing
- **Text**: Dark grey (#212121) for excellent readability

## Development Guidelines

### Adding New Features

1. Create feature folder in `lib/features/`
2. Follow the pattern: `application/` (providers) + `presentation/` (UI)
3. Create Hive model in `lib/data/models/` with TypeAdapter
4. Add repository in `lib/data/repositories/`
5. Create Riverpod providers for state management
6. Build responsive UI with consistent styling

### Code Generation

When you modify Hive models or Riverpod providers:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Building for Release

```bash
flutter build windows --release
```

## Next Steps

The application is set up with a solid foundation. Next features to implement:

1. **Articles Management** - Product/service catalog
2. **Reception Module** - Goods receipt tracking
3. **Delivery Module** - Delivery note generation
4. **PDF Generation** - Export delivery notes and reports
5. **Excel Export** - Data export functionality
6. **Inventory Management** - Stock tracking and reporting

## Database Location

The Hive database is stored in:
```
%USERPROFILE%\Documents\GestCom\data\
```

## Support

For issues or questions, please check the development documentation in `Developmentprocess.md`.

---

**Version**: 1.0.0  
**Author**: Generated with Flutter & GitHub Copilot  
**Platform**: Windows Desktop