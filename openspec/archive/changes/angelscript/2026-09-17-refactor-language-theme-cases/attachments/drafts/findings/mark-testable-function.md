# Mark a function as testable

Source: exploration finding `mark-testable-function.md`. Directive name settled as `@function` (Q14).

Do not reuse `UFUNCTION(meta=(AngelscriptTest))`, HotReload `@oracle`, `Observe_*` prefixes, or `@point` / `@breakpoint`.

The mark answers which **script** function C++ may `Prepare`. Not the bind surface. Helpers stay unmarked. Compile-fail cases have no mark.

The live declaration is filled after compile with `GetFunctionByName` then `GetDeclaration`. The function header also carries `@summary` / `@inputs` / `@return` (see [function-comment-fields.md](function-comment-fields.md)).
