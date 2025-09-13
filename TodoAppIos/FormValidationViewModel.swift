//
//  FormValidationViewModel.swift
//  TodoAppiOS
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Form Validation ViewModel

@MainActor
class FormValidationViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedPriority: Priority = .medium
    @Published var selectedDueDate: Date?
    @Published var selectedDueTime: String?
    @Published var isDaily = false
    @Published var selectedDailyTime: String?
    @Published var selectedDailyEndDate: Date?
    
    // Validation states
    @Published var titleError: String?
    @Published var descriptionError: String?
    @Published var timeError: String?
    @Published var dateError: String?
    @Published var dailyError: String?
    
    // Overall validation state
    @Published var isFormValid = false
    @Published var hasValidationErrors = false
    
    private let validator = TodoValidator()
    private var existingTodos: [Todo] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(existingTodos: [Todo] = []) {
        self.existingTodos = existingTodos
        setupValidation()
    }
    
    // MARK: - Setup
    
    private func setupValidation() {
        // Validate title on change
        $title
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateTitle()
            }
            .store(in: &cancellables)
        
        // Validate description on change
        $description
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateDescription()
            }
            .store(in: &cancellables)
        
        // Validate time on change
        $selectedDueTime
            .sink { [weak self] _ in
                self?.validateTime()
            }
            .store(in: &cancellables)
        
        // Validate date on change
        $selectedDueDate
            .sink { [weak self] _ in
                self?.validateDate()
                self?.validateTime() // Re-validate time when date changes
            }
            .store(in: &cancellables)
        
        // Validate daily settings on change
        Publishers.CombineLatest3($isDaily, $selectedDailyTime, $selectedDailyEndDate)
            .sink { [weak self] _ in
                self?.validateDailyTask()
            }
            .store(in: &cancellables)
        
        // Update overall validation state - simplified approach
        $titleError
            .combineLatest($descriptionError)
            .combineLatest($timeError)
            .combineLatest($dailyError)
            .map { errors in
                let (titleDesc, timeError) = errors.0
                let (titleError, descriptionError) = titleDesc
                let dailyError = errors.1
                return titleError != nil || descriptionError != nil || timeError != nil || dailyError != nil
            }
            .assign(to: &$hasValidationErrors)
        
        $hasValidationErrors
            .combineLatest($title)
            .map { hasErrors, title in
                return !hasErrors && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .assign(to: &$isFormValid)
    }
    
    // MARK: - Validation Methods
    
    private func validateTitle() {
        let result = validator.validateTitle(title, existingTodos: existingTodos)
        titleError = result.firstError?.errorDescription
    }
    
    private func validateDescription() {
        let result = validator.validateDescription(description)
        descriptionError = result.firstError?.errorDescription
    }
    
    private func validateTime() {
        let result = validator.validateDueDateTime(dueDate: selectedDueDate, dueTime: selectedDueTime)
        timeError = result.firstError?.errorDescription
    }
    
    private func validateDate() {
        let result = validator.validateDate(selectedDueDate, isRequired: false)
        dateError = result.firstError?.errorDescription
    }
    
    private func validateDailyTask() {
        guard isDaily else {
            dailyError = nil
            return
        }
        
        let result = validator.validateDailyTask(
            dailyTime: selectedDailyTime,
            dailyEndDate: selectedDailyEndDate,
            startDate: Date()
        )
        dailyError = result.firstError?.errorDescription
    }
    
    // MARK: - Public Methods
    
    func updateExistingTodos(_ todos: [Todo]) {
        existingTodos = todos
        validateTitle() // Re-validate title for duplicates
    }
    
    func validateAll() -> ValidationResult {
        let tempTodo = Todo(
            title: title,
            description: description,
            priority: selectedPriority,
            dueDate: isDaily ? nil : selectedDueDate,
            dueTime: isDaily ? nil : selectedDueTime,
            isDaily: isDaily,
            dailyTime: isDaily ? selectedDailyTime : nil,
            dailyEndDate: isDaily ? selectedDailyEndDate : nil
        )
        
        return validator.validate(tempTodo, existingTodos: existingTodos)
    }
    
    func clearValidationErrors() {
        titleError = nil
        descriptionError = nil
        timeError = nil
        dateError = nil
        dailyError = nil
    }
    
    func resetForm() {
        title = ""
        description = ""
        selectedPriority = .medium
        selectedDueDate = nil
        selectedDueTime = nil
        isDaily = false
        selectedDailyTime = nil
        selectedDailyEndDate = nil
        clearValidationErrors()
    }
}

// MARK: - Combine Extensions
