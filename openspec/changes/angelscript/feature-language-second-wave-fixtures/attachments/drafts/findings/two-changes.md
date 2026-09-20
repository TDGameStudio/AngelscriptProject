# Two independent Changes

Date: 2026-09-17. User: this can be split into two Changes. Source draft finding (Chinese original; approval R27).

Neighbors: archived `angelscript/feature-testcode-language-fixtures`; completed format Change `angelscript/refactor-language-theme-cases`. New IDs must be `<domain>/<type>-<scope>-<outcome>`.

```
angelscript/feature-language-second-wave-fixtures
└─ Language/ Auto Class Inheritance Destructors Typedef Mixin
   └─ current @begin pockets; merge ClassDeclarationCompileFail overlap

angelscript/feature-unreal-fixture-root
└─ AngelscriptTestCode/Unreal/
   └─ current pocket grammar; first batch is UClass + World
```

No dependency: Language admission does not need the Unreal root; Unreal admission does not edit the six Language author files. CodeGen already discovers non-Pending `.as` files. FileTag prefixes differ.
