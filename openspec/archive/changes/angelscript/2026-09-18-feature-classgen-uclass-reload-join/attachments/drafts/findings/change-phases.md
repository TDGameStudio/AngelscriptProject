# Phases in this Change

Translated from draft `findings/change-phases.md`. Approval R15.

UCLASS reload is phase 1 of one Change. Language corpus execute is out of this Change (later; not the database).

```
Phase 1  UCLASS Soft + transient Blueprint
         SoftReload method body
         same UClass*
         live instance ProcessEvent new value
         CreateBlueprint child still calls the new body

Phase 2  Finish the UCLASS seam
         FullReload add property, ProcessEvent still works
         broken reload, live instance still returns the old value

Out      PIE / file watch / Legacy 32-file port
         Language folder 807 @begin
         LevelBP / rename redirect
```

Phase 2 stays on the same stack as phase 1. `ClassGenReload` already has Full UserData and last-good `GetModule`. Missing: ProcessEvent after reload, and a new field after FullReload.
