//
//  Todo.swift
//  TodoAppIos
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation

struct Todo: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String = ""
    var isCompleted: Bool
    let createdAt: Date
    var priority: Priority
    var dueDate: Date?
    var dueTime: String? // Format: "HH:mm"
    var isDaily: Bool = false
    var dailyTime: String? // Format: "HH:mm"
    var dailyEndDate: Date?
    var completedAt: Date? // Time when the todo was completed
    
    init(title: String, description: String = "", priority: Priority = .medium, dueDate: Date? = nil, dueTime: String? = nil, isDaily: Bool = false, dailyTime: String? = nil, dailyEndDate: Date? = nil) {
        self.title = title
        self.description = description
        self.isCompleted = false
        self.createdAt = Date()
        self.priority = priority
        self.dueDate = dueDate
        self.dueTime = dueTime
        self.isDaily = isDaily
        self.dailyTime = dailyTime
        self.dailyEndDate = dailyEndDate
        self.completedAt = nil
    }
    
    // Computed property to check if todo is completed
    var isActuallyCompleted: Bool {
        return completedAt != nil
    }
    
    // Check if daily todo is expired
    var isDailyTodoExpired: Bool {
        guard isDaily, let endDate = dailyEndDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let endDateStart = calendar.startOfDay(for: endDate)
        return today > endDateStart
    }
}

enum Priority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        }
    }
}

enum TodoFilter: String, CaseIterable {
    case pending = "Pending"
    case completed = "Completed"
    case daily = "Daily"
    
    var displayName: String {
        switch self {
        case .pending:
            return "待办"
        case .completed:
            return "已完成"
        case .daily:
            return "每日任务"
        }
    }
}
