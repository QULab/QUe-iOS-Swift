QUe for iOS (Swift)
=======

QUe is a mobile conference app solution best suited for multitrack conferences.

#Dependencies
QUe-iOS-Swift uses [Alamofire](https://github.com/Alamofire/Alamofire) for networking purposes and [Realm](https://github.com/realm/realm-cocoa) as a database. Dependencies are managed using [Carthage](https://github.com/Carthage/Carthage).

#Usage
In order to get things started, this version uses data from the [Interspeech 2015](http://interspeech2015.org) conference.

Call `carthage update` to download and build the project's dependencies.

The app is able to work without any internet connection. However, it is designed to pull updates from a remote server (that is not yet available under an open source license). Be sure to check the URL given in *QUe-iOS-Swift/QUEDatasource.swift*.



#Author
[Tilo Westermann](https://tilowestermann.eu)

#License
QUe-iOS-Swift is licensed under the terms of the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
