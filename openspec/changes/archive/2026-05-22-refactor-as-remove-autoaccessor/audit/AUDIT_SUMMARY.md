# Auto Property Accessor System - Audit Summary
**Read-Only Analysis for Removal Preparation**

## Quick Reference: 7 Key Findings

| Item | Location | Current Value | Impact |
|------|----------|---------------|--------|
| Mode Setting | `AngelscriptEngine.h:24` | `3` (strict) | HIGH - controls global behavior |
| Implicit Promotion | `AngelscriptSettings.h:56` | `true` (enabled) | MEDIUM - affects all C++ bindings |
| Prefix Config | `as_config.h:1267-1268` | `"Get"/"Set"` | MEDIUM - UE convention divergence |
| Generated Accessors | `Bind_BlueprintType.cpp:1184-1303` | ~120 lines | HIGH - entire generation system |
| Compiler Lookups | `as_compiler.cpp:13989+` | Main implementation | LOW - becomes dead code |
| User Scripts | `Script/Examples/Example_Overlaps.as` | 4 `.Name` accesses | MEDIUM - will break |
| Documentation | `Syntax_PropertyAccessor.md` | 1280 lines | LOW - historical archive |

---

## The 4 Entry Paths (Will All Stop Working)

### Path 1: AS Decorator
```angelscript
void GetX() property { ... }  // Manually marked in AS
```
**Status**: Stops working (mode enforcement breaks this)

### Path 2: Virtual Property Blocks
```angelscript
int X { get const { ... } set { ... } }
```
**Status**: Compiles but `obj.X` syntax fails (methods GetX/SetX still exist)

### Path 3: C++ Implicit Promotion
```cpp
FAngelscriptBinds::Method("FString GetName() const", ...);
```
**Status**: Method works but `obj.Name` syntax fails (called via `obj.GetName()` only)

### Path 4: Global Function Decorator
```angelscript
FString GetGreeting() property { ... }
```
**Status**: Stops working (mode enforcement breaks this)

---

## Critical Impact Zones

### Zone 1: BindProperties() Auto-Generation (~120 lines)
**File**: `Bind_BlueprintType.cpp:1184-1303`

This is where the magic happens:
- Lines 1184-1185: Decide to generate getter/setter
- Lines 1208-1241: Generate `GetX()` methods + mark `asTRAIT_GENERATED_FUNCTION`
- Lines 1246-1303: Generate `SetX()` methods + mark trait

**Removal**: Delete entire block. Properties will no longer auto-generate.

### Zone 2: OnBind Hook (4 lines)
**File**: `AngelscriptBinds.cpp:547-550`

```cpp
if (Manager.ConfigSettings->bAllowImplicitPropertyAccessors)
{
    ScriptFunction->SetProperty(true);  // <-- REMOVE THIS
}
```

**Removal**: Delete condition. C++ methods no longer auto-elevated to properties.

### Zone 3: FindPropertyAccessor (Becomes Unreachable)
**File**: `as_compiler.cpp:13989-14430` (~450 lines)

First check: `if(engine->ep.propertyAccessorMode == 0) return 0;`

**Removal**: Not deleted (dead code), but never executed if mode = 0.

---

## Exact User Code Breakage

**File**: `Script/Examples/Core/Example_Overlaps.as`

```angelscript
// Line 11 - WILL BREAK
Print("Overlapping with: "+OtherActor.Name);
  // Expects: implicit getter obj.Name → obj.GetName()
  // After removal: compilation error

// MUST REWRITE TO:
Print("Overlapping with: "+OtherActor.GetName());
```

**Total Instances Found**: 4 in example scripts
**Actual Production Impact**: Unknown (audit was read-only, no grep of all scripts)

---

## Virtual Property Syntax Reality Check

**Question**: Does `int X { get; set; }` still work after removal?

**Answer**: Syntax compiles; functionality breaks

```angelscript
class Foo {
    int _value;
    
    // This STILL COMPILES after removal
    int Value {
        get const { return _value; }
        set { _value = value; }
    }
}

// AFTER REMOVAL:
foo.Value;       // ✗ COMPILE ERROR: no property accessor
foo.Value = 10;  // ✗ COMPILE ERROR: no property accessor

// BUT THESE STILL WORK:
foo.GetValue();          // ✓ Method still exists (generated from virtual property)
foo.SetValue(10);        // ✓ Method still exists (generated from virtual property)

// MIGRATION: Rewrite to explicit methods
int GetValue() const { return _value; }
void SetValue(int value) { _value = value; }
```

**All virtual property blocks need rewriting** to use explicit method syntax.

---

## Mode 3 Enforcement Points

**Current Setting**: `AS_PROPERTY_ACCESSOR_MODE = 3`

This strict mode requires `asTRAIT_PROPERTY` trait for all property methods.

**Enforcement Locations** (all need update):
- `as_compiler.cpp:14021` - Member getter check
- `as_compiler.cpp:14085` - Member setter check
- `as_compiler.cpp:14167` - Another context check
- `as_compiler.cpp:14219` - Another context check

All check: `if (engine->ep.propertyAccessorMode == 3 && !f->IsProperty()) return;`

**After Setting Mode to 0**: These checks become meaningless (mode 0 disables all properties).

---

## Debugger Transparency Benefit

**Current Behavior** (hiding generated accessors):
```cpp
// AngelscriptDebugServer.cpp:1853-1856
if (ScriptFunction->traits.GetTrait(asTRAIT_GENERATED_FUNCTION))
{
    continue;  // SKIP from call stack display
}
```

**After Removal Benefit**:
- Accessor calls become visible in debugger
- Developers see exact GetX/SetX method calls
- Transparency improves (no hidden function calls)

---

## The 5 Must-Do Changes

### 1. Disable Mode (1 line)
```diff
- #define AS_PROPERTY_ACCESSOR_MODE 3
+ #define AS_PROPERTY_ACCESSOR_MODE 0
```
**File**: `AngelscriptEngine.h:24`

### 2. Remove Implicit Promotion (4 lines)
```diff
- if (Manager.ConfigSettings->bAllowImplicitPropertyAccessors)
- {
-     ScriptFunction->SetProperty(true);
- }
```
**File**: `AngelscriptBinds.cpp:547-550`

### 3. Remove Generator Logic (120 lines)
```
Delete: Lines 1184-1303 in Bind_BlueprintType.cpp
Keep: Everything else in BindProperties()
```
**File**: `Bind_BlueprintType.cpp`

### 4. Rewrite Script Examples (4 lines)
```diff
- Print("Overlapping with: "+OtherActor.Name);
+ Print("Overlapping with: "+OtherActor.GetName());
```
**File**: `Script/Examples/Core/Example_Overlaps.as` (4 instances)

### 5. Archive Documentation
```
Archive: Documents/Knowledges/ZH/Syntax_PropertyAccessor.md
Reason: Entire 1280-line file documents system being removed
```

---

## Optional Cleanup (Low Priority)

- Remove `asTRAIT_GENERATED_FUNCTION` checks from debugger (3 locations)
- Mark `ValidatePropertyAccessorFunc` as obsolete (as_builder.cpp:1724)
- Comment `FindPropertyAccessor` as dead code (as_compiler.cpp:13989)

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Existing scripts using `.X` syntax fail compilation | HIGH | Scan all `.as` files; provide migration guide |
| Virtual property blocks need rewriting | HIGH | Document syntax migration pattern |
| BlueprintGetter/BlueprintSetter loses sugar | MEDIUM | No C++ breakage; only AS syntax changes |
| Debugger behavior changes | LOW | Actually improves transparency |
| Mode enforcement scattered across compiler | MEDIUM | Mode 0 makes enforcement unreachable (safe) |

---

## Total Code Changes Estimate

- **Must change**: ~250 lines (mode + OnBind + generated block)
- **Dead code left**: ~1,000 lines (FindPropertyAccessor + related)
- **Script rewrites**: 4 lines in examples
- **Documentation archive**: 1 file (1,280 lines)

**Total removal effort**: 2-3 days (accounting for testing)

---

## Key Insight: No "Soft Deprecation" Possible

The property accessor system is **all-or-nothing**:

- Can't deprecate `obj.X` syntax while keeping infrastructure
- Setting mode = 0 immediately breaks all property access
- No intermediate compatibility level exists

**Recommendation**: Plan full replacement of affected scripts before enabling removal.

