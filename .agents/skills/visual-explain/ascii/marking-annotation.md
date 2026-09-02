# Marking & annotation

## Mark emphasis, status, or severity on tree rows with colored Unicode

A small fixed palette; anything beyond these rarely pays off:

- ⭐ Key step — the one row that matters
- ✅ Done / pass, ❌ Failed / missing, ⚠️ Partial / has a catch
- 🔴 🟡 🟢 High / medium / low (risk, cost, heat)
- ❗ Important warning
- 💡 Insight / explanation
- 📌 Fixed attention point — "look here"

They are safe on tree rows because the `├─ └─ │` spine comes first; prefer end-of-row placement. Emoji are double-width and font-dependent, so never put them inside box-drawn tables — the `│` walls will drift.

```
NewObject<T>(Outer, Class, Name, Flags, Template)
├─ FStaticConstructObjectParameters Params(Class)
└─ StaticConstructObject_Internal(Params)        ⭐ Real allocate + construct entry
    ├─ StaticAllocateObject(...)                 💡 Also registers in GUObjectArray
    └─ ClassConstructor(FObjectInitializer(...))
```

```
FAngelscriptCompiler::CompileModule()
├─ Preprocess()          ✅
├─ ParseScript()         ✅
├─ BuildTypeInfo()       ⚠️ Delegates missing
└─ StaticJIT_Emit()      ❌ Not started
```

```
HotReload change classification
├─ 🟢 function body only     →  patch bytecode in place
├─ 🟡 signature changed      →  reinstance affected classes
└─ 🔴 base class changed     →  full module recompile  📌 needs BP impact scan
```

## Put long annotations outside the figure as external callouts

When an inline `//` note would not fit on the row, pick one of these shapes instead of cramming:

- Side arrow + short text — `├──────▶ [1] Push member var onto stack` next to the triggering row; cheapest, use first.
- `[N]` or `(*)` markers on the row + a footnote block below the figure, one paragraph per marker — when the explanation runs past one line (see the sequence diagram variants).
- Down-leader — drop a `│` from a row's exit into a small captioned box under the main figure; good for timing budgets or CVar tunings that would crowd the figure.

Figure hygiene: use `▶ ◄` for arrows (never `►`); inside box-drawn figures stick to ASCII punctuation — em-dashes, ellipses, and emoji have font-dependent widths and will drift the `│` walls.
