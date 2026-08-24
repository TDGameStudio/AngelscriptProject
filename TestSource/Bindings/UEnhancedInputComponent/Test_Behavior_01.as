// Purpose: Observe whether enhanced-input delegates may fire in editor worlds.
// Runner owns the Component fixture. Null Component is setup failure.
// AS-facing API: bool UEnhancedInputComponent.ShouldFireDelegatesInEditor() const;
// Inputs: Runner-owned UEnhancedInputComponent as the default flag, the same
// component after SetShouldFireDelegatesInEditor(true), and after restoration
// to false.
// Expected observations: After enabling, the query is true. After disabling,
// the query is false. The original flag is restored.
// Boundary/ownership: The flag lives on the component. The query does not
// mutate bindings. SetupOwner=Runner. CleanupOwner=Runner.

UCLASS()
class UTSEnhancedInputEditorHost : UObject
{
}

namespace TS_UEnhancedInputComponent_Behavior_01
{
	bool Observe_ShouldFireDelegatesInEditor_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_Behavior_01 setup: required Component is null");
		}
		bool bDefault = Component.ShouldFireDelegatesInEditor();
		Component.SetShouldFireDelegatesInEditor(true);
		bool bEnabled = Component.ShouldFireDelegatesInEditor();
		Component.SetShouldFireDelegatesInEditor(false);
		bool bDisabled = Component.ShouldFireDelegatesInEditor();
		Component.SetShouldFireDelegatesInEditor(bDefault);
		return bEnabled && !bDisabled;
	}
}
