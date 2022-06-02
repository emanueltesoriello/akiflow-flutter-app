# Akiflow Mobile App

## Run Development App

`flutter run -t lib/main_dev.dart`

## Generate translations

`flutter pub run fast_i18n`

## JS integration

Bundle node package as a single {package-name}.js file (if bundling with webpack use `output.libraryTarget = "window"`)
then import in `assets/js/` folder.

Follow `ChronoNodeJs.dart` class to use the package.