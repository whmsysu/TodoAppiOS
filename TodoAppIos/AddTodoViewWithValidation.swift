//
//  AddTodoViewWithValidation.swift
//  TodoAppiOS
//
//  Created by Haomin Wu on 2025/9/13.
//

import SwiftUI

struct AddTodoViewWithValidation: View {
    @ObservedObject var todoManager: TodoManager
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var validationViewModel: FormValidationViewModel
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var showingDailyTimePicker = false
    @State private var showingDailyEndDatePicker = false
    
    init(todoManager: TodoManager) {
        self.todoManager = todoManager
        self._validationViewModel = StateObject(wrappedValue: FormValidationViewModel(existingTodos: todoManager.todos))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("任务详情")) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("标题", text: $validationViewModel.title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(validationViewModel.titleError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if let titleError = validationViewModel.titleError {
                            Text(titleError)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 4)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("描述（可选）", text: $validationViewModel.description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(validationViewModel.descriptionError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if let descriptionError = validationViewModel.descriptionError {
                            Text(descriptionError)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 4)
                        }
                    }
                }
                
                Section(header: Text("优先级")) {
                    Picker("Priority", selection: $validationViewModel.selectedPriority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(priority.color))
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("日期时间")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Button(action: {
                            showingDatePicker = true
                        }) {
                            HStack {
                                Text("截止日期")
                                Spacer()
                                if let date = validationViewModel.selectedDueDate {
                                    Text(date, style: .date)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("选择日期")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .disabled(validationViewModel.isDaily)
                        
                        if let dateError = validationViewModel.dateError {
                            Text(dateError)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 4)
                        }
                    }
                    
                    if validationViewModel.selectedDueDate != nil && !validationViewModel.isDaily {
                        VStack(alignment: .leading, spacing: 4) {
                            Button(action: {
                                showingTimePicker = true
                            }) {
                                HStack {
                                    Text("截止时间")
                                    Spacer()
                                    if let time = validationViewModel.selectedDueTime {
                                        Text(time)
                                            .foregroundColor(.primary)
                                    } else {
                                        Text("选择时间（可选）")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            if let timeError = validationViewModel.timeError {
                                Text(timeError)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                
                Section(header: Text("每日任务")) {
                    Toggle("每日重复", isOn: $validationViewModel.isDaily)
                    
                    if validationViewModel.isDaily {
                        Button(action: {
                            showingDailyTimePicker = true
                        }) {
                            HStack {
                                Text("提醒时间")
                                Spacer()
                                if let time = validationViewModel.selectedDailyTime {
                                    Text(time)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("选择时间（可选）")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Button(action: {
                            showingDailyEndDatePicker = true
                        }) {
                            HStack {
                                Text("结束日期")
                                Spacer()
                                if let date = validationViewModel.selectedDailyEndDate {
                                    Text(date, style: .date)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("选择日期（可选）")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        if let dailyError = validationViewModel.dailyError {
                            Text(dailyError)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 4)
                        }
                    }
                }
                
                Section {
                    Button(action: saveTodo) {
                        HStack {
                            Spacer()
                            Text("添加任务")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!validationViewModel.isFormValid)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: validationViewModel.isFormValid ? 
                                [Color.blue, Color.purple] : [Color.gray],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                    .buttonStyle(PlainButtonStyle())
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .navigationTitle("新建任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(
                selectedDate: $validationViewModel.selectedDueDate,
                title: "选择截止日期",
                minimumDate: Date()
            )
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(
                selectedTime: $validationViewModel.selectedDueTime,
                title: "选择截止时间"
            )
        }
        .sheet(isPresented: $showingDailyTimePicker) {
            TimePickerSheet(
                selectedTime: $validationViewModel.selectedDailyTime,
                title: "选择提醒时间"
            )
        }
        .sheet(isPresented: $showingDailyEndDatePicker) {
            DatePickerSheet(
                selectedDate: $validationViewModel.selectedDailyEndDate,
                title: "选择结束日期",
                minimumDate: Date()
            )
        }
        .onAppear {
            validationViewModel.updateExistingTodos(todoManager.todos)
        }
    }
    
    private func saveTodo() {
        // Final validation before saving
        let validationResult = validationViewModel.validateAll()
        
        if !validationResult.isValid {
            // Show validation error - validation will be handled by TodoManager.addTodo
            return
        }
        
        let newTodo = Todo(
            title: validationViewModel.title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: validationViewModel.description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: validationViewModel.selectedPriority,
            dueDate: validationViewModel.isDaily ? nil : validationViewModel.selectedDueDate,
            dueTime: validationViewModel.isDaily ? nil : validationViewModel.selectedDueTime,
            isDaily: validationViewModel.isDaily,
            dailyTime: validationViewModel.isDaily ? validationViewModel.selectedDailyTime : nil,
            dailyEndDate: validationViewModel.isDaily ? validationViewModel.selectedDailyEndDate : nil
        )
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            todoManager.addTodo(newTodo)
        }
        
        dismiss()
    }
}

#Preview {
    AddTodoViewWithValidation(todoManager: DIContainer.shared.createTodoManager())
}

#Preview("Test Environment") {
    AddTodoViewWithValidation(todoManager: TestDIContainer.shared.createTodoManager())
}
