# Getting Started
For setup first you need the following things:
- Flutter Version 3.27.1
- IDE like Android Studio or VS Code with Flutter Plugin installed.

## Steps to run App
1.⁠ ⁠Clone the repository with Git

```git clone https://github.com/simonoppowa/OpenNutriTracker.git```

2.⁠ ⁠Get Dependencies

```flutter pub get```

3.⁠ ⁠Run Build Runner to generate Files

```flutter pub run build_runner build```

4.⁠ ⁠Run App

```flutter run lib/main.dart```

## Running the Application

The application can be run on multiple platforms. Here are the commands for each:

### Web (Chrome)
```bash
flutter run -d chrome
```

### iOS
```bash
open -a Simulator
flutter run
```

### macOS
```bash
flutter run -d macos
```

### Android
```bash
flutter run -d android
```

## Editing Localizations (l18n)
The localization files live in the ```lib/l10n``` directory.

This project uses the VS Code plugin "Flutter Intl" by Localizely. You can install this
in VS Code by pressing ```ctrl + shift + X``` or opening the Extensions tab, and searching
for "flutter intl".

After you edit any of the ```.arb``` files, the plugin will automatically regenerate the
corresponding dart code needed for the application to use your new translations.

## Editing Backend Code
This project uses Hive as the database backend for storing data. The Hive bindings live in
```lib/core/data/dbo``` as ```.dart``` files.

After changing any database files, you need to re-run the following command to generate
the corresponding ```.g.dart``` files:

```bash
flutter pub run build_runner build
```

## API Keys

In order to connect to public APIs and fetch nutritional information, you need API keys.
You can acquire most of these by a simple signup procedure online.

### FoodData Central (USDA)
1. Go to the following link and fill out the form: [https://fdc.nal.usda.gov/api-key-signup](https://fdc.nal.usda.gov/api-key-signup)
2. Your API key will be sent to the provided email

### Re-buildling
After adding API keys, you will need to re-build the project for the updates to propagate:

```bash
flutter pub run build_runner build
```
