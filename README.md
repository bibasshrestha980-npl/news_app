# News App

A Flutter app for browsing trending US headlines and news by category.
Tap an article to open it in your browser.

## Run

```sh
flutter pub get
flutter run
```

The NewsAPI key is configured in `lib/providers/news_provider.dart`.

## Project structure

- `lib/screens/`: onboarding, home, and category screens. Shared article widgets, link handling, and the article detail screen are kept in `category_screen.dart`.
- `lib/providers/`: news fetching and loading state.
- `lib/common/`: app colors.
- `lib/data/`: available news categories.
- `assets/`: app images.

## Checks

```sh
dart format lib test
flutter analyze
flutter test
```
