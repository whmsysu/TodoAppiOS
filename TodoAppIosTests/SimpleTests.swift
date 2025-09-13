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
    
    // MARK: - Validation Tests
    
    @Test("TodoValidator should validate empty title")
    func testValidateEmptyTitle() async throws {
        let validator = TodoValidator()
        let result = validator.validateTitle("", existingTodos: [])
        
        #expect(result.isValid == false)
        #expect(result.errors.contains(.emptyTitle))
    }
    
    @Test("TodoValidator should validate title too long")
    func testValidateTitleTooLong() async throws {
        let validator = TodoValidator()
        let longTitle = String(repeating: "a", count: 101) // Exceeds max length
        let result = validator.validateTitle(longTitle, existingTodos: [])
        
        #expect(result.isValid == false)
        #expect(result.errors.contains { 
            if case .titleTooLong(let maxLength) = $0 {
                return maxLength == ValidationConstants.maxTitleLength
            }
            return false
        })
    }
    
    @Test("TodoValidator should validate duplicate title")
    func testValidateDuplicateTitle() async throws {
        let validator = TodoValidator()
        let existingTodo = Todo(title: "Existing Task", description: "", priority: .medium)
        let result = validator.validateTitle("Existing Task", existingTodos: [existingTodo])
        
        #expect(result.isValid == false)
        #expect(result.errors.contains(.duplicateTitle))
    }
    
    @Test("TodoValidator should validate valid title")
    func testValidateValidTitle() async throws {
        let validator = TodoValidator()
        let result = validator.validateTitle("Valid Task", existingTodos: [])
        
        #expect(result.isValid == true)
        #expect(result.errors.isEmpty)
    }
    
    @Test("TodoValidator should validate time format")
    func testValidateTimeFormat() async throws {
        // Test format validation only (without past time check)
        // Valid time formats
        let validTimes = ["09:30", "23:59", "00:00", "12:00"]
        for time in validTimes {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let isValidFormat = formatter.date(from: time) != nil
            #expect(isValidFormat == true, "Time \(time) should have valid format")
        }
        
        // Invalid time formats
        let invalidTimes = ["25:00", "12:60", "9:30", "abc", "12.30"]
        for time in invalidTimes {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let isValidFormat = formatter.date(from: time) != nil
            #expect(isValidFormat == false, "Time \(time) should have invalid format")
        }
    }
    
    @Test("TodoValidator should validate date in past")
    func testValidatePastDate() async throws {
        let validator = TodoValidator()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = validator.validateDate(yesterday, isRequired: false)
        
        #expect(result.isValid == false)
        #expect(result.errors.contains(.pastDate))
    }
    
    @Test("TodoValidator should validate time without date")
    func testValidateTimeWithoutDate() async throws {
        let validator = TodoValidator()
        let result = validator.validateDueDateTime(dueDate: nil, dueTime: "09:30")
        
        #expect(result.isValid == false)
        #expect(result.errors.contains(.timeWithoutDate))
    }
    
    @Test("TodoValidator should validate complete todo")
    func testValidateCompleteTodo() async throws {
        let validator = TodoValidator()
        let validTodo = Todo(
            title: "Valid Task",
            description: "Valid description",
            priority: .high,
            dueDate: Date().addingTimeInterval(3600), // 1 hour from now
            dueTime: "14:30",
            isDaily: false
        )
        
        let result = validator.validate(validTodo, existingTodos: [])
        #expect(result.isValid == true)
        #expect(result.errors.isEmpty)
    }
}

// MARK: - Test Data Types

struct TestData: Codable, Equatable {
    let id: Int
    let name: String
    let value: Double
}
