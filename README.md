# ClinicSync

ClinicSync is a mobile app for clinic queue and appointment management, designed for Android and iOS.

## Overview

This project provides a foundation for managing:
- patient appointments
- clinic queue status
- scheduling workflows for medical staff

## Tech Stack

- Flutter
- Dart
- Android and iOS support

## Project Structure

- `lib/` contains the main application code
- `test/` contains widget and unit tests
- `android/`, `ios/`, `web/`, and `windows/` contain platform-specific project files

## Getting Started

1. Install Flutter and Dart on your machine.
2. Clone the repository.
3. Run the app with:

```bash
flutter pub get
flutter run
```

## Features

- Appointment scheduling with status updates
- Clinic queue management with priority and progress status
- Search and filter for both appointments and queue patients
- Edit and delete workflow entries
- Local persistence using shared preferences

## Notes

- Data is stored locally on the device between sessions.
- Default branch: `main`
- Development branch: `dev`
