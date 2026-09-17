/**
 * @version v1
 * @summary Deprecations host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Deprecations
 *
 * expected-observations
 */
/**
 * @begin expected-observations
 * @summary Expected observations: The
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Expected observations: The
 * @covers Deprecations.expected-observations
 * @inputs Deprecations values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: The

 replacement SetVariable(FName, float) is the
// supported call. Legacy SetNiagaraVariableFloat remains callable for this
// wave so the deprecation metadata can be observed later by a compiler
// diagnostic driver. After both calls the component remains a named live handle.
// Boundary/ownership: Deprecations add metadata only; they do not register a
// new callable. The component still owns the Niagara variable storage.
// SetupOwner=Runner. Null Component throws.
// Legacy SetNiagaraVariableFloat and current SetVariable(FName, float).
// Inputs: runner-owned UNiagaraComponent, "DeprecatedFloat", n"ReplacementFloat", 1.0.
// Oracle: both calls complete and the component name stays non-empty.
// Ownership: component owns Niagara variable storage; null Component throws.
bool ObserveSurface001Nominal(UNiagaraComponent Component)
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
/** @end */
