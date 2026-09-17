# Pending Language fixtures

Next-wave hand-authored containers that are not part of the admitted 47-file Language catalog.

`CodeGenTool` discovery skips the `Pending/` root, so these files do not require plugin C++ projections yet. Promote a file by moving it to `Language/<theme>/<name>.as` and running `codegen.py generate` when plugin writes are allowed.

Intended FileTags after promotion:

| Pending path | FileTag |
| --- | --- |
| `Language/Syntax/Class.as` | `Language/Syntax/Class` |
| `Language/Syntax/Inheritance.as` | `Language/Syntax/Inheritance` |
| `Language/Syntax/Destructors.as` | `Language/Syntax/Destructors` |
| `Language/Syntax/Typedef.as` | `Language/Syntax/Typedef` |
| `Language/Syntax/Properties.as` | `Language/Syntax/Properties` |
