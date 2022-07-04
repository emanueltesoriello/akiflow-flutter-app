
# Akiflow Mobile App

## Run

Use the `.vscode/launch.json` to launch the app with the specific environment or:

Development: `flutter run -t lib/main_dev.dart`

Production: `flutter run -t lib/main.dart`

## Build

### Android APK

Use only if it's necessary installs the app externally to Play Store:

`flutter build apk --release -t lib/main.dart`

### Android Appbundle

Create the build to upload to Play Store channels:

`flutter build appbundle --release -t lib/main.dart`

### iOS

`flutter build ipa --release -t lib/main.dart`

After build completed, it will be shown the path to the Runner archive like: */Users/{username}/akiflow/build/ios/archive/Runner.xcarchive*.

Then just run:

`open /Users/{username}/akiflow/build/ios/archive/Runner.xcarchive`

then tap "Distribute App" and follow the procedure through Xcode.

# Flow and Structure

## Flow

![Flutter Bloc & Cubit Tutorial - Reso Coder](https://i0.wp.com/resocoder.com/wp-content/uploads/2020/07/bloc_architecture_full.png?resize=778%2C195&ssl=1)

The application is composed of several packages, defined for execute operations in an isolated way, to facilitate the development while keeping each component simple to perform operations for the scope for which it was created.

The application uses [BLoC](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) as the State Management package. So call methods (*events*) on a feature blocks *(bloc)* located within the `features / cubit` package, defined one for each feature or context.

From the controller class *\_cubit.dart*, will be updated the *state* of the *bloc* which will notify the `ui` part to render the changes just received via `BlocBuilder`.

##  Structure

Each package is now described with its development logic and any logical flows.

### root

At the 'root' level of the project are defined the `main` classes that will take care of launching and instantiating the main entities and the setup of the app.

The `main_dev` and `main` files are respectively the files that are launched to separate the app's launch mode. In this way it is possible to define different behaviors for each configuration environment and loading the *main* method inside the shared `main_com` file.

### Api

Contains the classes needed to perform network operations with the *Akiflow* backend.
A `base_api.dart` class is defined and the methods within, are defined as common to all the classes used to make requests, this for a better organization of the code and for future unit testing and mocking of the code.

In the `api.dart` class, is defined the implementation of the code common to the other classes, in this way passing the type of the entity, it will be possible to make specific requests without rewriting the same methods for each 'api' class.

These classes can throw `ApiException` exceptions when the response contains values ​​within the `errors` field.

### Components

This package is divided into:
1. `base`
These are the basic components for rendering the custom UI according to the *Akiflow* style and custom components shared with multiple classes within the application.

2. `calendar`, `label`, `social`, `task`
Components exclusively related to UI related to specified context.

### Core

Contains the main configuration classes:

1. `config`
Here is defined the application launch config, including `endpoint` used to execute network requests with the backend, and other keys and endpoints necessary for authentication and connection with the various integrations. `development` /` production` files are defined so that you have two separate environments based on the launch of its *main* file.

1. `http_client` is defined as the class that deals with handling requests (authenticated and unauthenticated) through JWT tokens.

2. `locator` represents the central register [service locator](https://en.wikipedia.org/wiki/Service_locator_pattern) where the classes are instantiated so that they can be referenced anywhere in the code, for a better organization of the source code.

### Exceptions

Here are defined new *exceptions* to be thrown as needed.

### Features

Within this package, additional packages are created for each functionality or context necessary for development. The defined blocks will be accessible through the `BlocProvider` class (package [flutter_bloc](https://pub.dev/packages/flutter_bloc)).

Some blocks will be available anywhere within the code, being declared as a wrapper of the main application (the `Application` widget within the `main_com.dart` class), others will be defined in the appropriate widget where you need to create a new specific context. (See `flutter_bloc` specifications).

Each feature or context contains two packages: `cubit` and `ui`. The 'cubit' classes are used as controllers and receive *events* from the classes in 'ui'. The class `[filename]_state.dart` will contain the properties related to the functionality, in order to keep and track its *state*.

This will update the *state* from the `_cubit.dart` controller class, which will notify the UI part to render the changes just received on the `ui`.

### Repository

Contains the classes needed to work with the app's local database, `SQLite`.
A `base_database_repository.dart` class is defined and the methods are common to all the classes and used to make requests to the db.
In the `database_repository.dart` class, the implementation of the code is common to the other classes, so you can pass the entity type to execute specific entity operations.

### Services

Contains reusable service classes (defined in the `locator` class) to facilitate various operations over the source code:

- Synchronization service between database and backend.
- Analytics event management
- Dialog service to show `dialogs` directly from controller classes without using `context`.
- Handling of exceptions via Sentry.

### Style

Where the application style is defined. It is divided into:
- `colors` where are set the main palettes of the app.
- `theme` where is defined the basic theme of the app, i.e. everything that is rendered such as colors, dimensions, transition animations.

### Utils

These classes are utilities that allows to perform shared operations in order to reuse the developed source code.

Particular note for the `converters_isolate` class which contains the methods launched in a separate memory space from the main one, in order to support [concurrency](https://dart.dev/guides/language/concurrency) in dart.

### Packages

 `models` all classes that define the system entities. Each class must extend the abstract class [Equatable](https://pub.dev/packages/equatable) which facilitates the handling of objects comparison.
If the created class needs to be decomposed into multiple entities, a package is created which will contains the main class and its sub-classes.

 `i18n`, all translations are defined in the `strings.i18n.json` file.
To generate the file with all the translations to be used within the code, run `flutter pub run fast_i18n`.
In this way, within the code it will be possible to access the various strings using the getter `t` method.

## Other

In the *root* of the application source code there are also the following packages:

 1. `assets` with fonts, files, images are stored that will be made available for the application configuration through the file `pubspec.yaml`

	 `config` there are the two json files `dev` and `prod` to establish the app configuration parameters in different development environments.

 2. the `pubspec.yaml` file where dependencies are established with the various *packages* and application configurations and features for *fonts*, configuration of *assets* and *launch screen* and *app icons* generations.
 Whenever a package is added, remember to add its reference to the `LicencesPage.dart` widget.

`flutter pub run fast_i18n`

## JS integration

Put JS code inside the folder `/assets/html/` and edit the file `index.html` to include the JS code and create
custom methods to handle the events.