//
//  ContentView.swift
//  Shared
//
//  Created by Michael Long on 4/30/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = ContentViewModel()
    var body: some View {
        Text(model.text)
            .padding()
            .onAppear {
                model.load()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
