//
//  TodoUseCase.swift
//  TodoAppiOS
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation

// MARK: - Todo Use Case Protocol
protocol TodoUseCase {
    func addTodo(_ todo: Todo) async throws
    func deleteTodo(_ todo: Todo) async throws
    func toggleCompletion(for todo: Todo) async throws
    func updateTodo(_ todo: Todo) async throws
    func clearCompletedTodos() async throws
    func clearAllTodos() async throws
    func fetchTodos() async throws -> [Todo]
}

// MARK: - Todo Use Case Implementation
class TodoUseCaseImpl: TodoUseCase {
    private let repository: TodoRepository
    
    init(repository: TodoRepository) {
        self.repository = repository
    }
    
    func addTodo(_ todo: Todo) async throws {
        // Business validation
        try validateTodo(todo)
        try await repository.saveTodo(todo)
    }
    
    func deleteTodo(_ todo: Todo) async throws {
        try await repository.deleteTodo(todo)
    }
    
    func toggleCompletion(for todo: Todo) async throws {
        var updatedTodo = todo
        
        if todo.isActuallyCompleted {
            // Mark as incomplete
            updatedTodo.isCompleted = false
            updatedTodo.completedAt = nil
        } else {
            // Mark as completed
            updatedTodo.isCompleted = true
            updatedTodo.completedAt = Date()
        }
        
        try await repository.updateTodo(updatedTodo)
    }
    
    func updateTodo(_ todo: Todo) async throws {
        // Business validation
        try validateTodo(todo)
        try await repository.updateTodo(todo)
    }
    
    func clearCompletedTodos() async throws {
        try await repository.clearCompletedTodos()
    }
    
    func clearAllTodos() async throws {
        try await repository.clearAllTodos()
    }
    
    func fetchTodos() async throws -> [Todo] {
        return try await repository.fetchTodos()
    }
    
    // MARK: - Private Methods
    
    private func validateTodo(_ todo: Todo) throws {
        // Validate title
        let trimmedTitle = todo.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            throw TodoError.invalidTitle
        }
        
        // Validate daily task logic
        if todo.isDaily {
            // Daily tasks should not have due date/time
            if todo.dueDate != nil || todo.dueTime != nil {
                throw TodoError.invalidTitle // TODO: Create specific error for this case
            }
        } else {
            // Regular tasks should not have daily time/end date
            if todo.dailyTime != nil || todo.dailyEndDate != nil {
                throw TodoError.invalidTitle // TODO: Create specific error for this case
            }
        }
        
        // Validate date logic
        if let dueDate = todo.dueDate, let dailyEndDate = todo.dailyEndDate {
            if dueDate > dailyEndDate {
                throw TodoError.invalidTitle // TODO: Create specific error for this case
            }
        }
    }
}
