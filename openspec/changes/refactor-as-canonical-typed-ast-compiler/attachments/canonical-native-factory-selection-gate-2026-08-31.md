# Canonical native factory selection gate (2026-08-31)

`FBindHost h(3)` / `FBindHost h;` intern native factories as ConstructorDecls.
Methods/globals publish `canonicalASTStableDeclKey`; behaviours do not.
`h.Stored` is a `MEMBER_REF` of an implicit-handle local, so CodeGen PSF of
the handle slot cannot observe `Stored` even when the selected factory ran.

This advances `5.3`, `5.9`, `9.5`, and `13.2` for native same-arity / zero-arg
factory selection. It does not close those umbrellas or list factories.

### Gate card: sealed factory DeclId is the CALLSYS identity; handle local is a pointer slot

- **OpenSpec task(s):** `5.3`, `5.9`, `9.5`, `13.2` (slice)
- **Source fixture:**
  - `FBindHost h(3); return h.Stored;` with poison `factory(bool)` registered
    first and selected `factory(int)` second.
  - `FBindHost h; return h.Stored + 1;` with poison `factory(int)` first and
    selected `factory()` second.
  Methods `CanonicalNativeSameArityFactoryExecutesSelectedNotFirstRegistered`
  and `CanonicalNativeZeroArgDefaultFactoryExecutesInternedNotFirstRegistered`.
- **Canonical fact:** Sema seals the ranked factory ConstructorDecl; intern
  publishes `canonicalASTStableDeclKey` on that SYSTEM function; CodeGen
  `FindFunc` binds that key (signature walk is fail-closed `matches == 1`
  only); `DECL_REF` of the implicit-handle local is a PshVPtr slot so
  `MEMBER_REF Stored` reads the native object.
- **AST test:** ProductionCodeGen methods above. They retain AST and require
  execute `42` plus CALLSYS of the selected factory id, not the first
  registered poison.
- **AST-red:** focused prefixes `cta-factory-int`
  `20260831_203752_331_f5bc28b1` and `cta-factory-zero`
  `20260831_203821_788_d5ec6830`. Build/publish succeed; execute `got=0`.
- **AST-green:** `cta-factory-int` `20260831_210043_381_94abb12a` **1/1** and
  `cta-factory-zero` `20260831_210112_949_e1e6e7ae` **1/1**. Repair: intern
  publishes `canonicalASTStableDeclKey`; CodeGen prefers that key; handle
  `DECL_REF` is a PshVPtr slot so `Stored` is the native field.
- **CodeGen/provenance:** `as_sema_expr.cpp` `InternNativeBehaviourList`;
  `as_bytecode_codegen.cpp` `FindExactRegisteredConstructor` / `EmitLValueAddress`.
- **Lifecycle:** N/A (no Cache identity change).
- **Focused regression:** VALUE same-arity *constructor* remains a different
  representation (inline PSF). Full ProductionCodeGen **196/196**
  (`cta-ast-first-codegen` `20260831_210231_401_c5b5ef43`). SemaAuthority
  **474/474**. This card does not close 5.3/5.9/9.5/13.2.
- **Remaining boundary:** list-pattern `{41}` Marker, lexical owning-handle
  release, product-default cutover.
