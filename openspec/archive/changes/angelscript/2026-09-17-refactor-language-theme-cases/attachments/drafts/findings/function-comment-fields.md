# Function comments are more than a name

Source: exploration finding `function-comment-fields.md` (Chinese). Q14 named `@function`. Q17: the description is `@summary`.

Pending Language / Containers functions use a Doxygen block: unlabeled first paragraph, then `@Kind`, `@Covers`, `@Inputs`, `@Return`, optional `@Boundary` / `@Param`. Compile-fail `void Test()` still writes Inputs/Return (`does not compile`) and has no callable entry.

Bindings file-level `// AS-facing API` is the bind surface, not the script entry. Do not fold it into `@function`.

`@Kind` values seen in-repo include Observe, RuntimeException, WorldStory, EventHandler, Action, Helper. Language positives are almost always Observe. Fail files already carry polarity, so this Change does not import the Kind table.

Accepted function header (Q15=C2, Q16=D1, Q17):

```
/**
 * @function UseOverride
 * @summary Calling the derived object runs the override.
 * @covers override
 * @inputs a default-constructed AChild
 * @return 3
 */
```

The live AngelScript declaration still comes from `GetDeclaration` after compile. Do not author a full decl in the mark. Compile-fail cases omit `@function`.
