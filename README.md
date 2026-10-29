# Visitor Management Mobile Application

A clean, modern, and production-ready Flutter mobile application for front-desk and security personnel to register visitors, manage visitor information, generate and scan QR codes, and record real-time visitor check-in and check-out activities across residential and commercial project sites.

---

## 📌 Project Overview
The **Visitor Management App** is built according to practical enterprise requirements:
- **Dashboard**: Real-time count of total visitors today, currently checked-in visitors, and checked-out visitors today, with quick shortcuts to register visitors and scan QR codes.
- **Visitor Registration & Editing**: Comprehensive form with input validations (10-digit mobile number, @gmail.com email validation, visitor types, projects, and purpose).
- **QR Code Generation**: Unique digital QR pass generated using visitor ID upon registration, displayed on visitor details.
- **QR Code Scanning**: Built using mobile_scanner to scan passes and immediately retrieve visitor info for check-in / check-out.
- **Status Workflow**: Strict sequence: Registered -> Checked In -> Checked Out (completed visits cannot check in again; duplicate actions prevented).
- **Reusable Architecture**: Clean component library under lib/widgets/ maintaining modularity.

---

## 🛠️ Technology Stack & Dependencies

| Component | Technology / Package | Purpose |
|---|---|---|
| Framework | Flutter (Dart SDK ^3.12.2) | Cross-platform mobile development |
| State Management | provider (^6.1.5) | Reactive state synchronization across screens |
| Networking | http (^1.6.0) | REST API client for mock CRUD operations |
| QR Code Generation | qr_flutter (^4.1.0) | Rendering high-resolution QR codes from ID |
| QR Code Scanner | mobile_scanner (^7.4.2) | Fast camera-based QR scanning with flashlight & camera switch |
| Date & Time Formatting | intl (^0.20.3) | Clean, localized timestamp formatting |

---

## 📂 Architecture & Project Structure

```
visitor_management_app/
├── lib/
│   ├── core/
│   │   └── constants.dart         # API endpoints & configuration
│   ├── models/
│   │   └── visitor.dart           # Visitor model with JSON serialization
│   ├── providers/
│   │   └── visitor_provider.dart  # Provider for CRUD and status state
│   ├── services/
│   │   └── api_service.dart       # REST API service (GET, POST, PUT, DELETE)
│   ├── screens/
│   │   ├── dashboard.dart         # Operations dashboard & summary cards
│   │   ├── visitor_list.dart      # Directory with search & status filters
│   │   ├── visitor_form.dart      # Registration and editing form
│   │   ├── visitor_details.dart   # QR pass view, timestamps & check-in/out
│   │   ├── qr_scanner.dart        # QR camera scanner
│   │   └── main_navigation_screen.dart # Bottom navigation bar
│   ├── widgets/
│   │   ├── stat_card.dart         # Reusable dashboard metric card
│   │   ├── status_chip.dart       # Reusable status pill widget
│   │   ├── visitor_card.dart      # Reusable visitor record tile
│   │   ├── custom_text_field.dart # Form input with consistent styling
│   │   ├── custom_button.dart     # Primary action button with loading state
│   │   └── state_views.dart       # LoadingView and EmptyStateWidget
│   └── main.dart                  # App entry point & theme setup
└── README.md
```

---

## 🌐 Mock API Information
- **Base URL**: https://6ae029c78e42963c8d5eff23.mockapi.io/visitors-app/visitors
- Persistent storage for GET, POST, PUT, and DELETE operations.

---

## 🚀 Setup & Execution Instructions
1. **Navigate to Project**:
   ```bash
   cd c:\Deepan\visitor_management_app
   ```
2. **Fetch Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Analyze Code**:
   ```bash
   flutter analyze
   ```
4. **Run Application**:
   ```bash
   flutter run
   ```
5. **Build Release APK**:
   ```bash
   flutter build apk --release
   ```

---

## 📋 Features Checklist
- [x] **Dashboard Metrics**: Calculated locally from API records based on today's local date.
- [x] **Form Validations**: Required name & purpose, exactly 10 digits for mobile, optional @gmail.com validation.
- [x] **QR Pass Lifecycle**: Instant QR code rendering on registration; scanner detects pass and opens details.
- [x] **Status Workflow**: Validates transition from Registered -> Checked In -> Checked Out.
- [x] **Delete Confirmation**: Modal dialog before deleting records.
- [x] **Reusable Widgets**: All 6 core reusable components implemented in lib/widgets/.
