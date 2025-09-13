//
//  TodoManager.swift
//  TodoAppIos
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation
import SwiftUI

class TodoManager: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var currentFilter: TodoFilter = .pending
    @Published var filteredTodos: [Todo] = []
    
    private let userDefaults = UserDefaults.standard
    private let todosKey = "SavedTodos"
    
    init() {
        loadTodos()
        applyFilter()
    }
    
    // MARK: - CRUD Operations
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        saveTodos()
        applyFilter()
    }
    
    func deleteTodo(at indexSet: IndexSet) {
        todos.remove(atOffsets: indexSet)
        saveTodos()
        applyFilter()
    }
    
    func deleteTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos.remove(at: index)
            saveTodos()
            applyFilter()
        }
    }
    
    func toggleCompletion(for todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            if todos[index].isActuallyCompleted {
                // Mark as incomplete
                todos[index].isCompleted = false
                todos[index].completedAt = nil
            } else {
                // Mark as completed
                todos[index].isCompleted = true
                todos[index].completedAt = Date()
            }
            saveTodos()
            applyFilter()
        }
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            saveTodos()
            applyFilter()
        }
    }
    
    // MARK: - Computed Properties
    
    var completedTodos: [Todo] {
        todos.filter { $0.isActuallyCompleted && !$0.isDailyTodoExpired }
    }
    
    var pendingTodos: [Todo] {
        todos.filter { !$0.isActuallyCompleted && !$0.isDailyTodoExpired }
    }
    
    var dailyTodos: [Todo] {
        todos.filter { $0.isDaily && !$0.isDailyTodoExpired }
    }
    
    var completionPercentage: Double {
        guard !todos.isEmpty else { return 0 }
        let completedCount = completedTodos.count
        return Double(completedCount) / Double(todos.count)
    }
    
    // MARK: - Filter Methods
    
    func setFilter(_ filter: TodoFilter) {
        currentFilter = filter
        applyFilter()
    }
    
    private func applyFilter() {
        let filtered = switch currentFilter {
        case .pending:
            pendingTodos
        case .completed:
            completedTodos
        case .daily:
            dailyTodos
        }
        
        // Sort the filtered list by due date, then by time, then by priority
        filteredTodos = filtered.sorted { todo1, todo2 in
            // First sort by due date (null dates go to end)
            let date1 = todo1.dueDate?.timeIntervalSince1970 ?? Double.greatestFiniteMagnitude
            let date2 = todo2.dueDate?.timeIntervalSince1970 ?? Double.greatestFiniteMagnitude
            
            if date1 != date2 {
                return date1 < date2
            }
            
            // Then sort by time (no time goes to end)
            let time1 = todo1.dueTime ?? "24:00"
            let time2 = todo2.dueTime ?? "24:00"
            
            if time1 != time2 {
                return time1 < time2
            }
            
            // Finally sort by priority (high to low)
            let priorityOrder: [Priority] = [.high, .medium, .low]
            let priority1 = priorityOrder.firstIndex(of: todo1.priority) ?? 0
            let priority2 = priorityOrder.firstIndex(of: todo2.priority) ?? 0
            
            return priority1 < priority2
        }
    }
    
    // MARK: - Persistence
    
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            userDefaults.set(encoded, forKey: todosKey)
        }
    }
    
    private func loadTodos() {
        if let data = userDefaults.data(forKey: todosKey),
           let decoded = try? JSONDecoder().decode([Todo].self, from: data) {
            todos = decoded
        }
    }
    
    // MARK: - Utility Methods
    
    func clearCompleted() {
        todos.removeAll { $0.isActuallyCompleted }
        saveTodos()
        applyFilter()
    }
    
    func clearAll() {
        todos.removeAll()
        saveTodos()
        applyFilter()
    }
}
