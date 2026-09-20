# When runtime bytecode is written onto asCScriptFunction

Pinned for this draft. The user asked the agent to settle the moment; Q13/Q15 already force it. This is not lazy execution and not Emit.

## Purpose

Runtime bytecode is the Engine-local DWORD stream the VM actually steps. It exists only on an `asCScriptFunction` that this Engine owns. Stable bytecode (StableKey slots) is a different object and is produced earlier, without an Engine.

## Lifecycle

```text
asCBuilder / Emit
 └─ asCScriptFunction.稳定字节码            // 可以没有 Engine；还不能跑

asCCompileOutput / ClassGen
 └─ 不碰 runtime 码

asCEngineCompileRegistration  ◆
 ├─ Install                                 // Engine 拥有 Function；仍无 runtime 码
 └─ Link（同一 Registration 成功之前必须做完）
      └─ 写出 Function.runtime 可执行字节码  // 唯一生成时机
           └─ 之后才允许 Prepare / Execute

asCContext::Prepare
 └─ 只读取已有 runtime 码                    // 找不到 → asNO_FUNCTION；不生成
```

From outside, Registration is one success: Install then Link are not separately observable. A script function with a body is not callable until that success.

## Why this moment

Link needs this Engine’s TypeInfo*/function pointers and layout. Emit cannot produce it. First `Prepare` must not grow a new half-state or hide MissingDeclaration until gameplay. Native `BindNativeFunction` writes `sysFuncIntf`, not script runtime bytecode.

## Today (code)

```text
caller
 └─[calls] Engine.RegisterMetadataImage(Image)     // 定义进 Engine；Function.scriptData 仍空
    └─[calls] asLinkByteCodeImage(Engine, ByteCodeImage)  ◆
       ├─[reads] Engine.FindMetadataType/Function(StableKey)
       ├─[calls] LowerFunction → Executable.AllocateScriptData()
       └─[writes] Snapshot.Executables + PublishExecutable(Key)
            └─ Prepare → AcquirePublishedExecutable → 只读 scriptData
```

```cpp
// Simplified from as_bytecode_linker.cpp asLinkByteCodeImage / LowerFunction
asEByteCodeLinkStatus asLinkByteCodeImage(Engine, Image, OutSnapshot)
{
    // requirements must already be on this Engine or MissingDeclaration
    for (Body : Image.Functions)
    {
        Function = Engine.FindMetadataFunction(Body.FunctionKey);
        LowerFunction(Body, Executable, Engine, Image, Lifetime);
        // AllocateScriptData(); write lowered DWORDs into Executable.scriptData
        Snapshot->Executables.Add(Body.FunctionKey, Executable);
    }
    Engine.CommitExecutablePublication(*Snapshot, Generation);
}

// Simplified from as_context.cpp Prepare
BindExecutableFor(m_currentFunction);
if (funcType == asFUNC_SCRIPT && !m_currentExecutable)
    return asNO_FUNCTION;   // does not Link, does not Emit
```

## After (contract)

Same moment, fewer objects: Link writes onto `asCScriptFunction` itself. `asCExecutableFunction` is not public. Registration owns the call; callers do not call a public `asLinkByteCodeImage` as a third ritual.

| Event | Stable bytecode | Runtime bytecode |
| --- | --- | --- |
| Function constructed | no | no |
| Emit | written | no |
| ClassGen reads CompileOutput | unchanged | no |
| Registration.Install | unchanged | no |
| Registration.Link | unchanged | **written, once, this Engine** |
| Prepare / Execute | unchanged | read only |
| BindNativeFunction | empty | not used (`sysFuncIntf`) |

Reload/replace of a body is a later Registration/Link generation, not a first-call side effect.
