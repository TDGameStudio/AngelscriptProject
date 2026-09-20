# reload-classgen-join glossary

Translated from draft `designs/reload-classgen-join/glossary.md`. Approval R10.

| Term | Chosen | Rejected | Reason |
| --- | --- | --- | --- |
| Change | `angelscript/feature-classgen-reload-join` | `angelscript/feature-register-per-file-reload` | Outcome is reload joined to ClassGen; per-file sets are the means |
| Test class | `ClassGenReload` | extend `ClassGenMaterialization` | Neighbour already owns Initial materialization; reload is a separate case group |
| Test prefix | `Angelscript.UnitTest.NativeEngine.Compile.ClassGenReload` | | NativeEngine.Compile convention |
| Entry | `CompileModules` | restore bind helper | Same as the Initial join |
