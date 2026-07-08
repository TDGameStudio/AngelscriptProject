## 1. Source Layout

- [x] 1.1 Move `UASFunction` declarations into `ASFunction.h` while keeping `ASClass.h` compatible.
- [x] 1.2 Extract shared script-call helper code for the split implementation files.
- [x] 1.3 Split `UASFunction` implementation into base, dispatch, and JIT dispatch files.
- [x] 1.4 Split `UASClass` implementation into metadata and construction files.

## 2. Verification

- [x] 2.1 Build `AngelscriptProjectEditor` through `Tools/RunBuild.ps1`.
- [x] 2.2 Run targeted `Generator.ASFunction` automation tests.
- [x] 2.3 Run targeted `Generator.ASClass` automation tests.
- [x] 2.4 Run UFunction and networking coverage automation tests.
