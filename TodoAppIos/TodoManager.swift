//
//  TodoManager.swift
//  TodoAppIos
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation
import SwiftUI

@MainActor
class TodoManager: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var currentFilter: TodoFilter = .pending
    @Published var filteredTodos: [Todo] = []
    @Published var isLoading = false
    @Published var errorHandler: ErrorHandler
    
    private let todoUseCase: TodoUseCase
    
    init(todoUseCase: TodoUseCase) {
        self.todoUseCase = todoUseCase
        self.errorHandler = ErrorHandler()
        Task {
            await loadTodos()
        }
    }
    
    // MARK: - CRUD Operations
    
    func addTodo(_ todo: Todo) {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                try await todoUseCase.addTodo(todo)
                await MainActor.run {
                    todos.append(todo)
                    applyFilter()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorHandler.handle(error)
                    isLoading = false
                }
            }
        }
    }
    
    func deleteTodo(at indexSet: IndexSet) {
        for index in indexSet {
            let todo = filteredTodos[index]
            deleteTodo(todo)
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                try await todoUseCase.deleteTodo(todo)
                await MainActor.run {
                    todos.removeAll { $0.id == todo.id }
                    applyFilter()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorHandler.handle(error)
                    isLoading = false
                }
            }
        }
    }
    
    func toggleCompletion(for todo: Todo) {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                try await todoUseCase.toggleCompletion(for: todo)
                await MainActor.run {
                    // Update local state
                    if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                        todos[index] = todo
                    }
                    applyFilter()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorHandler.handle(error)
                    isLoading = false
                }
            }
        }
    }
    
    func updateTodo(_ todo: Todo) {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                try await todoUseCase.updateTodo(todo)
                await MainActor.run {
                    if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                        todos[index] = todo
                    }
                    applyFilter()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorHandler.handle(error)
                    isLoading = false
                }
            }
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
    
    @MainActor
    private func loadTodos() async {
        isLoading = true
        
        do {
            todos = try await todoUseCase.fetchTodos()
            applyFilter()
            isLoading = false
        } catch {
            errorHandler.handle(error)
            isLoading = false
        }
    }
    
    // MARK: - Utility Methods
    
    func clearCompleted() {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                try await todoUseCase.clearCompletedTodos()
                await MainActor.run {
                    todos.removeAll { $0.isActuallyCompleted }
                    applyFilter()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorHandler.handle(error)
                    isLoading = false
                }
            }
        }
    }
    
    func clearAll() {
        Task {
            await MainActor.run { isLoading = true }
            
            do {
                try await todoUseCase.clearAllTodos()
                await MainActor.run {
                    todos.removeAll()
                    applyFilter()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorHandler.handle(error)
                    isLoading = false
                }
            }
        }
    }
}
