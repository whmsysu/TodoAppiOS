//
//  AddTodoView.swift
//  TodoAppIos
//
//  Created by Haomin Wu on 2025/9/13.
//

import SwiftUI

struct AddTodoView: View {
    @ObservedObject var todoManager: TodoManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedPriority: Priority = .medium
    @State private var selectedDueDate: Date?
    @State private var selectedDueTime: String?
    @State private var isDaily = false
    @State private var selectedDailyTime: String?
    @State private var selectedDailyEndDate: Date?
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var showingDailyTimePicker = false
    @State private var showingDailyEndDatePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("任务详情")) {
                    TextField("标题", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("描述（可选）", text: $description, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section(header: Text("优先级")) {
                    Picker("Priority", selection: $selectedPriority) {
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
                    // Due Date
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        HStack {
                            Text("截止日期")
                            Spacer()
                            if let date = selectedDueDate {
                                Text(date, style: .date)
                                    .foregroundColor(.primary)
                            } else {
                                Text("选择日期")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(isDaily)
                    
                    // Due Time (only if date is selected and not daily)
                    if selectedDueDate != nil && !isDaily {
                        Button(action: {
                            showingTimePicker = true
                        }) {
                            HStack {
                                Text("截止时间")
                                Spacer()
                                if let time = selectedDueTime {
                                    Text(time)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("选择时间（可选）")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("每日任务")) {
                    Toggle("每日重复", isOn: $isDaily)
                    
                    if isDaily {
                        // Daily Time
                        Button(action: {
                            showingDailyTimePicker = true
                        }) {
                            HStack {
                                Text("提醒时间")
                                Spacer()
                                if let time = selectedDailyTime {
                                    Text(time)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("选择时间（可选）")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Daily End Date
                        Button(action: {
                            showingDailyEndDatePicker = true
                        }) {
                            HStack {
                                Text("结束日期")
                                Spacer()
                                if let date = selectedDailyEndDate {
                                    Text(date, style: .date)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("选择日期（可选）")
                                        .foregroundColor(.secondary)
                                }
                            }
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
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                                [Color.gray] : [Color.blue, Color.purple],
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
                selectedDate: $selectedDueDate,
                title: "选择截止日期",
                minimumDate: Date()
            )
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(
                selectedTime: $selectedDueTime,
                title: "选择截止时间"
            )
        }
        .sheet(isPresented: $showingDailyTimePicker) {
            TimePickerSheet(
                selectedTime: $selectedDailyTime,
                title: "选择提醒时间"
            )
        }
        .sheet(isPresented: $showingDailyEndDatePicker) {
            DatePickerSheet(
                selectedDate: $selectedDailyEndDate,
                title: "选择结束日期",
                minimumDate: Date()
            )
        }
    }
    
    private func saveTodo() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newTodo = Todo(
            title: trimmedTitle,
            description: trimmedDescription,
            priority: selectedPriority,
            dueDate: isDaily ? nil : selectedDueDate,
            dueTime: isDaily ? nil : selectedDueTime,
            isDaily: isDaily,
            dailyTime: isDaily ? selectedDailyTime : nil,
            dailyEndDate: isDaily ? selectedDailyEndDate : nil
        )
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            todoManager.addTodo(newTodo)
        }
        
        dismiss()
    }
}

struct EditTodoView: View {
    let todo: Todo
    @ObservedObject var todoManager: TodoManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var selectedPriority: Priority
    @State private var selectedDueDate: Date?
    @State private var selectedDueTime: String?
    @State private var isDaily: Bool
    @State private var selectedDailyTime: String?
    @State private var selectedDailyEndDate: Date?
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var showingDailyTimePicker = false
    @State private var showingDailyEndDatePicker = false
    
    init(todo: Todo, todoManager: TodoManager) {
        self.todo = todo
        self.todoManager = todoManager
        self._title = State(initialValue: todo.title)
        self._description = State(initialValue: todo.description)
        self._selectedPriority = State(initialValue: todo.priority)
        self._selectedDueDate = State(initialValue: todo.dueDate)
        self._selectedDueTime = State(initialValue: todo.dueTime)
        self._isDaily = State(initialValue: todo.isDaily)
        self._selectedDailyTime = State(initialValue: todo.dailyTime)
        self._selectedDailyEndDate = State(initialValue: todo.dailyEndDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("任务详情")) {
                    TextField("标题", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(todo.isActuallyCompleted || todo.isDailyTodoExpired)
                    
                    TextField("描述（可选）", text: $description, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                        .disabled(todo.isActuallyCompleted || todo.isDailyTodoExpired)
                }
                
                Section(header: Text("优先级")) {
                    Picker("Priority", selection: $selectedPriority) {
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
                    .disabled(todo.isActuallyCompleted || todo.isDailyTodoExpired)
                }
                
                Section(header: Text("日期时间")) {
                    // Due Date
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        HStack {
                            Text("截止日期")
                            Spacer()
                            if let date = selectedDueDate {
                                Text(date, style: .date)
                                    .foregroundColor(.primary)
                            } else {
                                Text("选择日期")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(todo.isActuallyCompleted || todo.isDailyTodoExpired || isDaily)
                    
                    // Due Time (only if date is selected and not daily)
                    if selectedDueDate != nil && !isDaily {
                        Button(action: {
                            showingTimePicker = true
                        }) {
                            HStack {
                                Text("截止时间")
                                Spacer()
                                if let time = selectedDueTime {
                                    Text(time)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("选择时间（可选）")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .disabled(todo.isActuallyCompleted || todo.isDailyTodoExpired)
                    }
                }
                
                Section(header: Text("每日任务")) {
                    Toggle("每日重复", isOn: $isDaily)
                        .disabled(todo.isActuallyCompleted || todo.isDailyTodoExpired)
                    
                    if isDaily {
                        // Daily Time
                        Button(action: {
                            showingDailyTimePicker = true
                        }) {
                            HStack {
                                Text("提醒时间")
                                Spacer()
                                if let time = selectedDailyTime {
                                    Text(time)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("选择时间（可选）")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .disabled(todo.isActuallyCompleted || todo.isDailyTodoExpired)
                        
                        // Daily End Date
                        Button(action: {
                            showingDailyEndDatePicker = true
                        }) {
                            HStack {
                                Text("结束日期")
                                Spacer()
                                if let date = selectedDailyEndDate {
                                    Text(date, style: .date)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("选择日期（可选）")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .disabled(todo.isActuallyCompleted || todo.isDailyTodoExpired)
                    }
                }
                
                Section {
                    Button(action: saveChanges) {
                        HStack {
                            Spacer()
                            Text("保存更改")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || todo.isActuallyCompleted || todo.isDailyTodoExpired)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || todo.isActuallyCompleted || todo.isDailyTodoExpired ? 
                                [Color.gray] : [Color.green, Color.blue],
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
            .navigationTitle("编辑任务")
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
                selectedDate: $selectedDueDate,
                title: "选择截止日期",
                minimumDate: Date()
            )
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(
                selectedTime: $selectedDueTime,
                title: "选择截止时间"
            )
        }
        .sheet(isPresented: $showingDailyTimePicker) {
            TimePickerSheet(
                selectedTime: $selectedDailyTime,
                title: "选择提醒时间"
            )
        }
        .sheet(isPresented: $showingDailyEndDatePicker) {
            DatePickerSheet(
                selectedDate: $selectedDailyEndDate,
                title: "选择结束日期",
                minimumDate: Date()
            )
        }
    }
    
    private func saveChanges() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var updatedTodo = todo
        updatedTodo.title = trimmedTitle
        updatedTodo.description = trimmedDescription
        updatedTodo.priority = selectedPriority
        updatedTodo.dueDate = isDaily ? nil : selectedDueDate
        updatedTodo.dueTime = isDaily ? nil : selectedDueTime
        updatedTodo.isDaily = isDaily
        updatedTodo.dailyTime = isDaily ? selectedDailyTime : nil
        updatedTodo.dailyEndDate = isDaily ? selectedDailyEndDate : nil
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            todoManager.updateTodo(updatedTodo)
        }
        
        dismiss()
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date?
    let title: String
    let minimumDate: Date?
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempDate: Date
    
    init(selectedDate: Binding<Date?>, title: String, minimumDate: Date? = nil) {
        self._selectedDate = selectedDate
        self.title = title
        self.minimumDate = minimumDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue ?? Date())
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "选择日期",
                    selection: $tempDate,
                    in: (minimumDate ?? Date())...,
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") {
                        selectedDate = tempDate
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TimePickerSheet: View {
    @Binding var selectedTime: String?
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempTime: Date
    
    init(selectedTime: Binding<String?>, title: String) {
        self._selectedTime = selectedTime
        self.title = title
        
        // Parse existing time or use current time
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let timeString = selectedTime.wrappedValue,
           let date = formatter.date(from: timeString) {
            self._tempTime = State(initialValue: date)
        } else {
            self._tempTime = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "选择时间",
                    selection: $tempTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        selectedTime = formatter.string(from: tempTime)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddTodoView(todoManager: TodoManager())
}
