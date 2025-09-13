//
//  TodoValidator.swift
//  TodoAppiOS
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation

// MARK: - Todo Validator Protocol

protocol TodoValidatorProtocol {
    func validate(_ todo: Todo, existingTodos: [Todo]) -> ValidationResult
    func validateTitle(_ title: String, existingTodos: [Todo], excludeId: UUID?) -> ValidationResult
    func validateDescription(_ description: String) -> ValidationResult
    func validateTime(_ time: String?) -> ValidationResult
    func validateDate(_ date: Date?, isRequired: Bool) -> ValidationResult
    func validateDailyTask(dailyTime: String?, dailyEndDate: Date?, startDate: Date?) -> ValidationResult
    func validateDueDateTime(dueDate: Date?, dueTime: String?) -> ValidationResult
}

// MARK: - Todo Validator Implementation

class TodoValidator: TodoValidatorProtocol {
    
    // MARK: - Main Validation Method
    
    func validate(_ todo: Todo, existingTodos: [Todo]) -> ValidationResult {
        var allErrors: [ValidationError] = []
        
        // Validate title
        let titleResult = validateTitle(todo.title, existingTodos: existingTodos, excludeId: todo.id)
        allErrors.append(contentsOf: titleResult.errors)
        
        // Validate description
        let descriptionResult = validateDescription(todo.description)
        allErrors.append(contentsOf: descriptionResult.errors)
        
        // Validate time format
        if let dueTime = todo.dueTime {
            let timeResult = validateTime(dueTime)
            allErrors.append(contentsOf: timeResult.errors)
        }
        
        if let dailyTime = todo.dailyTime {
            let timeResult = validateTime(dailyTime)
            allErrors.append(contentsOf: timeResult.errors)
        }
        
        // Validate due date and time combination
        let dueDateTimeResult = validateDueDateTime(dueDate: todo.dueDate, dueTime: todo.dueTime)
        allErrors.append(contentsOf: dueDateTimeResult.errors)
        
        // Validate daily task
        if todo.isDaily {
            let dailyResult = validateDailyTask(
                dailyTime: todo.dailyTime,
                dailyEndDate: todo.dailyEndDate,
                startDate: todo.createdAt
            )
            allErrors.append(contentsOf: dailyResult.errors)
        }
        
        return ValidationResult(isValid: allErrors.isEmpty, errors: allErrors)
    }
    
    // MARK: - Individual Validation Methods
    
    func validateTitle(_ title: String, existingTodos: [Todo], excludeId: UUID? = nil) -> ValidationResult {
        var errors: [ValidationError] = []
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if empty
        if trimmedTitle.isEmpty {
            errors.append(.emptyTitle)
            return ValidationResult(isValid: false, errors: errors)
        }
        
        // Check length
        if trimmedTitle.count > ValidationConstants.maxTitleLength {
            errors.append(.titleTooLong(maxLength: ValidationConstants.maxTitleLength))
        }
        
        if trimmedTitle.count < ValidationConstants.minTitleLength {
            errors.append(.emptyTitle)
        }
        
        // Check for duplicates
        let hasDuplicate = existingTodos.contains { existingTodo in
            existingTodo.id != excludeId && 
            existingTodo.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == trimmedTitle.lowercased()
        }
        
        if hasDuplicate {
            errors.append(.duplicateTitle)
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    func validateDescription(_ description: String) -> ValidationResult {
        var errors: [ValidationError] = []
        
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check length (description is optional, so only check if not empty)
        if !trimmedDescription.isEmpty && trimmedDescription.count > ValidationConstants.maxDescriptionLength {
            errors.append(.descriptionTooLong(maxLength: ValidationConstants.maxDescriptionLength))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    func validateTime(_ time: String?) -> ValidationResult {
        guard let time = time, !time.isEmpty else {
            return ValidationResult(isValid: true) // Time is optional
        }
        
        var errors: [ValidationError] = []
        
        // Check format using regex
        let timeRegex = try! NSRegularExpression(pattern: ValidationConstants.timeFormatRegex)
        let range = NSRange(location: 0, length: time.utf16.count)
        
        if timeRegex.firstMatch(in: time, options: [], range: range) == nil {
            errors.append(.invalidTimeFormat)
        }
        
        // Check if time is in the past (only if it's today)
        if errors.isEmpty {
            let now = Date()
            let calendar = Calendar.current
            
            // Parse time
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            if let timeDate = formatter.date(from: time) {
                let components = calendar.dateComponents([.hour, .minute], from: timeDate)
                let today = calendar.startOfDay(for: now)
                
                if let todayWithTime = calendar.date(byAdding: components, to: today),
                   todayWithTime < now {
                    errors.append(.pastTime)
                }
            }
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    func validateDate(_ date: Date?, isRequired: Bool = false) -> ValidationResult {
        var errors: [ValidationError] = []
        
        if isRequired && date == nil {
            errors.append(.pastDate) // Using pastDate as a generic "invalid date" error
            return ValidationResult(isValid: false, errors: errors)
        }
        
        guard let date = date else {
            return ValidationResult(isValid: true) // Date is optional
        }
        
        // Check if date is in the past
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.compare(date, to: now, toGranularity: .day) == .orderedAscending {
            errors.append(.pastDate)
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    func validateDailyTask(dailyTime: String?, dailyEndDate: Date?, startDate: Date?) -> ValidationResult {
        var errors: [ValidationError] = []
        
        guard let startDate = startDate else {
            return ValidationResult(isValid: true) // No start date to validate against
        }
        
        // Validate daily time
        let timeResult = validateTime(dailyTime)
        errors.append(contentsOf: timeResult.errors)
        
        // Validate daily end date
        if let endDate = dailyEndDate {
            let calendar = Calendar.current
            
            // Check if end date is before start date
            if calendar.compare(endDate, to: startDate, toGranularity: .day) == .orderedAscending {
                errors.append(.dailyEndDateBeforeStart)
            }
            
            // Check if end date is in the past
            let now = Date()
            if calendar.compare(endDate, to: now, toGranularity: .day) == .orderedAscending {
                errors.append(.invalidDailyEndDate)
            }
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    func validateDueDateTime(dueDate: Date?, dueTime: String?) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // If time is set but date is not, that's invalid
        if dueTime != nil && dueDate == nil {
            errors.append(.timeWithoutDate)
        }
        
        // Validate date if provided
        let dateResult = validateDate(dueDate, isRequired: false)
        errors.append(contentsOf: dateResult.errors)
        
        // Validate time if provided
        let timeResult = validateTime(dueTime)
        errors.append(contentsOf: timeResult.errors)
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}
