//
//  ErrorAlertView.swift
//  TodoAppiOS
//
//  Created by Haomin Wu on 2025/9/13.
//

import SwiftUI

struct ErrorAlertView: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        content
            .alert("错误", isPresented: $errorHandler.showingError) {
                Button("确定") {
                    errorHandler.clearError()
                }
                if errorHandler.recoverySuggestion != nil {
                    Button("重试") {
                        errorHandler.clearError()
                        // TODO: Implement retry logic
                    }
                }
            } message: {
                Text(errorHandler.errorMessage ?? "未知错误")
            }
    }
}

extension View {
    func errorAlert(errorHandler: ErrorHandler) -> some View {
        modifier(ErrorAlertView(errorHandler: errorHandler))
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("加载中...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("出现错误")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("重试", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
