//
//  ContentView.swift
//  TodoAppIos
//
//  Created by Haomin Wu on 2025/9/13.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var todoManager = TodoManager()
    
    var body: some View {
        TodoListView(todoManager: todoManager)
            .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
