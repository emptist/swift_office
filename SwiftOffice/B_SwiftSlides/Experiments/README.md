# Experiments 目录

此目录包含 SwiftSlides 框架的各种实验性实现。

## 子目录

### ProtocolComposition/

**Protocol Composition 模式实验** - 当前主要实验

探索如何使用 Swift 的协议组合功能创建 PowerPoint 演示文稿。

**核心特点：**
- 工具代码（Core/）与用户内容（Presentations/）完全分离
- 使用 Protocol Composition 定义幻灯片能力
- 数据与呈现分离
- 支持多个演示文稿共存

**快速开始：**
```bash
cd ProtocolComposition
swift run 医院管理总览
swift run 销售报告
```

详见 [ProtocolComposition/README.md](ProtocolComposition/README.md)

## 其他实验文件

此目录下可能还包含其他实验性文件，这些是开发过程中的尝试：
- `ScriptModeSupport.swift` - 早期脚本模式实验
- `HospitalManagementDemo.swift` - 早期混合版本
- `Core.swift` - 早期核心代码
- `医院管理总览.swift` - 早期单文件版本
- `SwiftSlidesCore.*` - 编译生成的模块文件

这些文件保留了开发历史，供参考使用。

## 实验状态

所有此目录下的代码都是**实验性**的：
- API 可能会变化
- 不保证向后兼容
- 可能会整合到主框架中

## 与主框架的关系

实验成功的模式会逐步整合到 `B_SwiftSlides/Sources/` 主框架中。
