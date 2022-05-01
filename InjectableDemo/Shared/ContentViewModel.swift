//
//  ContentViewModel.swift
//  InjectableDemo
//
//  Created by Michael Long on 4/30/22.
//

import Foundation
import Injectable

class ContentViewModel: ObservableObject {
    @Injectable(\.myService) var service: MyServiceType
    @Published var text: String = ""
    func load() {
        text = service.text()
    }
}
