# Prepare your environment

To install the necessary tools on macOS, open a Terminal to this folder and run `make setup`:

# Generate swift files

1. If `pretix_sig1.pb.swift` is already part of the project, remove the file. (Right click > Delete > **Remove Reference**)


2. In Terminal, run `make convert`. This will recreate the `pretix_sig1.pb.swift` file.


3. Re-add the file to Xcode. Right click on the "Proto" group > Add files to "pretixSCAN" > select `pretix_sig1.pb.swift` while ensuring the `pretixSCAN` target is checked.



# Links

More information can be found [here](https://github.com/apple/swift-protobuf/#converting-proto-files-into-swift).

# Help

To get a list of all available commands, please run `make` or `make help`.
