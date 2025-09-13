//
//  ValidationError.swift
//  TodoAppiOS
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation

// MARK: - Validation Error Types

enum ValidationError: LocalizedError, Equatable {
    case emptyTitle
    case titleTooLong(maxLength: Int)
    case descriptionTooLong(maxLength: Int)
    case invalidTimeFormat
    case pastDate
    case pastTime
    case dailyEndDateBeforeStart
    case invalidDailyEndDate
    case timeWithoutDate
    case duplicateTitle
    case invalidPriority
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "标题不能为空"
        case .titleTooLong(let maxLength):
            return "标题长度不能超过\(maxLength)个字符"
        case .descriptionTooLong(let maxLength):
            return "描述长度不能超过\(maxLength)个字符"
        case .invalidTimeFormat:
            return "时间格式无效，请使用HH:mm格式"
        case .pastDate:
            return "不能选择过去的日期"
        case .pastTime:
            return "不能选择过去的时间"
        case .dailyEndDateBeforeStart:
            return "每日任务结束日期不能早于开始日期"
        case .invalidDailyEndDate:
            return "每日任务结束日期无效"
        case .timeWithoutDate:
            return "设置了时间但未设置日期"
        case .duplicateTitle:
            return "已存在相同标题的任务"
        case .invalidPriority:
            return "优先级无效"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .emptyTitle:
            return "请输入任务标题"
        case .titleTooLong:
            return "请缩短标题长度"
        case .descriptionTooLong:
            return "请缩短描述长度"
        case .invalidTimeFormat:
            return "请使用正确的时间格式"
        case .pastDate, .pastTime:
            return "请选择未来的日期或时间"
        case .dailyEndDateBeforeStart:
            return "请选择晚于开始日期的结束日期"
        case .invalidDailyEndDate:
            return "请选择有效的结束日期"
        case .timeWithoutDate:
            return "请先设置日期，或移除时间设置"
        case .duplicateTitle:
            return "请使用不同的标题"
        case .invalidPriority:
            return "请选择有效的优先级"
        }
    }
}

// MARK: - Validation Result

struct ValidationResult {
    let isValid: Bool
    let errors: [ValidationError]
    
    init(isValid: Bool, errors: [ValidationError] = []) {
        self.isValid = isValid
        self.errors = errors
    }
    
    var firstError: ValidationError? {
        return errors.first
    }
    
    var errorMessage: String? {
        return firstError?.errorDescription
    }
}

// MARK: - Validation Constants

struct ValidationConstants {
    static let maxTitleLength = 100
    static let maxDescriptionLength = 500
    static let minTitleLength = 1
    static let timeFormatRegex = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
}
