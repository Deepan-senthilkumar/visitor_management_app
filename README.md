# Visitor Management App

A Flutter mobile application created for front-desk and security staff to manage visitors across residential and commercial projects. It handles visitor registration, QR code generation, camera scanning, check-in/check-out tracking, and real-time dashboard statistics.

---

## About the Project

The app is built for a scenario where visitors (customers, vendors, etc.) visit different sites like Project A, Project B, or Project C. 

The goal was to build a clean and fast mobile app that allows:
- Registering a new visitor and immediately getting a QR pass.
- Scanning visitor QR passes with the device camera to check them in and out.
- Keeping track of who is currently on-site and who has completed their visit.
- Viewing live stats on the dashboard calculated from API data.

---

## Features

- **Dashboard**:
  - Shows total visitors registered today, currently checked-in visitors, and checked-out visitors today.
  - Tapping on any of the stat cards takes you directly to the Visitors list with that specific filter active (Today Registered, Checked In, or Checked Out).
  - Quick action buttons to register a visitor or open the scanner.
  - Shows the 5 most recent visitors.
  - Pull to refresh to reload data from the API.

- **Visitor Registration & Edit**:
  - Name (required).
  - Mobile number (strictly validated to 10 digits).
  - Email (optional, validated using standard email regex if entered).
  - Visitor type dropdown (Customer, Vendor, Other).
  - Project dropdown (Project A, Project B, Project C).
  - Purpose of visit (required).
  - Cancel button to go back and Save button to submit.
  - Redirects straight to the Visitor Details page with their QR pass on successful registration.

- **Visitor Directory**:
  - Instant search by visitor name or mobile number.
  - Filter chips to switch between All, Today Registered, Checked In, and Checked Out.
  - Edit visitor info.
  - Delete visitor with a confirmation dialog box.

- **QR Pass & Gate Operations**:
  - Generates a QR code using the visitor's unique ID.
  - Displays check-in and check-out timestamps once completed.
  - Gate button changes state dynamically:
    - If status is Registered -> Shows "CHECK IN VISITOR".
    - If status is Checked In -> Shows "CHECK OUT VISITOR".
    - If status is Checked Out -> Shows "VISIT COMPLETED" badge.

- **QR Code Scanner**:
  - Fast camera scanning using `mobile_scanner`.
  - Configured with `noDuplicates` to prevent double scanning.
  - Looks up the visitor pass directly from the API.
  - If camera permission is denied, it shows an "ALLOW ACCESS" button that opens the phone's App Settings directly.
  - When returning from Settings after allowing permission, it automatically detects it and starts the camera.
  - Includes an "ENTER PASS ID MANUALLY" button so you can test easily on emulators without a camera.

---

## Project Structure

Here is how the project files are organized:

- `lib/core/constants.dart`: API base URL, endpoints, and default dropdown options.
- `lib/models/visitor.dart`: Visitor model with fromJson, toJson, copyWith, and VisitorStatus enum.
- `lib/services/api_service.dart`: Handles HTTP calls (GET, POST, PUT, DELETE) with 10-second timeouts and error handling.
- `lib/providers/visitor_provider.dart`: State management handling visitor list, CRUD, dashboard counts, and business rule guards.
- `lib/screens/dashboard.dart`: Home dashboard with metric cards and recent visitors.
- `lib/screens/visitor_list.dart`: Directory screen with search bar and filter chips.
- `lib/screens/visitor_form.dart`: Registration and editing form with validation.
- `lib/screens/visitor_details.dart`: QR code pass view with check-in and check-out actions.
- `lib/screens/qr_scanner.dart`: Camera scanner view with permission handling and manual entry fallback.
- `lib/screens/main_navigation_screen.dart`: Bottom navigation bar connecting Dashboard, Visitors, and Scan QR tabs.
- `lib/widgets/`: Reusable widgets including StatCard, VisitorCard, StatusChip, CustomTextField, CustomButton, LoadingView, and EmptyStateWidget.
- `test/`: Unit and widget tests covering model parsing, business rules, and UI rendering.

---

## State Management

I used **Provider** (`ChangeNotifierProvider`) for state management:

- It is lightweight, officially recommended, and easy to maintain.
- When a visitor checks in or out, `VisitorProvider` updates the state and calls `notifyListeners()`.
- The updated status immediately reflects across the Visitor Details screen, the Visitor Directory list, and the Dashboard counts without needing to restart the app.
- Business rules are protected inside the provider (for example, attempting to check in an already checked-in visitor throws an exception).
- The list of visitors is returned as an unmodifiable list to prevent unexpected mutations from the UI.

---

## API Details

I used MockAPI for the backend to store data persistently:

- **Base URL**: `https://6ae029c78e42963c8d5eff23.mockapi.io/visitors-app`
- **Endpoints**:
  - `GET /visitors`: Fetch all visitors.
  - `GET /visitors/:id`: Fetch single visitor by ID (used during QR scan).
  - `POST /visitors`: Add a new visitor.
  - `PUT /visitors/:id`: Update existing visitor details.
  - `PATCH /visitors/:id`: Update status and timestamps.
  - `DELETE /visitors/:id`: Delete a visitor pass.

All network calls have a 10-second timeout and handle `SocketException` (no internet) and API errors cleanly using custom error messages.

---

## Business Rules

1. **Visit Flow**: A visitor must follow the lifecycle:
   `Registered -> Checked In -> Checked Out`
2. **Check-In Rule**: Only visitors with `Registered` status can check in.
3. **Check-Out Rule**: Visitors cannot check out without checking in first.
4. **Completed Rule**: Once checked out, the visit is completed and the pass cannot be used to check in again.
5. **Duplicate Prevention**: Scanner stops after reading a code so duplicate requests are not sent.

---

## Packages Used

- `provider: ^6.1.5` - State management
- `http: ^1.6.0` - REST API calls
- `qr_flutter: ^4.1.0` - Generating QR codes
- `mobile_scanner: ^7.4.2` - Camera QR code scanning
- `permission_handler: ^13.0.2` - Handling camera permissions and opening App Settings
- `intl: ^0.20.3` - Date and time formatting

---

## How to Run the Project

1. Make sure Flutter and Dart are installed on your machine.
2. Clone or open this project directory:
   ```bash
   cd visitor_management_app
   ```
3. Get the packages:
   ```bash
   flutter pub get
   ```
4. Check code analysis (0 errors, 0 warnings):
   ```bash
   flutter analyze
   ```
5. Run the app on an Android emulator or physical device:
   ```bash
   flutter run
   ```

---

## Running Automated Tests

I wrote unit and widget tests to verify model parsing, business rules, and initial screen rendering.

Run tests using:
```bash
flutter test
```

All 6 tests will pass:
- JSON parsing and copyWith updates
- Case-insensitive status enum parsing
- Provider check-in and check-out business rule exceptions
- VisitorApp launch and dashboard smoke test

---

## Building Release APK

To build the release APK for testing:
```bash
flutter build apk --release
```

The APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`
