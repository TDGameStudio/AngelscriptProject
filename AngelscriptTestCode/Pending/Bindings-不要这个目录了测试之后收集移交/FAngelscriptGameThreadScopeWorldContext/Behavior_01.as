/**
 * @version v1
 * @summary Observe FAngelscriptGameThreadScopeWorldContext construction that pushes WorldContext for the scope lifetime and restores it on destruction.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FAngelscriptGameThreadScopeWorldContext construction that pushes WorldContext for the scope lifetime and restores it on destruction.
 * @topic Baseline
 */
// Runner owns WorldContext. The bool return is the restoration oracle.
// AS-facing API: FAngelscriptGameThreadScopeWorldContext Scope(UObject WorldContext);
// Inputs: Null WorldContext, GetTransientPackage() as an empty UObject
// context, and a runner-owned UObject as a nominal world-context object.
// Expected observations: Each constructor returns a named NoDiscard scope.
// GetWorldSubsystem after the scopes matches the value captured before them.
// Boundary/ownership: The scope borrows WorldContext to resolve the active
// world. It does not take ownership of the object. The constructor is
// NoDiscard; the value must be stored for the intended lifetime.
// SetupOwner=Runner. CleanupOwner=Runner.

namespace TS_FAngelscriptGameThreadScopeWorldContext_Behavior_01
{
	bool Observe_Scope_Nominal(UObject WorldContext)
	{
		if (WorldContext is null)
		{
			throw("TS_FAngelscriptGameThreadScopeWorldContext_Behavior_01 setup: required WorldContext is null");
		}

		UClass WorldSubsystemClass = UNetworkSubsystem::StaticClass();
		UObject Before = USubsystemLibrary::GetWorldSubsystem(WorldSubsystemClass);

		{
			FAngelscriptGameThreadScopeWorldContext NullScope(nullptr);
		}

		UObject PackageContext = GetTransientPackage();
		if (PackageContext is null)
		{
			throw("TS_FAngelscriptGameThreadScopeWorldContext_Behavior_01 setup: required PackageContext is null");
		}
		{
			FAngelscriptGameThreadScopeWorldContext PackageScope(PackageContext);
		}

		{
			FAngelscriptGameThreadScopeWorldContext ActorScope(WorldContext);
			USubsystemLibrary::GetWorldSubsystem(WorldSubsystemClass);
		}
		UObject After = USubsystemLibrary::GetWorldSubsystem(WorldSubsystemClass);
		return After == Before;
	}
}
/** @end */
