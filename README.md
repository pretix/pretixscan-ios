# PretixScan for iOS

# Architecture
The following is a draft:

## AppDelegate
- initialises ConfigStore
- initialises TicketValidator
- initialises DataStore

## Models
A collection of enum based models and parsing code to and from JSON

## ConfigStore (Protocol)
Holds key-value pairs for configuration. Creates and holds an APIClient per instance

Optional: Notifications when configuration changes

## DataStore (Protocol)
Database that optionally manages a queue of changes to be uploaded to the API.

- requires an APIClient instance 
- Has sub-objects for queueing uploads and managing downloads
- will periodically try to upload the queue to the server 
- will periodically try to download all (or all new) server data
- Optional: Notifications when data changes

## APIClient (Protocol)
Manages requests to and responses from the Pretix REST API. Needs to be initialised with configStore.

## TicketValidator (Protocol)
Exposes methods to check the validity of tickets and show event status.

- requires a ConfigStore instance

### Protocol methods
- check(ticketid, List of Answers, ignore_unpaid);
- search(query)
- status() 

### OnlineTicketValidator
Uses the APIClient directly to check the validity of tickets.

- does not add anything to DataStore's queue, but instead throws errors if no network available

### AsyncTicketValidator
Uses the DataStore to check the validity of tickets. 

- adds new information to DataStore's upload queue
- tries to init sync every now and then

# Rebranding 
TBD

# Building Documentation
To build the HTML documentation, install [jazzy](https://github.com/realm/jazzy) by running `sudo gem install jazzy` (requirements: current macOS and Xcode is installed). Documentation will be auto-generated each time the project is built. You can also run `jazzy` manually from the project root folder. Find generated documentation files in the `docs/` directory. Documentation configuration lives in `.jazzy.yml`.

# Code Linting
To check for linting errors, install [swiftlint](https://github.com/realm/swiftlint) by running `brew install swiftlint` (requirements: current macOS and [homebrew](brew.sh)). Code will be linted and warnings and errors generated each time the project is built.

# License 
TBD
