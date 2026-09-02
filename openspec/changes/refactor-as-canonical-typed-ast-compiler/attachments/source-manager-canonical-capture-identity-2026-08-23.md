# SourceManager：Canonical Parser/Sema 源身份 fail-closed 修复（2026-08-23）

## 问题与根因

`asCSourceManager::RemapLogical()` 原本已经能拒绝“相同 logical key + origin、但 source
bytes 或 line offset 不同”的重映射。不过 Canonical Parser/Sema capture 没有使用它：
`asCSema` 仅以 `parsedSection`（section 名）缓存 `parsedFile`。

因此在同一个 `asCASTContext` 中先后处理下面两个 `asCScriptCode` 时：

```text
SharedLogicalSection.as, lineOffset=3: int First() { return 1; }
SharedLogicalSection.as, lineOffset=7: int Other() { return 2; }
```

第二段会错误复用第一段的 FileID。新 declaration/statement/expression 的 token offsets
随后被解释成第一段的文本坐标；即使没有越界，也会成为**可封存、却指向错误源码的 AST**。
这是 SourceManager 只能作为“旁路数据结构”而不是真相源的具体漏洞。

## 修复

1. `asCASTContext` 新增 `RemapSourceSection()`，和 `AddSourceSection()` 一样受 seal
   防火墙保护，但调用 `asCSourceManager::RemapLogical()`，从而由 Context 保持 source
   ownership；
2. `asCSema::PrepareParsedSource()` 统一比较 logical key、完整字节内容和 `lineOffset`，
   并把结果缓存在本次 parser callback 的 source identity 中；
3. declaration、expression、statement、control-stub、parameter 和 enumerator action 均先
   经过这一入口；
4. 冲突时清除当前 `parsedFile`、记录稳定诊断 token
   `source-remap-mismatch`，并停止该段 Canonical AST capture。它**不**修改旧源码记录，也
   不给新节点伪造旧 range；Legacy Parser 自身仍可完成语法解析。

```text
Parser callback
  |
  +-- PrepareParsedSource(script)
         |
         +-- Context.RemapSourceSection(name, authored, bytes, lineOffset)
                |
                +-- same identity  -> existing snapshot-local FileID
                +-- new identity   -> allocate snapshot-local FileID
                +-- same name but changed bytes/offset -> 0
                                                     |
                                                     +-- source-remap-mismatch
                                                         no Canonical node write
```

这条规则是 fail-closed：捕获图宁可缺失冲突段，也不能生成范围看似有效、实际归属另一份
源码的 sealed graph。

## TDD 证据

新增
`ParserSemaRejectsChangedContentForSameLogicalSection` 到
`AngelscriptNativeSourceManagerTests.cpp`。它用真实 `asCParser + asCSema`（不是 mock）
解析同名的两份不同源码，要求：

- Legacy syntax parse 仍成功；
- Sema 报 `source-remap-mismatch`；
- 第二段不会增加 Canonical declaration；
- SourceManager 不创建第二个歧义 source record；
- 第一段 source bytes 仍是权威内容。

红测：

- 构建：`Saved/Build/cta-source-identity-red-build/20260823_080121_452_5e5d094f`，成功；
- 测试：`Saved/Tests/cta-source-identity-red/20260823_080138_245_80832eeb`，**4/5 PASS，1
  expected failure**（缺少 `source-remap-mismatch`）。

绿测：

- 构建：`Saved/Build/cta-source-identity-green-build/20260823_080401_309_e5d8132f`，成功（29 actions）；
- SourceManager 组：`Saved/Tests/cta-source-identity-green/20260823_080435_647_69f5a988`，**5/5 PASS**；
- Native SDK Frontend 前缀：`Saved/Tests/cta-source-identity-frontend-regression/20260823_080521_189_7396f903`，**269/269 PASS，0 failures，0 not-run**。

## 尚未完成的范围

这不是 Task 2.2 或 R10/Task 13.10 的全量完成。当前修复建立的是 **Canonical capture
入口** 的可靠 source identity。仍需迁移的范围包括：

- Legacy Lexer/Parser 的 `Error/Warning/Info` 仍通过 `asCScriptCode::ConvertPosToRowCol()`
  直接计算坐标，尚未以 `asCSourceLocation/asCSourceRange` 作为统一诊断输入；
- Builder/legacy compiler 诊断、source provenance 与 Canonical source ranges 尚未共享一个
  完整的 source-session owner；
- Cache AST DTO restore 还没有重建这些 source records 并验证 ExactStartup 坐标；
- Backend debug/coverage/source maps 还没有全部只消费 Canonical source model。

所以 `tasks.md` 的 2.2、13.10 保持未勾选；本附件记录的是它们的一个已验证子闭环，而非
把未接入的诊断链路误报为已完成。
