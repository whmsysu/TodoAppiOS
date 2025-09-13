//
//  TodoRepository.swift
//  TodoAppiOS
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation

// MARK: - Todo Repository Protocol
protocol TodoRepository {
    func fetchTodos() async throws -> [Todo]
    func saveTodo(_ todo: Todo) async throws
    func deleteTodo(_ todo: Todo) async throws
    func updateTodo(_ todo: Todo) async throws
    func clearCompletedTodos() async throws
    func clearAllTodos() async throws
}

// MARK: - Local Todo Repository
class LocalTodoRepository: TodoRepository {
    private let storageService: StorageService
    private let todosKey = "SavedTodos"
    
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    func fetchTodos() async throws -> [Todo] {
        return try storageService.load([Todo].self, forKey: todosKey) ?? []
    }
    
    func saveTodo(_ todo: Todo) async throws {
        var todos = try await fetchTodos()
        todos.append(todo)
        try storageService.save(todos, forKey: todosKey)
    }
    
    func deleteTodo(_ todo: Todo) async throws {
        var todos = try await fetchTodos()
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else {
            throw TodoError.todoNotFound
        }
        todos.remove(at: index)
        try storageService.save(todos, forKey: todosKey)
    }
    
    func updateTodo(_ todo: Todo) async throws {
        var todos = try await fetchTodos()
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else {
            throw TodoError.todoNotFound
        }
        todos[index] = todo
        try storageService.save(todos, forKey: todosKey)
    }
    
    func clearCompletedTodos() async throws {
        let todos = try await fetchTodos()
        let filteredTodos = todos.filter { !$0.isActuallyCompleted }
        try storageService.save(filteredTodos, forKey: todosKey)
    }
    
    func clearAllTodos() async throws {
        try storageService.save([Todo](), forKey: todosKey)
    }
}
