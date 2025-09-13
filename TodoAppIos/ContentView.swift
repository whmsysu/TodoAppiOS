//
//  ContentView.swift
//  TodoAppIos
//
//  Created by Haomin Wu on 2025/9/13.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var todoManager: TodoManager
    
    init() {
        // Use dependency injection container
        self._todoManager = StateObject(wrappedValue: DIContainer.shared.createTodoManager())
    }
    
    var body: some View {
        TodoListView(todoManager: todoManager)
            .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}

#Preview("Test Environment") {
    let testTodoManager = TestDIContainer.shared.createTodoManager()
    return TodoListView(todoManager: testTodoManager)
        .preferredColorScheme(.light)
}
