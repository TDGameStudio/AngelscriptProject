/**
 * @version v1
 * @summary Observe the legacy Niagara typed-name setters that the deprecation contribution marks, and contrast them with the current SetVariable(FName) replacements.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe the legacy Niagara typed-name setters that the deprecation contribution marks, and contrast them with the current SetVariable(FName) replacements.
 * @topic Baseline
 */
// SetNiagaraVariableLinearColor, SetNiagaraVariableVec4, SetNiagaraVariableQuat,
// SetNiagaraVariableMatrix, SetNiagaraVariableVec3, SetNiagaraVariablePosition,
// SetNiagaraVariableVec2, SetNiagaraVariableFloat, SetNiagaraVariableInt,
// SetNiagaraVariableBool, SetNiagaraVariableActor, SetNiagaraVariableObject.
// Inputs: Runner-owned UNiagaraComponent, the legacy typed-name
// "DeprecatedFloat", FName n"ReplacementFloat", and float 1.0 as the value.
// Expected observations: The replacement SetVariable(FName, float) is the
// supported call. Legacy SetNiagaraVariableFloat remains callable for this
// wave so the deprecation metadata can be observed later by a compiler
// diagnostic driver. After both calls the component remains a named live handle.
// Boundary/ownership: Deprecations add metadata only; they do not register a
// new callable. The component still owns the Niagara variable storage.
// SetupOwner=Runner. Null Component throws.

namespace TS_Deprecations_Behavior_01
{
	// Legacy SetNiagaraVariableFloat and current SetVariable(FName, float).
	// Inputs: runner-owned UNiagaraComponent, "DeprecatedFloat", n"ReplacementFloat", 1.0.
	// Oracle: both calls complete and the component name stays non-empty.
	// Ownership: component owns Niagara variable storage; null Component throws.
	bool Observe_Surface001_Nominal(UNiagaraComponent Component)
	{
		if (Component is null)
		{
			throw("TS_Deprecations_Behavior_01 setup: required Component is null");
		}
		FName ReplacementName = n"ReplacementFloat";
		float32 ReplacementValue = 1.0;
		Component.SetNiagaraVariableFloat("DeprecatedFloat", ReplacementValue);
		Component.SetVariable(ReplacementName, ReplacementValue);
		return Component.GetName().Len() > 0 && ReplacementValue == 1.0;
	}
}
/** @end */
