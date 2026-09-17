/**
 * @version v1
 * @summary Observe that native-module function-address payloads replace eligible reflective UFUNCTION bindings without changing the script-facing declaration. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe that native-module function-address payloads replace eligible reflective UFUNCTION bindings without changing the script-facing declaration. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// surface stand-in, plus a null object as the empty state.
// Expected observations: AActor::StaticClass() remains callable and non-null.
// The script declaration is unchanged whether the native-module payload or
// the reflective fallback is selected.
// Boundary/ownership: The registrar declares no fixed script API. The exact
// declaration is supplied by the target module and remains identical to its
// UFUNCTION surface. Native-module transport does not transfer UObject
// ownership.

namespace TS_NativeModuleFunctionBinding_Behavior_01
{
	// AActor::StaticClass stays callable; a null UObject remains the empty state.
	bool Observe_Surface001_Nominal()
	{
		UClass ActorClass = AActor::StaticClass();
		UObject NullObject = nullptr;
		return ActorClass != nullptr && NullObject is null;
	}
}
/** @end */
