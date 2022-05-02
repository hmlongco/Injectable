//
//  MyService.swift
//  InjectableDemo
//
//  Created by Michael Long on 4/30/22.
//

import Foundation
import Injectable

class MySimpleService {
    func text() -> String {
        "A Simple Hello Will Do!"
    }
}

protocol MyServiceType {
    func text() -> String
}

class MyService: MyServiceType {
    func text() -> String {
        "Hello World!"
    }
}

class MockService: MyServiceType {
    func text() -> String {
        "Hello MockWorld!"
    }
}

class MySingleton {
    static var instance: MySingleton = MySingleton()
    func text() -> String {
        "Hello Singles!"
    }
}

class MyConstructedService {
    private let service: MyServiceType
    init(service: MyServiceType) {
        self.service = service
    }
    func text() -> String {
        "Well, " + service.text()
    }
}

class MyPrivateSingleton {
    fileprivate init() {}
    func text() -> String {
        "Hello Private!"
    }
}

extension Injections {
    var myPrivateSingleton: MyPrivateSingleton { application(MyPrivateSingleton()) }
}

