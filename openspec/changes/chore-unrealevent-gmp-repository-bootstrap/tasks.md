## 1. OpenSpec Setup

- [x] 1.1 <!-- Non-TDD --> Validate `chore-unrealevent-gmp-repository-bootstrap` artifacts with `openspec validate "chore-unrealevent-gmp-repository-bootstrap" --strict --json`.

## 2. Standalone Repository

- [x] 2.1 <!-- Non-TDD --> Create a fresh local `UnrealEventPlugin` repository from `D:\Workspace\UnrealEvent\Plugins\GenericMessagePlugin`, excluding generated artifacts (`Binaries/`, `Intermediate/`, `Saved/`, IDE folders, caches).
- [x] 2.2 <!-- Non-TDD --> Rename the plugin bootstrap identity from GMP to UnrealEvent enough for repository identity and UBT discovery: descriptor filename/content, primary module folder/build/module names, README, notice, and gitignore.
- [x] 2.3 <!-- Non-TDD --> Preserve GMP Apache 2.0 attribution by keeping the license text and adding notice text for GMP-derived portions.
- [x] 2.4 <!-- Non-TDD --> Initialize the standalone repo with a fresh initial commit, set `origin` to `git@github.com:TDGameStudio/UnrealEventPlugin.git`, and verify `git status --short --branch`, `git log --oneline`, and `git remote -v`.

## 3. Host Submodule Integration

- [x] 3.1 <!-- Non-TDD --> Add `git@github.com:TDGameStudio/UnrealEventPlugin.git` as the host submodule at `Plugins/UnrealEvent`, using the local bootstrap repository when the remote is not yet available.
- [x] 3.2 <!-- Non-TDD --> Enable the `UnrealEvent` plugin in `AngelscriptProject.uproject` and keep `.gitmodules` consistent with the existing plugin submodule pattern.
- [x] 3.3 <!-- Non-TDD --> Update root setup documentation to mention the `Plugins/UnrealEvent` submodule and the deferred GMP pruning boundary.

## 4. Verification

- [x] 4.1 <!-- Non-TDD --> Verify host submodule metadata with `git submodule status -- Plugins/UnrealEvent` and `git config --file .gitmodules --get submodule.Plugins/UnrealEvent.url`.
- [x] 4.2 <!-- Non-TDD --> Run build discovery with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label unrealevent-submodule-bootstrap -TimeoutMs 180000 -NoXGE`.
- [x] 4.3 <!-- Non-TDD --> Re-run `openspec validate "chore-unrealevent-gmp-repository-bootstrap" --strict --json` and confirm all tasks are complete.
