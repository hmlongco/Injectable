//
//  InjectableDemoApp.swift
//  Shared
//
//  Created by Michael Long on 4/30/22.
//

import SwiftUI
import Injectable

@main
struct InjectableDemoApp: App {
    var body: some Scene {
        let _ = sharedContainer.registerMocks()
        WindowGroup {
            ContentView()
        }
    }
}
