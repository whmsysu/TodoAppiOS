# TodoAppiOS 架构分析与优化建议

## 🏗️ 当前架构分析

### 架构模式：MVVM (Model-View-ViewModel)

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│      View       │◄──►│   ViewModel      │◄──►│      Model      │
│   (SwiftUI)     │    │ (TodoManager)    │    │     (Todo)      │
│                 │    │                  │    │                 │
│ • TodoListView  │    │ • @Published     │    │ • Data Model    │
│ • AddTodoView   │    │ • CRUD Operations│    │ • Business Logic│
│ • TodoRowView   │    │ • Filter/Sort    │    │ • Validation    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📊 当前架构优势

### ✅ 优点
1. **清晰的职责分离**: View、ViewModel、Model各司其职
2. **响应式数据绑定**: SwiftUI + ObservableObject 实现自动UI更新
3. **组件化设计**: 可复用的UI组件 (FilterChipsView, TodoRowView等)
4. **数据持久化**: UserDefaults简单可靠的本地存储
5. **智能排序**: 多维度排序算法 (日期→时间→优先级)

## 🚀 架构优化建议

### 1. 依赖注入与解耦

#### 当前问题
- TodoManager直接依赖UserDefaults
- 硬编码的存储键值
- 难以进行单元测试

#### 优化方案
```swift
// 定义存储协议
protocol StorageService {
    func save<T: Codable>(_ object: T, forKey key: String) throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
    func delete(forKey key: String)
}

// UserDefaults实现
class UserDefaultsStorage: StorageService {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save<T: Codable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        userDefaults.set(data, forKey: key)
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    func delete(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

// 重构TodoManager
class TodoManager: ObservableObject {
    private let storageService: StorageService
    private let todosKey = "SavedTodos"
    
    init(storageService: StorageService = UserDefaultsStorage()) {
        self.storageService = storageService
        loadTodos()
        applyFilter()
    }
    
    private func saveTodos() {
        do {
            try storageService.save(todos, forKey: todosKey)
        } catch {
            // 错误处理
            print("Failed to save todos: \(error)")
        }
    }
    
    private func loadTodos() {
        do {
            todos = try storageService.load([Todo].self, forKey: todosKey) ?? []
        } catch {
            print("Failed to load todos: \(error)")
            todos = []
        }
    }
}
```

### 2. Repository模式

#### 优化方案
```swift
// 数据访问抽象层
protocol TodoRepository {
    func fetchTodos() async throws -> [Todo]
    func saveTodo(_ todo: Todo) async throws
    func deleteTodo(_ todo: Todo) async throws
    func updateTodo(_ todo: Todo) async throws
}

// 本地存储实现
class LocalTodoRepository: TodoRepository {
    private let storageService: StorageService
    private let todosKey = "SavedTodos"
    
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    func fetchTodos() async throws -> [Todo] {
        return try storageService.load([Todo].self, forKey: todosKey) ?? []
    }
    
    func saveTodo(_ todo: Todo) async throws {
        var todos = try await fetchTodos()
        todos.append(todo)
        try storageService.save(todos, forKey: todosKey)
    }
    
    func deleteTodo(_ todo: Todo) async throws {
        var todos = try await fetchTodos()
        todos.removeAll { $0.id == todo.id }
        try storageService.save(todos, forKey: todosKey)
    }
    
    func updateTodo(_ todo: Todo) async throws {
        var todos = try await fetchTodos()
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            try storageService.save(todos, forKey: todosKey)
        }
    }
}

// 重构TodoManager使用Repository
class TodoManager: ObservableObject {
    private let todoRepository: TodoRepository
    
    init(todoRepository: TodoRepository) {
        self.todoRepository = todoRepository
        Task {
            await loadTodos()
        }
    }
    
    @MainActor
    private func loadTodos() async {
        do {
            todos = try await todoRepository.fetchTodos()
            applyFilter()
        } catch {
            // 错误处理
        }
    }
    
    func addTodo(_ todo: Todo) {
        Task {
            do {
                try await todoRepository.saveTodo(todo)
                await MainActor.run {
                    todos.append(todo)
                    applyFilter()
                }
            } catch {
                // 错误处理
            }
        }
    }
}
```

### 3. UseCase模式

#### 优化方案
```swift
// 业务用例抽象
protocol TodoUseCase {
    func addTodo(_ todo: Todo) async throws
    func deleteTodo(_ todo: Todo) async throws
    func toggleCompletion(for todo: Todo) async throws
    func updateTodo(_ todo: Todo) async throws
    func fetchTodos(filter: TodoFilter) async throws -> [Todo]
}

// 具体实现
class TodoUseCaseImpl: TodoUseCase {
    private let repository: TodoRepository
    
    init(repository: TodoRepository) {
        self.repository = repository
    }
    
    func addTodo(_ todo: Todo) async throws {
        // 业务验证
        guard !todo.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TodoError.invalidTitle
        }
        
        try await repository.saveTodo(todo)
    }
    
    func toggleCompletion(for todo: Todo) async throws {
        var updatedTodo = todo
        if todo.isActuallyCompleted {
            updatedTodo.isCompleted = false
            updatedTodo.completedAt = nil
        } else {
            updatedTodo.isCompleted = true
            updatedTodo.completedAt = Date()
        }
        try await repository.updateTodo(updatedTodo)
    }
    
    // 其他方法...
}

// 错误定义
enum TodoError: LocalizedError {
    case invalidTitle
    case todoNotFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "任务标题不能为空"
        case .todoNotFound:
            return "任务不存在"
        case .saveFailed:
            return "保存失败"
        }
    }
}
```

### 4. 错误处理与用户反馈

#### 优化方案
```swift
// 统一错误处理
class ErrorHandler: ObservableObject {
    @Published var errorMessage: String?
    @Published var showingError = false
    
    func handle(_ error: Error) {
        errorMessage = error.localizedDescription
        showingError = true
    }
}

// 在TodoManager中集成
class TodoManager: ObservableObject {
    @Published var errorHandler = ErrorHandler()
    
    func addTodo(_ todo: Todo) {
        Task {
            do {
                try await todoUseCase.addTodo(todo)
                await MainActor.run {
                    todos.append(todo)
                    applyFilter()
                }
            } catch {
                await MainActor.run {
                    errorHandler.handle(error)
                }
            }
        }
    }
}
```

### 5. 性能优化

#### 大数据量处理
```swift
// 分页加载
class PaginatedTodoManager: ObservableObject {
    private let pageSize = 50
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var hasMoreData = true
    
    func loadMoreTodos() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        Task {
            // 加载下一页数据
            let newTodos = try await repository.fetchTodos(
                offset: todos.count,
                limit: pageSize
            )
            
            await MainActor.run {
                todos.append(contentsOf: newTodos)
                hasMoreData = newTodos.count == pageSize
                isLoading = false
            }
        }
    }
}

// 虚拟化列表 (SwiftUI LazyVStack)
struct VirtualizedTodoList: View {
    @ObservedObject var todoManager: PaginatedTodoManager
    
    var body: some View {
        LazyVStack {
            ForEach(todoManager.todos) { todo in
                TodoRowView(todo: todo)
                    .onAppear {
                        if todo == todoManager.todos.last {
                            todoManager.loadMoreTodos()
                        }
                    }
            }
        }
    }
}
```

### 6. 数据存储升级

#### Core Data集成
```swift
// Core Data Stack
class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
}

// Core Data Repository
class CoreDataTodoRepository: TodoRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchTodos() async throws -> [Todo] {
        let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        let entities = try context.fetch(request)
        return entities.map { $0.toTodo() }
    }
    
    // 其他方法...
}
```

### 7. 网络层准备

#### 云端同步
```swift
// 网络服务协议
protocol NetworkService {
    func uploadTodo(_ todo: Todo) async throws
    func downloadTodos() async throws -> [Todo]
    func syncTodos(_ todos: [Todo]) async throws -> [Todo]
}

// CloudKit实现
class CloudKitService: NetworkService {
    private let container = CKContainer.default()
    private let database: CKDatabase
    
    init() {
        database = container.privateCloudDatabase
    }
    
    func uploadTodo(_ todo: Todo) async throws {
        let record = todo.toCKRecord()
        try await database.save(record)
    }
    
    func downloadTodos() async throws -> [Todo] {
        let query = CKQuery(recordType: "Todo", predicate: NSPredicate(value: true))
        let result = try await database.records(matching: query)
        
        return result.matchResults.compactMap { _, result in
            switch result {
            case .success(let record):
                return Todo(from: record)
            case .failure:
                return nil
            }
        }
    }
}
```

## 🎯 实施优先级

### 高优先级 (立即实施)
1. **错误处理**: 添加统一的错误处理和用户反馈
2. **依赖注入**: 重构TodoManager支持依赖注入
3. **单元测试**: 为核心业务逻辑添加测试

### 中优先级 (近期实施)
1. **Repository模式**: 抽象数据访问层
2. **UseCase模式**: 封装业务逻辑
3. **性能优化**: 大数据量处理优化

### 低优先级 (长期规划)
1. **Core Data**: 升级数据存储方案
2. **CloudKit**: 添加云端同步功能
3. **网络层**: 完整的网络服务架构

## 📈 架构演进路径

```
当前架构 → 依赖注入 → Repository模式 → UseCase模式 → 云端同步
    ↓           ↓            ↓             ↓            ↓
 MVVM      → 可测试性   → 数据抽象    → 业务封装   → 多端同步
```

这个演进路径确保了架构的逐步改进，每个阶段都能带来明显的价值提升，同时保持系统的稳定性。
