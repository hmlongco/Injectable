//
//  InjectableDemoApp+Injections.swift
//  InjectableDemo
//
//  Created by Michael Long on 4/30/22.
//

import Foundation
import Injectable

extension Injections {
    var myService: MyServiceType { shared( MyService() as MyServiceType ) }
}
