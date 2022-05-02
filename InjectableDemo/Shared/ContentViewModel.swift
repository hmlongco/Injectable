//
//  ContentViewModel.swift
//  InjectableDemo
//
//  Created by Michael Long on 4/30/22.
//

import Foundation
import Injectable

class ContentViewModel: ObservableObject {

    @Injectable(\.myConstructedService) var service

    @Published var text: String = ""
    
    func load() {
        text = service.text()
    }
}
