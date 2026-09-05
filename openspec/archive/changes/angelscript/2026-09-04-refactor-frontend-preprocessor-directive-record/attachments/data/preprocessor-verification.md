# Frontend preprocessor verification

## TDD sequence

- Task `1.1` expected RED build `b2f6b522469c40bea4e15e50b6e883c5` failed because `frontend/as_preprocessor.h` did not exist. GREEN build `3e3bc625ac244248be3e7e6b90b11c1c` and exact Fast run `ca50cd6829f5497d95215c009718301e` passed the initial 6/6 routing tests.
- Task `1.2` expected RED build `bc2e049cd50d453bbc9b218da626c346` failed because `frontend/as_directive_tree.h` did not exist. GREEN build `5ca00384badc4bdb948788f519fabda2` and exact Fast run `4ff509c5f3614974af4fb0d18fe5b49c` passed 12/12 routing and tree tests.
- Task `1.3` expected RED build `e63a8a24ab8849d1a40bb9bc5a44fcfb` failed on the absent typed restriction contract. GREEN build `2aa8b3e44d0d4123be1b65d363487699` succeeded.
- Task `1.3` run `f9ed51a14ac24027a9e21bae1596494a` exposed a CQTest fixture-name collision: the process succeeded but its Automation summary contained only 6 tests. Unique `Preprocessor*` class names repaired registration without changing the public area prefix. Run `99f6e49aa92e45a397e0024bdc73f02b` then passed 18/18 with zero warnings, errors, or skips.
- Task `2.1` expected RED build `a37b269f16694b66a39a99a46d5d0989` failed only because `frontend/as_preprocessing_record.h` was absent. GREEN build `1b18079526de48368b6c8c7f2c7297fe` and exact Fast run `16d62956b77e45a88f2f1a80197d2ce9` passed 24/24.
- Final incremental Editor build `9a16cffc96f149dfacfb4ed6822a03f9` succeeded. Final exact Fast test `f92f26a5f14c4cbfb6c5ed2c1281b7a0` passed 24/24 with 0 failed, 0 skipped, 0 not-run, 0 warnings, and 0 errors.

The final Automation report is `Saved/Harness/Unreal/Runs/f92f26a5f14c4cbfb6c5ed2c1281b7a0/AutomationReport/index.json`. It enumerates only the `PreprocessorRouting`, `PreprocessorDirectiveTree`, `PreprocessorPolicy`, and `PreprocessorRecord` fixtures in `NewVersion/NativeEngine/Preprocessor`.

## Final content identity

| File | SHA-256 |
|---|---|
| `frontend/as_directive_kinds.def` | `c9d5d5f079781ea871b80f675d791d724213999dc8d99180136b4aff2b32c4b8` |
| `frontend/as_directive_tree.h` | `5f6a4606d4b6dcb9f82378cce25b911021f3f530ca6641455fafe653a65df204` |
| `frontend/as_directive_tree.cpp` | `09b9e8d64091262be6631abc9a5aa1cbb021c5e86eb4214b9b4ea8eb1ae2715e` |
| `frontend/as_preprocessor.h` | `92a7445f408402734f25d60bd68d40385473b6d10fe7cf2284e7cef947d52301` |
| `frontend/as_preprocessor.cpp` | `072c22d42511ffa7e09d949ccdf7225b011b929b1c6a588143729f389fd8822d` |
| `frontend/as_preprocessing_record.h` | `04d326fd42bb871ae83ea9eb97718d725db5e9087dc5cba5a37a3316d66e107a` |
| `frontend/as_preprocessing_record.cpp` | `4a4fef0efa3cd8d77cf4f264e416922414d67d49bb77a74d1a2120ef0ccfbb83` |
| `NativePreprocessorTestSupport.h` | `64a28869fb74874d170c1338602bd2ed022b61503c83f0598596251f7c3e43f5` |
| `AngelscriptNativePreprocessorDirectiveRoutingTests.cpp` | `8c9752da646c7a049001b236d8351aa9adfb14b6abea20a164c0e6ac964fe5d4` |
| `AngelscriptNativeDirectiveTreeTests.cpp` | `744643010873704066981d1d9977c318eb97d26ec063453df65f6ecafd22e289` |
| `AngelscriptNativePreprocessorPolicyTests.cpp` | `d45e8448336b70f787e16be59c86189651f07c89cf12bc97c79d3c2ff8cf9fbc` |
| `AngelscriptNativePreprocessingRecordTests.cpp` | `998fb699bad293736df51a173b61b17091ca61d4baff421260be520f1b61f2ff` |
| current `preprocessing/spec.md` | `c57b68306abaedb2320e1842e3b1b1031aafd8d3e34a710d434ad36427abf1c3` |

## Durable contract and knowledge

- CLI-created capability `angelscript/language/frontend/preprocessing` contains all seven requirements without delta-operation headings.
- `preprocessing/knowledges/clang-directive-and-source-backquery.md` retains the adopted Clang separation and snapshot-owner guidance.
- Strict active-Change validation passed 1/1; strict all-current-spec validation passed 10/10.
- OpenSpec doctor run `05a29dadc75647d394b6c4ab590a2a6a` reported valid with zero diagnostics; TaskPlan run `8330125a2d934e28b8fde4f9009ff9f9` reported complete 7/7.

## Impact boundary

The new preprocessor compiles inside the isolated frontend boundary and is exercised only through `NewVersion` CQTests. It does not replace or call the production `FAngelscriptPreprocessor`, Parser, Builder, Engine, reflection publication, dependency construction, VM, Standalone, or quarantined legacy test framework. It performs no textual macro expansion, include loading, or keyword-driven module loading.

Harness aggregate `Quick`, `Performance`, and `Integration` profiles, full UE suites, Standalone tests, legacy preprocessor tests, upper Runtime tests, and Unreal product builds were intentionally omitted. The incremental Editor build and complete 24-test isolated Preprocessor prefix directly prove the changed boundary. The one discovered test-registration collision was repaired locally and the final report count proves all fixtures execute.

