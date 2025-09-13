//
//  TodoListView.swift
//  TodoAppIos
//
//  Created by Haomin Wu on 2025/9/13.
//

import SwiftUI

struct TodoListView: View {
    @ObservedObject var todoManager: TodoManager
    @State private var showingAddTodo = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Chips
                FilterChipsView(todoManager: todoManager)
                
                // Progress Header
                ProgressHeaderView(todoManager: todoManager)
                
                // Todo List
                if todoManager.filteredTodos.isEmpty {
                    EmptyStateView(currentFilter: todoManager.currentFilter)
                } else {
                    List {
                        ForEach(todoManager.filteredTodos) { todo in
                            TodoRowView(todo: todo, todoManager: todoManager)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                todoManager.deleteTodo(todoManager.filteredTodos[index])
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("My Todos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTodo = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Clear Completed") {
                            todoManager.clearCompleted()
                        }
                        .disabled(todoManager.completedTodos.isEmpty)
                        
                        Button("Clear All", role: .destructive) {
                            todoManager.clearAll()
                        }
                        .disabled(todoManager.todos.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTodo) {
            AddTodoView(todoManager: todoManager)
        }
    }
}

struct FilterChipsView: View {
    @ObservedObject var todoManager: TodoManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TodoFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: todoManager.currentFilter == filter,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                todoManager.setFilter(filter)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TodoRowView: View {
    let todo: Todo
    @ObservedObject var todoManager: TodoManager
    @State private var showingEditTodo = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    todoManager.toggleCompletion(for: todo)
                }
            }) {
                Image(systemName: todo.isActuallyCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isActuallyCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Todo Content
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.headline)
                    .strikethrough(todo.isActuallyCompleted)
                    .foregroundColor(todo.isActuallyCompleted ? .secondary : .primary)
                
                if !todo.description.isEmpty {
                    Text(todo.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    // Priority Badge
                    Text(todo.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(todo.priority.color).opacity(0.2))
                        .foregroundColor(Color(todo.priority.color))
                        .cornerRadius(8)
                    
                    // Daily Badge
                    if todo.isDaily {
                        Text("每日")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Due Date and Time
                    if let dueDate = todo.dueDate {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(dueDate, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            if let dueTime = todo.dueTime {
                                Text(dueTime)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else if todo.isDaily, let dailyTime = todo.dailyTime {
                        Text("每日 \(dailyTime)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Edit Button (only if not completed and not expired)
            if !todo.isActuallyCompleted && !todo.isDailyTodoExpired {
                Button(action: {
                    showingEditTodo = true
                }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                todoManager.toggleCompletion(for: todo)
            }
        }
        .sheet(isPresented: $showingEditTodo) {
            EditTodoView(todo: todo, todoManager: todoManager)
        }
    }
}

struct ProgressHeaderView: View {
    @ObservedObject var todoManager: TodoManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(todoManager.completedTodos.count) of \(todoManager.todos.count) completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: todoManager.completionPercentage)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: todoManager.completionPercentage)
                    
                    Text("\(Int(todoManager.completionPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct EmptyStateView: View {
    let currentFilter: TodoFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var iconName: String {
        switch currentFilter {
        case .pending:
            return "checklist"
        case .completed:
            return "checkmark.circle"
        case .daily:
            return "repeat.circle"
        }
    }
    
    private var title: String {
        switch currentFilter {
        case .pending:
            return "暂无待办任务"
        case .completed:
            return "暂无已完成任务"
        case .daily:
            return "暂无每日任务"
        }
    }
    
    private var subtitle: String {
        switch currentFilter {
        case .pending:
            return "点击右下角的 + 按钮添加新任务"
        case .completed:
            return "完成一些任务后，它们会显示在这里"
        case .daily:
            return "创建每日重复任务来建立好习惯"
        }
    }
}

#Preview {
    TodoListView(todoManager: TodoManager())
}
