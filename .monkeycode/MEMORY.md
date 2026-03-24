# 用户指令记忆

本文件记录了用户的指令、偏好和教导，用于在未来的交互中提供参考。

## 格式

### 用户指令条目
用户指令条目应遵循以下格式：

[用户指令摘要]
- Date: [YYYY-MM-DD]
- Context: [提及的场景或时间]
- Instructions:
  - [用户教导或指示的内容，逐行描述]

### 项目知识条目
Agent 在任务执行过程中发现的条目应遵循以下格式：

[项目知识摘要]
- Date: [YYYY-MM-DD]
- Context: Agent 在执行 [具体任务描述] 时发现
- Category: [代码结构|代码模式|代码生成|构建方法|测试方法|依赖关系|环境配置]
- Instructions:
  - [具体的知识点，逐行描述]

## 去重策略
- 添加新条目前，检查是否存在相似或相同的指令
- 若发现重复，跳过新条目或与已有条目合并
- 合并时，更新上下文或日期信息
- 这有助于避免冗余条目，保持记忆文件整洁

## 条目

[项目知识-票夹管家App规范文档]
- Date: 2026-03-24
- Context: Agent 在审计需求文档时发现
- Category: 项目知识
- Instructions:
  - 项目名称：票夹管家
  - 项目类型：个人票据收藏移动应用
  - 核心功能：拍照存档证件、门票、车票、发票等各类票据，通过 OCR 自动提取信息并智能分类
  - 技术栈：Flutter 3.x + Riverpod 2.x + Drift + RapidOCR + Go Router
  - 设计原则：隐私优先（OCR 手动触发、数据本地存储）、智能 OCR（本地 RapidOCR）、简洁界面（无底部导航、折叠菜单）

[项目知识-需求文档EARS规范]
- Date: 2026-03-24
- Context: Agent 在审计需求文档时发现
- Category: 项目知识
- Instructions:
  - EARS 格式要求：
    - Ubiquitous: The system SHALL do X
    - Event-driven: WHEN trigger, the system SHALL response
    - State-driven: WHILE state, the system SHALL do X
    - Conditional: IF condition, the system SHALL do X
    - Completion: Upon completion, the system SHALL do X
  - EARS 关键词转换：
    - 状态查询用 WHILE
    - 进行中的过程用 AS
    - 条件判断用 IF
    - 完成事件用 Upon

[项目知识-需求文档INCOSE规则]
- Date: 2026-03-24
- Context: Agent 在审计需求文档时发现
- Category: 项目知识
- Instructions:
  - 使用主动语态
  - 避免模糊术语（如"快速"、"用户友好"）
  - 避免逃生条款（如"可能的情况下"）
  - 避免否定陈述（使用 SHALL NOT 时要重述为肯定形式）
  - 每个需求只包含一个概念
  - 明确条件（可测量的标准）
  - 一致性术语（使用术语表中的定义）
  - 避免代词（不使用"它"、"他们"、"这"）
  - 避免绝对词（避免"从不"、"总是"、"100%"）
  - 解决方案无关（关注是什么，而不是如何做）

[项目知识-四阶段工期规划]
- Date: 2026-03-24
- Context: Agent 在创建项目规范时发现
- Category: 项目知识
- Instructions:
  - 第一阶段：基础框架与用户系统（2周）
  - 第二阶段：核心票据管理与扫描矫正（3周）
  - 第三阶段：搜索与管理（2周）
  - 第四阶段：测试与基础发布（2周）
  - 总工期：约 9 周

[项目知识-存储限制]
- Date: 2026-03-24
- Context: Agent 在审计需求文档时发现
- Category: 项目知识
- Instructions:
  - 单用户总存储容量：1 GB
  - 单张图片大小：不超过 20 MB
  - 单个票据图片数量：不超过 9 张
  - 单用户票据数量：不超过 10000 条
  - 标签数量：不限制
  - 合集数量：不超过 100 个

[项目知识-登录安全约束]
- Date: 2026-03-24
- Context: Agent 在审计需求文档时发现
- Category: 项目知识
- Instructions:
  - 验证码有效期：5 分钟
  - 同一手机号 24 小时内最多发送 10 次验证码
  - 连续 5 次输入错误验证码则验证码失效
  - 单设备 24 小时内最多尝试登录 20 次

[项目知识-性能指标]
- Date: 2026-03-24
- Context: Agent 在审计需求文档时发现
- Category: 项目知识
- Instructions:
  - 应用冷启动时间：不超过 3 秒
  - OCR 识别时间：不超过 3 秒
  - 列表滑动帧率：保持 60fps
  - 图片懒加载响应：不超过 500ms
  - 搜索响应时间：不超过 1 秒（1000 条数据）

[项目知识-兼容性要求]
- Date: 2026-03-24
- Context: Agent 在审计需求文档时发现
- Category: 项目知识
- Instructions:
  - Android 版本：支持 Android 6.0（API 23）及以上
  - iOS 版本：支持 iOS 12 及以上
  - 图片格式：支持 JPEG、PNG、WebP
  - 屏幕适配：支持主流手机屏幕比例（16:9、18:9、19.5:9、20:9）
