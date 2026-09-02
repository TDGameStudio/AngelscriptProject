# SourceManager：诊断源码会话与 Parser 初始状态修复（2026-08-23）

## 目标与边界

Canonical AST 已有 snapshot-owned `asCSourceManager`，但 Legacy Parser、Builder 和
Compiler 诊断仍各自通过 `asCScriptCode::ConvertPosToRowCol()` 直接换算坐标。这会让
调试工具无法观察“诊断使用的是哪一份逻辑源码”，也无法把诊断坐标和 Canonical source
identity 放进同一套受验证的映射规则。

本次增加的是 **Builder 生命周期内、只读的诊断 source session**：它是过渡期诊断和调试
观测面，不是 public/script ABI，也没有把它错误宣称为 Cache、backend source-map 或完整
Canonical diagnostic pipeline 的替代品。

## 已实现的路径

`asCBuilder` 拥有 `diagnosticSourceManager`，并公开只读
`GetDiagnosticSourceManager()` 供内部调试和自动化测试观察。统一辅助函数
`GetDiagnosticRowColumn()` 的规则是：

```text
asCScriptCode(name, bytes, lineOffset, token offset)
        |
        +-- diagnosticSourceManager.RemapLogical(..., authored, ...)
        |       |
        |       +-- source identity accepted
        |              -> asCSourceLocation(FileID, offset)
        |              -> SourceManager.GetLineColumn()
        |
        +-- no source / offset invalid / same-name conflict
                -> legacy ConvertPosToRowCol() fallback
```

因此，已有诊断文字、section 名和无法建立 session 时的旧坐标语义均保持不变；source
identity 冲突不会令诊断读取错误的 source record。

以下入口已经改走该辅助函数：

- Parser 的 `Error`、`Warning` 和 `Info`；
- Compiler 的中心 `Error`、`Warning`、`Information` 与 `PrintMatchingFuncs`；
- Builder 接收 `asCScriptNode` 的 `WriteInfo`、`WriteWarning`、`WriteError` 重载。

这样 parser 的真实语法错误会建立可观察的 source session，并以 session 的 logical key、
line offset 和 token offset 输出坐标。

## TDD 证据

新增 `ParserDiagnosticsPublishSourceSessionCoordinates` 到
`AngelscriptNativeSourceManagerTests.cpp`。它解析带 `lineOffset = 12` 的真实非法源码：

```as
void F(
{
}
```

测试同时断言：

1. Parser 确实返回语法失败；
2. Builder session 精确保留 `/Angelscript/Game/Script/DiagnosticSource.as` 和 line offset；
3. 失配 token offset `8` 通过 session 映射为第 `14` 行、第 `1` 列；
4. 引擎接收到的 error 也带同一 section/row/column，而不只是测试事后自行换算。

红测先因为 `asCBuilder` 没有 debug observation API 而无法构建：

- `Saved/Build/cta-diagnostic-source-session-red-build/20260823_080756_879_fc526c9f`（预期失败）。

初版测试夹具使用的 `@` 在该语言上下文并不构成语法错误；将它替换为已知非法的参数列表
形状后，绿测通过：

- `Saved/Build/cta-diagnostic-source-session-syntax-fixture-build/20260823_081305_694_5b4adb3e`：成功；
- `Saved/Tests/cta-diagnostic-source-session-syntax-fixture/20260823_081323_284_486bc35d`：**6/6 PASS**。

## 由回归验证揭露并一并修复的问题

第一次完整 Frontend 回归为 **269/270 PASS**。唯一失败是
`Parser.ReuseAfterSyntaxError`：它通过内部的“无隐式 Reset”入口直接进行首次解析。根因不是
source mapping，而是 `asCParser` 构造函数没有初始化 `errorWhileParsing`、`isSyntaxError`、
`sourcePos` 和 `lastToken`；常见 public `ParseScript()` 恰好先调用 `Reset()`，掩盖了这个
未定义行为。Builder 新增成员改变栈布局后，潜伏问题被稳定暴露。

构造函数现在调用一次 `Reset()`，使 public 与内部首个 parse entry 都从同一确定状态开始。

- `Saved/Build/cta-parser-initial-state-build/20260823_081547_300_fe20c8ac`：成功；
- `Saved/Tests/cta-parser-initial-state-reuse/20260823_081559_090_f75ea72d`：**1/1 PASS**；
- `Saved/Tests/cta-diagnostic-source-session-frontend-green/20260823_081635_828_ddbf6c66`：
  **270/270 PASS，0 failures，0 not-run**。

这说明诊断 session 路由在既有 Frontend 树上没有改变可见诊断/解析结果，并顺带关闭了一个
由布局变化暴露出的 parser 初始化缺口。

## 仍未完成的范围

本闭环不能勾选 Task 2.2 或 Task 13.10。剩余工作包括：

- Builder 的所有行列直算点仍未完全收敛；例如部分全局初始化、默认参数与候选匹配路径仍直接
  调用 `ConvertPosToRowCol()`；
- `asCSourceLocation/asCSourceRange` 尚未成为 Legacy Parser/Compiler diagnostic object 的
  统一传递类型，目前只在换算点内部临时构造；
- session 生命周期目前跟随 Builder；若未来 Builder 的 reuse 模型要求“每轮 build 清空诊断
  source”，必须先定义 reset 边界并补测试，不能以无验证的清空破坏多 section build；
- Cache DTO restore、ExactStartup、backend debug/coverage/source map 还未重建或只消费同一
  source identity。

`tasks.md` 保持原有未勾选状态。本附件只记录已验证的 Parser/Builder/Compiler diagnostic
source-session 子闭环和随之发现的 parser 初始化修复。
