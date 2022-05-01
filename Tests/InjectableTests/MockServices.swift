//
//  File.swift
//  
//
//  Created by Michael Long on 5/1/22.
//

import Foundation
@testable import Injectable

protocol MyServiceType {
    var id: UUID { get }
    func text() -> String
}

class MyService: MyServiceType {
    let id = UUID()
    func text() -> String {
        "MyService"
    }
}

class MockService: MyServiceType {
    let id = UUID()
    func text() -> String {
        "MockService"
    }
}

class Services {
    @Injectable(\.myService) var service
    @Injectable(\.mockService) var mock
    init() {}
}

extension Injections {
    var myService: MyServiceType { MyService() }
    var mockService: MyServiceType { MockService() }
    var applicationService: MyServiceType { application( MyService() as MyServiceType ) }
    var cachedService: MyServiceType { cached( MyService() as MyServiceType ) }
    var sharedService: MyServiceType { shared( MyService() as MyServiceType ) }
}
