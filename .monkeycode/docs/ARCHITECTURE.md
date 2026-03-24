# 票夹管家 - 系统架构

## 1. 架构概述

票夹管家采用 **Clean Architecture** 分层架构，确保代码结构清晰、职责分明、易于测试和维护。

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│   (Pages, Widgets, Router)                                   │
├─────────────────────────────────────────────────────────────┤
│                   State Management Layer                      │
│   (Riverpod Providers, Notifiers)                           │
├─────────────────────────────────────────────────────────────┤
│                   Business Logic Layer                       │
│   (Services, Use Cases)                                     │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                              │
│   (Database, Repositories, Engines)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 技术架构图

```mermaid
graph TB
    subgraph "Presentation Layer"
        P[Pages]
        W[Widgets]
        R[Router]
    end

    subgraph "State Management"
        SM[State Management<br/>Riverpod]
    end

    subgraph "Domain Layer"
        D[Domain Models]
        I[Interfaces]
    end

    subgraph "Data Layer"
        subgraph "Repositories"
            RR[Repositories]
        end
        subgraph "Services"
            S[OCR Service]
            IP[Image Processing]
            ST[Storage Service]
            A[Auth Service]
        end
        subgraph "Database"
            DB[(SQLite<br/>Drift)]
        end
        subgraph "File System"
            FS[Local Files]
        end
    end

    P --> R
    R --> SM
    SM --> I
    I --> RR
    RR --> DB
    RR --> FS
    S --> D
    IP --> D
    A --> D
    ST --> FS
```

---

## 3. 核心模块

### 3.1 数据库架构

```mermaid
erDiagram
    USER ||--o{ BILL : owns
    USER ||--o{ COLLECTION : owns
    USER ||--o{ TAG : owns
    BILL ||--o{ BILL_IMAGE : has
    BILL ||--o{ TAG : tagged_with
    BILL ||--o| COLLECTION : belongs_to
    BILL ||--o| RECYCLE_BIN : deleted_to
```

### 3.2 模块依赖关系

```mermaid
graph LR
    A[main.dart] --> B[app.dart]
    B --> C[Router]
    C --> D[Pages]
    D --> E[Providers]
    E --> F[Services]
    E --> G[Repositories]
    G --> H[Database]
    G --> I[File System]
    F --> J[OCR Engine]
    F --> K[Image Processing]
```

---

## 4. 数据流

### 4.1 票据创建流程

```mermaid
sequenceDiagram
    participant U as User
    participant P as Pages
    participant PR as Providers
    participant S as Services
    participant R as Repositories
    participant DB as Database

    U->>P: 选择图片
    P->>PR: updateImages()
    U->>P: 点击扫描矫正
    P->>S: scanAndCorrect()
    S-->>P: 处理后图片
    U->>P: 点击识别文字
    P->>S: recognizeText()
    S-->>P: OCR结果 + 推荐标签
    U->>P: 添加标签、填写信息
    U->>P: 点击保存
    PR->>R: saveBill()
    R->>DB: insert()
    DB-->>R: billId
    R-->>PR: bill
    PR-->>P: 跳转详情页
```

### 4.2 搜索流程

```mermaid
sequenceDiagram
    participant U as User
    participant P as SearchPage
    participant PR as SearchProvider
    participant R as BillRepository

    U->>P: 输入关键词
    U->>P: 选择筛选条件
    U->>P: 点击搜索
    P->>PR: search()
    PR->>R: searchBills()
    R->>R: buildQuery()
    R-->>PR: results
    PR-->>P: 显示结果
```

---

## 5. 状态管理架构

```mermaid
graph TB
    subgraph "Auth States"
        AU[authStateProvider]
    end

    subgraph "Bill States"
        BL[billListProvider]
        BD[billDetailProvider]
        BE[billEditProvider]
        BF[billFilterProvider]
    end

    subgraph "Resource States"
        CL[collectionListProvider]
        TG[tagListProvider]
    end

    subgraph "UI States"
        TH[themeProvider]
        SE[searchProvider]
    end

    AU -.->|updates| BL
    BE -.->|creates| BL
    BF -.->|filters| BL
    CL -.->|used by| BF
    TG -.->|used by| BF
```

---

## 6. 路由架构

```mermaid
stateDiagram-v2
    [*] --> SplashPage
    
    state SplashPage {
        [*] --> checkAuth
        checkAuth --> isLoggedIn: 已登录
        checkAuth --> isNotLoggedIn: 未登录
    }
    
    SplashPage --> LoginPage: 未登录
    SplashPage --> HomePage: 已登录
    
    LoginPage --> HomePage: 登录成功
    LoginPage --> SplashPage: 取消
    
    HomePage --> PersonalCenterPage: 头像点击
    HomePage --> SearchPage: 搜索框点击
    HomePage --> ImageEditPage: 上传按钮
    HomePage --> FoldMenu: 菜单图标
    
    FoldMenu --> RecycleBinPage
    FoldMenu --> TagManagementPage
    FoldMenu --> CollectionManagementPage
    FoldMenu --> SettingsPage
    FoldMenu --> HelpFeedbackPage
    
    ImageEditPage --> BillDetailPage: 保存
    
    BillDetailPage --> BillEditPage: 编辑
    BillDetailPage --> RecycleBinPage: 删除
    BillEditPage --> BillDetailPage: 保存
```

---

## 7. 安全架构

### 7.1 数据安全

| 安全措施 | 实现方式 |
|----------|----------|
| 本地存储 | 所有数据存储在应用私有目录 |
| OCR 触发控制 | 必须用户手动点击，不自动识别 |
| 登录验证 | 手机号 + 验证码 |
| 回收站保护 | 30 天后自动删除，提供恢复选项 |

### 7.2 隐私设计

```
┌────────────────────────────────────────┐
│              隐私优先设计                 │
├────────────────────────────────────────┤
│  ✓ 数据默认本地存储，不自动上传云端        │
│  ✓ OCR 由用户手动触发                    │
│  ✓ 无底部导航，减少误操作                │
│  ✓ 折叠菜单收纳次要功能                  │
└────────────────────────────────────────┘
```

---

## 8. 性能架构

### 8.1 图片加载策略

```mermaid
graph LR
    A[原图] -->|首次加载| B[生成缩略图]
    B --> C[缓存缩略图]
    C --> D[列表展示]
    D -->|点击| E[加载原图]
    E --> F[全屏预览]
```

### 8.2 数据库优化

| 优化项 | 实现方式 |
|--------|----------|
| 索引 | 对外键和常用查询字段建立索引 |
| 分页 | 列表查询使用分页，避免全表扫描 |
| 事务 | 批量操作使用事务保证一致性 |

---

## 9. 错误处理架构

```mermaid
graph TB
    E[Error Occurs] --> T{Error Type}
    T -->|Network| N[网络错误处理]
    T -->|Storage| S[存储错误处理]
    T -->|OCR| O[OCR 错误处理]
    T -->|Image| I[图像处理错误]
    T -->|Database| D[数据库错误处理]
    
    N --> U[显示友好提示]
    S --> U
    O --> U
    I --> U
    D --> U
```

---

## 10. 技术选型理由

| 技术 | 选型 | 理由 |
|------|------|------|
| Flutter | 跨平台框架 | 一套代码支持 Android/iOS，开发效率高 |
| Riverpod | 状态管理 | 轻量、无嵌套、编译时安全、易测试 |
| Drift | 数据库 ORM | 类型安全、声明式、迁移方便 |
| RapidOCR | OCR 引擎 | 本地运行、离线可用、中文支持好 |
| Go Router | 路由管理 | 声明式路由、深链接支持、类型安全 |
