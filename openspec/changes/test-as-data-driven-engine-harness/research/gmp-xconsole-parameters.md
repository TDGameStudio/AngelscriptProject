# GMP XConsole vs data-driven `Parameters`

Offline look at `Reference/GenericMessagePlugin` (`XConsoleManager`, `XConsoleCommandMeta`). GMP is not imported. This only answers: if a DataDriven leaf later needs a **complex payload**, where does that payload live?

## What XConsole actually does

UE console commands still arrive as **tokens**: `TArray<FString> Args`. GMP’s `FXConsoleCommandLambda*` then maps those strings onto a typed lambda via `GMP::Serializer::SerializedInvoke` (`GMPArchive.h`).

Per-argument decode (`TParameterSerializer` in `XConsoleManager.h`):

1. Empty string → leave the C++ default / `TOptional` unset.
2. Token starting with `@` → load that **file** and decode the file body.
3. Body starting with `{` or `[` → `Json::FromJson` into the USTRUCT / property type.
4. Otherwise → `FProperty::ImportText`.

Tokenizer (`XSplitCommandLine`) is quote-aware so a JSON object can survive as **one argv token** if quoted. `z.XCmdList` feeds a file of commands. Pipeline pause/continue and `CommandPipelineInteger` / `String` are for sequential console scripts, not Automation leaves.

So XConsole’s answer to “the argument is too fat for a command line” is: **typed decode of tokens, JSON in a token, or `@file`**. The command *name* stays a short key.

## Why we cannot paste that onto COMPLEX `Parameters`

`FAutomationTestBase::GenerateTestNames` builds

```text
CompleteTestName = TestName + " " + Parameters
```

`FBridge` (and this harness) parse the command as **everything after the last space**. A JSON blob, a Windows path with spaces, or a quoted argv list in `Parameters` will split wrong. Automation is **one string**, not `TArray<FString>`.

| Channel | GMP XConsole | DataDriven COMPLEX |
|---|---|---|
| Wire | several argv tokens | one `Parameters` string |
| Complex value | JSON token or `@file` | catalog / generator **snapshot** keyed by `theme/caseId@profileId` |
| Type check | `MakeStaticNames` + runtime decode | observation `kind` + `decl` in JSON |
| Sequential scripts | pause/continue pipeline | UE already calls `RunTest` per leaf; do not import the pipeline |

## What to copy

1. **Keep the public command tiny.** XConsole never puts the USTRUCT in the command *name*. We never put observations, `cacheRoot`, or engine config in `Parameters`.
2. **Structured data stays JSON, off the wire.** Catalog `cases.json` is already that store. Generated products stay in the snapshot (or dumped on failure). Later `executeStruct` / expected maps belong in the catalog object, not in the Automation command.
3. **`@file` is a later sidecar, not Wave A.** If a generated AS or expected blob is too large to keep in the enumerate snapshot, write `Saved/Automation/DataDriven/<leaf>/payload.json` during `GetTests` / first `RunTest`, and look it up **by the same key**. Do not splice the path into `Parameters` (spaces). Do not copy GMP’s `SerializedInvoke` into the Automation bridge.
4. **Do not copy** console meta (`FXConsoleMeta` ClampMin/UI), HTTP command ingest, or pipeline `{"code":n}` output. Failures go through `ExecutionInfo` and `[AS-SOURCE-BEGIN]` dumps.

## How this harness moves complex payloads

Automation is not a console. Do not paste XConsole’s JSON/`@file` onto COMPLEX `Parameters`.

```text
  cases.json / generator table          GetTests                    RunTest
  (already JSON)                   command = KEY only          lookup KEY → snapshot
         │                              │                              │
         └──────── snapshot[key] ───────┴── fixtures, observations, ───┤
                                           generated source, cacheRoot  │
                                                                        ▼
                                                              session runs AS
                                                                        │
                    ┌───────────────────────────────────────────────────┤
                    │ ExecutionInfo   pass/fail, Info-skip, error text
                    │ log dump        [AS-SOURCE-BEGIN] on generated fail
                    │ Saved file      perf JSON (v1); later actual.json
                    └───────────────────────────────────────────────────┘
```

**Inbound.** The catalog object is the fat bus. Later `executeJson`, function `args`, or map oracles are new fields on that object. C++ deserializes them in the session (XConsole’s idea: typed decode of JSON — without putting JSON on argv). If the enumerate snapshot must not hold a megabyte of generated AS, write `Saved/Automation/DataDriven/<leaf>/source.as` and store that relative path **in the snapshot**. Never splice it into `Parameters`.

**Outbound.** `RunTest` returns `bool`. There is no typed Automation result payload. Session Frontend / `RunTests.ps1` consume `ExecutionInfo`. Each leaf prints a compact `[AS-DD-DRIVER]` Info line so the driving row is visible without stuffing JSON into `Parameters` (`design.md` Decision 15). Humans need the generated source in the log on failure. CI that wants a blob collects a file under `Saved/Automation/`, named from the same key.

Wave A needs none of the later observation kinds. `theme/caseId@profileId` plus snapshot observations is enough. Do not copy `SerializedInvoke`.

## Wave A consequence

`theme/caseId@profileId` remains sufficient. Complex expected values, when added, extend the **catalog schema** (new observation fields), not the command string. GMP confirms the split; it does not justify packing JSON into `OutTestCommands`.
