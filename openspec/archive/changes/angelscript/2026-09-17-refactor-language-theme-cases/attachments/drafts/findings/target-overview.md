# What this Change is for

Source: exploration finding `target-overview.md` (Chinese). Approval: R20.

One sentence: turn hand-authored Language `.as` files from a fake modification tree plus privileged `root` into theme pockets with several cases; split compile-fail and runtime-fail; write Parent only for a real edit chain; attach a call contract to callable script functions.

```
code-database / parser / Builder
├─ drop "exactly one root"
├─ allow several parentless VersionTags
├─ open a case with @begin <tag>; file header stays @version v1
└─ retarget Get(..., "root") / Parent==root tests and Adoption

Author files (all Language/*.as)
├─ lengthen only the four Casting leaves
├─ split mashup roots; move Bleed
├─ move negatives into *CompileFail / *RuntimeFail
└─ mark callables with @function and the contract fields

Unchanged
├─ 122 generator products
├─ asCBuilder / diagnostic oracles
├─ TestFramework UFUNCTION(meta=(AngelscriptTest))
└─ treating admission as compile or execute
```
