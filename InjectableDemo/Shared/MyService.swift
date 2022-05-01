//
//  MyService.swift
//  InjectableDemo
//
//  Created by Michael Long on 4/30/22.
//

import Foundation

protocol MyServiceType {
    func text() -> String
}

class MyService: MyServiceType {
    func text() -> String {
        "Hello World!"
    }
}
