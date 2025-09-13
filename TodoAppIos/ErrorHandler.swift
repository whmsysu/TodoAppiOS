//
//  ErrorHandler.swift
//  TodoAppiOS
//
//  Created by Haomin Wu on 2025/9/13.
//

import Foundation
import SwiftUI

// MARK: - Todo Error Types
enum TodoError: LocalizedError {
    case invalidTitle
    case todoNotFound
    case saveFailed
    case loadFailed
    case deleteFailed
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "任务标题不能为空"
        case .todoNotFound:
            return "任务不存在"
        case .saveFailed:
            return "保存失败，请重试"
        case .loadFailed:
            return "加载数据失败"
        case .deleteFailed:
            return "删除失败，请重试"
        case .updateFailed:
            return "更新失败，请重试"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidTitle:
            return "请输入有效的任务标题"
        case .todoNotFound:
            return "请刷新列表后重试"
        case .saveFailed, .loadFailed, .deleteFailed, .updateFailed:
            return "请检查存储空间后重试"
        }
    }
}

// MARK: - Error Handler
@MainActor
class ErrorHandler: ObservableObject {
    @Published var errorMessage: String?
    @Published var showingError = false
    @Published var recoverySuggestion: String?
    
    func handle(_ error: Error) {
        if let todoError = error as? TodoError {
            errorMessage = todoError.errorDescription
            recoverySuggestion = todoError.recoverySuggestion
        } else {
            errorMessage = error.localizedDescription
            recoverySuggestion = "请稍后重试"
        }
        showingError = true
    }
    
    func clearError() {
        errorMessage = nil
        recoverySuggestion = nil
        showingError = false
    }
}

// MARK: - Result Type Extensions
extension Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
