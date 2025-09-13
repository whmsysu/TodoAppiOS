//
//  SimpleTests.swift
//  TodoAppiOSTests
//
//  Created by Haomin Wu on 2025/9/13.
//

import Testing
import Foundation

@testable import TodoAppiOS

struct SimpleTests {
    
    // MARK: - Todo Model Tests
    
    @Test("Todo should be created with correct initial values")
    func testTodoCreation() async throws {
        let todo = Todo(
            title: "Test Task",
            description: "Test Description",
            priority: .medium,
            dueDate: nil,
            dueTime: nil,
            isDaily: false,
            dailyTime: nil,
            dailyEndDate: nil
        )
        
        #expect(todo.title == "Test Task")
        #expect(todo.description == "Test Description")
        #expect(todo.isCompleted == false)
        #expect(todo.priority == .medium)
        #expect(todo.isDaily == false)
    }
    
    @Test("Todo should generate unique ID")
    func testTodoUniqueID() async throws {
        let todo1 = Todo(
            title: "Task 1",
            description: "",
            priority: .low
        )
        
        let todo2 = Todo(
            title: "Task 2",
            description: "",
            priority: .low
        )
        
        #expect(todo1.id != todo2.id)
    }
    
    // MARK: - Priority Tests
    
    @Test("Priority should have correct raw values")
    func testPriorityRawValues() async throws {
        #expect(Priority.low.rawValue == "Low")
        #expect(Priority.medium.rawValue == "Medium")
        #expect(Priority.high.rawValue == "High")
    }
    
    // MARK: - TodoFilter Tests
    
    @Test("TodoFilter should have correct raw values")
    func testTodoFilterRawValues() async throws {
        #expect(TodoFilter.pending.rawValue == "Pending")
        #expect(TodoFilter.completed.rawValue == "Completed")
        #expect(TodoFilter.daily.rawValue == "Daily")
    }
    
    // MARK: - Storage Service Tests
    
    @Test("InMemoryStorage should save and load data correctly")
    func testInMemoryStorage() async throws {
        let storage = InMemoryStorage()
        let testData = TestData(id: 1, name: "Test", value: 42.0)
        let key = "test_key"
        
        // Save data
        try storage.save(testData, forKey: key)
        
        // Load data
        let loadedData: TestData = try storage.load(TestData.self, forKey: key)!
        
        #expect(loadedData.id == testData.id)
        #expect(loadedData.name == testData.name)
        #expect(loadedData.value == testData.value)
    }
    
    @Test("InMemoryStorage should return nil for non-existent key")
    func testInMemoryStorageNonExistentKey() async throws {
        let storage = InMemoryStorage()
        let key = "non_existent_key"
        
        let result: TestData? = try storage.load(TestData.self, forKey: key)
        
        #expect(result == nil)
    }
}

// MARK: - Test Data Types

struct TestData: Codable, Equatable {
    let id: Int
    let name: String
    let value: Double
}
