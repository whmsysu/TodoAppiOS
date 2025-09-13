//
//  DIContainer.swift
//  TodoAppiOS
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation

// MARK: - Dependency Injection Container

class DIContainer {
    static let shared = DIContainer()
    
    // MARK: - Core Services
    
    private let storageService: StorageService
    private let todoRepository: TodoRepository
    private let todoUseCase: TodoUseCase
    
    // MARK: - Initialization
    
    private init() {
        // Initialize core services
        storageService = UserDefaultsStorage()
        todoRepository = LocalTodoRepository(storageService: storageService)
        todoUseCase = TodoUseCaseImpl(repository: todoRepository)
    }
    
    // MARK: - Factory Methods
    
    @MainActor
    func createTodoManager() -> TodoManager {
        return TodoManager(todoUseCase: todoUseCase)
    }
    
    @MainActor
    func createTodoManagerWithErrorHandler() -> (TodoManager, ErrorHandler) {
        let errorHandler = ErrorHandler()
        let todoManager = TodoManager(todoUseCase: todoUseCase)
        todoManager.errorHandler = errorHandler
        return (todoManager, errorHandler)
    }
    
    // MARK: - Service Access (for testing)
    
    func getStorageService() -> StorageService {
        return storageService
    }
    
    func getTodoRepository() -> TodoRepository {
        return todoRepository
    }
    
    func getTodoUseCase() -> TodoUseCase {
        return todoUseCase
    }
}

// MARK: - Test DIContainer

class TestDIContainer {
    static let shared = TestDIContainer()
    
    private let storageService: StorageService
    private let todoRepository: TodoRepository
    private let todoUseCase: TodoUseCase
    
    private init() {
        // Use in-memory storage for testing
        storageService = InMemoryStorage()
        todoRepository = LocalTodoRepository(storageService: storageService)
        todoUseCase = TodoUseCaseImpl(repository: todoRepository)
    }
    
    @MainActor
    func createTodoManager() -> TodoManager {
        return TodoManager(todoUseCase: todoUseCase)
    }
    
    @MainActor
    func createTodoManagerWithErrorHandler() -> (TodoManager, ErrorHandler) {
        let errorHandler = ErrorHandler()
        let todoManager = TodoManager(todoUseCase: todoUseCase)
        todoManager.errorHandler = errorHandler
        return (todoManager, errorHandler)
    }
    
    func getStorageService() -> StorageService {
        return storageService
    }
    
    func getTodoRepository() -> TodoRepository {
        return todoRepository
    }
    
    func getTodoUseCase() -> TodoUseCase {
        return todoUseCase
    }
    
    func reset() {
        if let inMemoryStorage = storageService as? InMemoryStorage {
            inMemoryStorage.clear()
        }
    }
}
