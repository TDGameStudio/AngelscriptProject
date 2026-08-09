# feature-ue-angelscript-standalone-compiler SDD progress

- Goal: implement the full `feature-ue-angelscript-standalone-compiler` OpenSpec.
- Starting state: 0/180 OpenSpec tasks complete; no `Plugins/Angelscript/Standalone/` directory exists.
- Workspace constraint: use the current main checkout; do not create a worktree.
- Preserve existing user changes in `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageInputTests.cpp`, `AngelscriptCoverageUStructTests.cpp`, and `Shared/AngelscriptTestMacros.h`.
- Current milestone: portable/native checkpoint is green on both hosts; Phase 1 remains open while hard memory isolation, full LanguageCore facade parity, declaration/oracle work, corpus, and documentation are completed. Phase 2 contract types/identity/canonical serialization are next.
- Fresh evidence (2026-07-31):
  - `Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix standalone-native-checkpoint -TimeoutMs 600000`: 7/7 CTest passed.
  - `Tools\RunBuild.ps1 -TimeoutMs 1800000 -NoXGE`: UE 5.8 Win64 Development succeeded at `Saved/Build/build/20260731_021403_502_e7943456`.
- Do not mark Phase 1 complete: the current allocation ceiling is a safe-boundary termination signal, not yet a hard process allocation boundary.
- Phase 2 checkpoint (2026-07-31): tasks 2.1-2.3 are green. The value-only contract records, versioned SHA-256 semantic IDs, and canonical UTF-8/LF JSON/JSONL golden are covered by `3/3` focused Automation tests at `Saved/Tests/offline-contract-core-golden/20260731_022350_439_37dd1a43`.
- Phase 2 final-engine observer (task 2.4) is green. It exports the complete public registration surface without binding hooks or native addresses, handles wildcard type IDs safely, records string-factory state, and proves representative `FVector`, `FString`, and `AActor` registrations. Fresh full prefix: `5/5` at `Saved/Tests/offline-contract-observer-full-green-3/20260731_024742_553_2d9e6c1c`.
