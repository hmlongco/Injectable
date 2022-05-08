//
//  InjectableDemoApp+Injections.swift
//  InjectableDemo
//
//  Created by Michael Long on 4/30/22.
//

import Foundation
import Injectable

extension Injections {
    var mySimpleService: MySimpleService { MySimpleService() }
}

extension Injections {
    var myServiceType: MyServiceType { registered(MyService()) }
    var mockServiceType: MyServiceType { MockService() }
}

extension Injections {
    var mySingletonInstance: MySingleton { MySingleton.instance }
    var mySingleton: MySingleton { application(MySingleton()) }
    var myCachedService: MyService { cached(MyService()) }
    var mySharedService: MyServiceType { shared(MyService() as MyServiceType) }
}

extension Injections {
    var myConstructedService: MyConstructedService {
        MyConstructedService(service: resolve(\.myServiceType))
    }
    var myConstructedService2: MyConstructedService {
        MyConstructedService(service: myServiceType)
    }
}

extension Injections {
    func registerMocks() {
        register { MockService() as MyServiceType }
    }
}
