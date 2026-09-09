# Task 7.4 Input/UI Verification

## Outcome

Task 7.4 migrates the selected input, enhanced-input, input-event and UUserWidget customization providers into detached records that install in a fresh binding Engine. The final fixture proves six independent behaviors and accounts for exactly 427 selected-provider member contributions, including 63 native recipes.

## Staged setup and RED

- Initial build run `6545c767512d439ca79815ee6e9f176b` failed because the enabled replacement-test module did not expose EnhancedInput, InputCore, Slate, SlateCore or UMG. Applied replan `replan-20260909-082640-input-ui-test-dependencies` corrected task 7.4's Build.cs ownership; build `97d45b28a6714887b12f18a29dc6e7dc` then succeeded.
- Exact run `4dcf240a4ac54037b7f0b023c5901f4c` discovered all six tests but asserted while `FInputActionValue` used the legacy global Engine namespace. Run `3a5e8441cde448ef8a4139c7f43e03d2` found the next Engine-only generated override. These crashes are retained as setup failures, not behavioral RED.
- Exact run `7e835f1e89284d118d2d98a0733f72ac` executed all six cases and failed them during frozen-image creation because the UUserWidget namespace scope qualified later Slate types incorrectly.
- Exact run `9526b12ae76346538c6258e2d6d705e1` failed five creation cases on the previously undeclared enhanced-input delegate wrappers; the Engine-free accounting case independently reached its provisional threshold assertion. After declaring those wrappers, run `60febd9d6cfe41c9b73a306cc86eb896` passed four controls and isolated two fixture defects: abstract UUserWidget construction and an incorrect guessed recipe threshold. Run `84407f79aab9425daa3d392f25841f7e` proved five behaviors and measured the stable 427-contribution/63-recipe surface before the exact inventory assertion replaced the guess.

## Implementation

- Replacement tests now declare the existing EnhancedInput, InputCore, Slate, SlateCore and UMG dependencies.
- Recording-safe namespace scopes replace global target-Engine scopes in the selected providers; the WidgetBlueprint namespace ends before FSlateColor and FSlateBrush customization.
- `FInputBindingHandle.Types` declares both enhanced-input dynamic delegate wrapper types so every UEnhancedInputComponent signature resolves before image freeze.
- The legacy `UPlayerInput` function-map override is skipped during detached recording because loaded reflection recording owns those generated/reflective callables; direct Engine registration retains its legacy behavior.
- The non-rendering widget case uses the abstract class default object with a scoped, restored transient WidgetTree, avoiding construction of an abstract UUserWidget instance and leaving global state unchanged.

## Exact GREEN

Command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.InputUI.'; Fast = $true; TimeoutMs = 600000 }
```

Harness run `9af2612b05a84920a866133180ac53cc` passed 6/6 with zero warnings and zero errors:

- `ActionMappingCopyPreservesKeyAndModifiers`
- `AxisTwoValuePreservesComponentsAndType`
- `BindingResourcesReleaseWithOwnerAndProvidersAreAccounted`
- `InputChordConstructorPreservesModifierFlags`
- `RemoveBindingByHandleAffectsExactlyOneBinding`
- `TransientWidgetRootLookupPreservesVisibility`

The exact run used source SHA-256 `e621cab803dfa690d8095119a18649f7b90fc2305e99b71f43bb7aa858530101` and `UnrealEditor-AngelscriptTest.dll` SHA-256 `b6e866eb46efa00a4333a23f9c037145a63b1152e397f2b934353d29a1a77fe3`.

## Shared regression proof

The impact-expanded command selected `Angelscript.UnitTest.RuntimeBindings.`. Harness run `58933bdd4c0b4faab69eadda7f673257` passed 272/272 with zero warnings, errors, skips or incomplete tests. No broader Unreal suite was run because the changes are bounded to runtime-binding recording and installation providers, and this selection includes every affected shared contract.
