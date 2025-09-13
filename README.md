# TodoAppiOS 📱

一个功能丰富的iOS待办事项管理应用，采用SwiftUI开发，支持任务创建、编辑、完成状态管理、优先级设置、每日任务、智能筛选等功能。

## ✨ 功能特性

### 🎯 核心功能
- **任务管理**: 创建、编辑、删除、完成待办事项
- **智能筛选**: 支持待办、已完成、每日任务三种筛选模式
- **优先级管理**: 高、中、低三级优先级，可视化颜色标识
- **时间管理**: 支持截止日期和时间设置
- **每日任务**: 支持重复性每日任务，可设置结束日期和提醒时间
- **数据持久化**: 使用UserDefaults本地存储，数据安全可靠

### 🎨 用户体验
- **现代化UI**: 基于SwiftUI的现代化界面设计
- **智能排序**: 按截止时间、优先级自动排序
- **进度追踪**: 实时显示任务完成进度
- **空状态处理**: 优雅的空状态页面设计
- **动画效果**: 流畅的交互动画和状态转换

## 🏗️ 技术架构

### 架构模式
- **MVVM (Model-View-ViewModel)**: 清晰的架构分离
- **SwiftUI**: 声明式UI框架
- **ObservableObject**: 响应式数据绑定

### 核心组件

#### 📊 数据层 (Model)
```swift
// Todo.swift - 数据模型
struct Todo: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var isCompleted: Bool
    let createdAt: Date
    var priority: Priority
    var dueDate: Date?
    var dueTime: String?
    var isDaily: Bool
    var dailyTime: String?
    var dailyEndDate: Date?
    var completedAt: Date?
}

enum Priority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium" 
    case high = "High"
}

enum TodoFilter: String, CaseIterable {
    case pending = "Pending"
    case completed = "Completed"
    case daily = "Daily"
}
```

#### 🔧 业务逻辑层 (ViewModel)
```swift
// TodoManager.swift - 业务逻辑管理器
class TodoManager: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var currentFilter: TodoFilter = .pending
    @Published var filteredTodos: [Todo] = []
    
    // CRUD操作
    func addTodo(_ todo: Todo)
    func deleteTodo(_ todo: Todo)
    func toggleCompletion(for todo: Todo)
    func updateTodo(_ todo: Todo)
    
    // 筛选和排序
    func setFilter(_ filter: TodoFilter)
    private func applyFilter()
    
    // 数据持久化
    private func saveTodos()
    private func loadTodos()
}
```

#### 🎨 视图层 (View)
- **ContentView**: 应用入口视图
- **TodoListView**: 主列表视图
- **AddTodoView**: 添加/编辑任务视图
- **TodoRowView**: 任务行视图
- **FilterChipsView**: 筛选标签视图
- **ProgressHeaderView**: 进度显示视图
- **EmptyStateView**: 空状态视图

## 📁 项目结构

```
TodoAppiOS/
├── TodoAppiOS/                    # 源代码目录
│   ├── TodoAppiOSApp.swift       # 应用入口
│   ├── ContentView.swift         # 根视图
│   ├── Todo.swift               # 数据模型
│   ├── TodoManager.swift        # 业务逻辑管理器
│   ├── TodoListView.swift       # 主列表视图
│   ├── AddTodoView.swift        # 添加/编辑视图
│   ├── Assets.xcassets/         # 资源文件
│   └── TodoAppiOS.entitlements  # 权限配置
├── TodoAppiOSTests/              # 单元测试
├── TodoAppiOSUITests/            # UI测试
├── TodoAppiOS.xcodeproj/         # Xcode项目文件
└── README.md                     # 项目文档
```

## 🚀 快速开始

### 环境要求
- **Xcode**: 15.0+
- **iOS**: 18.5+
- **Swift**: 5.0+

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd TodoAppiOS
   ```

2. **打开项目**
   ```bash
   open TodoAppiOS.xcodeproj
   ```

3. **构建运行**
   - 选择目标设备或模拟器
   - 按 `Cmd + R` 运行项目

### 构建命令
```bash
# 构建项目
xcodebuild -project TodoAppiOS.xcodeproj -scheme TodoAppiOS -destination 'platform=iOS Simulator,name=iPhone 16' build

# 运行测试
xcodebuild test -project TodoAppiOS.xcodeproj -scheme TodoAppiOS -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 📱 使用指南

### 基本操作
1. **创建任务**: 点击右上角 `+` 按钮
2. **编辑任务**: 点击任务行的编辑按钮
3. **完成任务**: 点击任务前的复选框
4. **删除任务**: 左滑任务行或使用删除按钮
5. **筛选任务**: 使用顶部的筛选标签

### 高级功能
- **设置优先级**: 在添加/编辑任务时选择优先级
- **设置截止时间**: 选择日期和时间
- **创建每日任务**: 开启"每日重复"选项
- **批量操作**: 使用菜单清除已完成或所有任务

## 🔧 架构分析

### 当前架构优势
✅ **清晰的MVVM架构**: 职责分离明确  
✅ **响应式数据绑定**: SwiftUI + ObservableObject  
✅ **组件化设计**: 可复用的UI组件  
✅ **数据持久化**: UserDefaults本地存储  
✅ **智能排序**: 多维度排序算法

### 📚 详细架构文档
查看 [ARCHITECTURE.md](ARCHITECTURE.md) 了解完整的架构分析和优化建议，包括：

- **当前架构分析**: MVVM模式的实现细节
- **优化建议**: 依赖注入、Repository模式、UseCase模式
- **性能优化**: 大数据量处理、虚拟化列表
- **数据存储升级**: Core Data、CloudKit集成
- **实施优先级**: 分阶段的架构演进计划

### 🚀 快速优化建议

#### 立即可实施的优化
1. **错误处理**: 添加统一的错误处理和用户反馈机制
2. **依赖注入**: 重构TodoManager支持依赖注入，提高可测试性
3. **单元测试**: 为核心业务逻辑添加测试覆盖

#### 中期优化目标
1. **Repository模式**: 抽象数据访问层，支持多种存储方案
2. **UseCase模式**: 封装业务逻辑，提高代码复用性
3. **性能优化**: 大数据量时的懒加载和虚拟化处理

#### 长期规划
1. **Core Data**: 升级到Core Data支持复杂查询和关系
2. **CloudKit**: 添加iCloud同步功能
3. **主题系统**: 支持深色模式和自定义主题

## 🛠️ 开发规范

### 代码规范
- **命名规范**: 使用PascalCase命名类、结构体，camelCase命名变量、函数
- **文件组织**: 按功能模块组织代码文件
- **注释规范**: 关键业务逻辑添加文档注释
- **错误处理**: 使用Result类型处理可能失败的操作

### Git规范
- **提交信息**: 使用语义化提交信息
- **分支策略**: feature/、bugfix/、hotfix/ 分支命名
- **代码审查**: 重要功能需要代码审查

## 📊 项目统计

- **代码行数**: ~800+ 行
- **文件数量**: 8个核心文件
- **支持语言**: 中文界面
- **最低iOS版本**: iOS 18.5+
- **目标设备**: iPhone, iPad

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- **开发者**: Haomin Wu
- **项目链接**: [GitHub Repository](https://github.com/your-username/TodoAppiOS)

---

**TodoAppiOS** - 让任务管理变得简单高效 🚀
