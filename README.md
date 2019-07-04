# pretixSCAN (iOS)

This is an iOS app for validating pretix tickets.

## Components

### LibPretixSync
Library containing all business logic for interacting with pretix.

### Models
Communcation with the API, and caching data in the `DataStore` is based on the `Model` protocol: A collection of enum based models and parsing code to and from JSON. See  `Model` for a detailed description.  

### ConfigStore (Protocol)
Holds key-value pairs for configuration. Passed around in the app as the source of truth for configuration, and also for accessing any other manager entities. See  `ConfigStore` for a detailed description.  

Provides these manager entities: 
- `DataStore`
- `APIClient`
- `TicketValidator` (switched based on the `asyncModeEnabled` property)
- `SyncManager`

### DataStore (Protocol)
Abstracts all local data caching and sends notifications when data changes.

### APIClient (Protocol)
Manages requests to and responses from the Pretix REST API. 

### TicketValidator (Protocol)
Exposes methods to check the validity of tickets and show event status. `ConfigStore` will intantiate a fitting implementation of `TicketValidator` depending on the   `asyncModeEnabled` property. This might be `OnlineTicketValidator`, which uses the APIClient directly to check the validity of tickets and does not add anything to DataStore's queue, but instead throws errors if no network available, or `AsyncTicketValidator`, which uses the DataStore to check the validity of tickets, and adds new checkins to DataStore's upload queue.

### SyncManager (Protocol)
Downloads all data from the API using `APIClient` and peridically updates the data using incremental updates. Manages a queue of changes to be uploaded to the API.

### pretixSCAN for iOS
The actual app that uses LibPretixSync

### AppDelegate and AppCoordinator
Initialises a `ConfigStore` instance and passes it on to `ValidateTicketViewController`, which is the root view controller for the application.   `ValidateTicketViewController` will pass the instance on to any sub view controllers that request them using the `Configurable` protocol.

`ValidateTicketViewController` is implementing the `AppCoordinator` protocol. Classes that are marked as `AppCoordinatorReceiver` will get their `appcoordinator` property set. Use `AppCoordinator` for anything that needs to be a singleton. 

## Storyboards
The app uses storbyboards and segues for navigation. Segue identifiers, in case you need to trigger segues manually, are in `Segues.swift`. but most segues should be triggered by the storyboard. 

## Passing around `ConfigStore`
`Configurable` and `ConfiguredNavigationController`: If a UIViewController is marked as implementing the Configurable protocol it will automatially get assigned a ConfigStore when it gets pushed from `ValidateTicketViewController`.

## Tests
Unit Tests are available to make sure models parse correctly.

## Building Documentation
To build the HTML documentation, install [jazzy](https://github.com/realm/jazzy) by running `sudo gem install jazzy` (requirements: current macOS and Xcode is installed). Documentation will be auto-generated each time the project is built. You can also run `jazzy` manually from the project root folder. Find generated documentation files in the `docs/` directory. Documentation configuration lives in `.jazzy.yml`.

## Code Linting
To check for linting errors, install [swiftlint](https://github.com/realm/swiftlint) by running `brew install swiftlint` (requirements: current macOS and [homebrew](brew.sh)). Code will be linted and warnings and errors generated each time the project is built.

## License 

The code in this repository is published under the terms of the Apache License.
See the LICENSE file for the complete license text.

## Licences for used Libraries

- FMDB [MIT Licence](https://github.com/ccgus/fmdb/blob/master/LICENSE.txt)
- SwiftMessages [MIT License](https://github.com/SwiftKickMobile/SwiftMessages/blob/master/LICENSE.md)
- Tink Keychain [MIT Licence](https://github.com/tink-ab/Keychain/blob/master/LICENSE)
