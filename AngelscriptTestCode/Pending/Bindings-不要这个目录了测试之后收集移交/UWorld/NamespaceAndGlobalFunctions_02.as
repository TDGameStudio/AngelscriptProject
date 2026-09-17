/**
 * @version v1
 * @summary Observe remaining ENetMode enumerators including the exclusive upper bound.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining ENetMode enumerators including the exclusive upper bound.
 * @topic Baseline
 */
// ENetMode::NM_MAX;
// Inputs: Each enumerator and comparison against NM_Client.
// Expected observations: NM_ListenServer, NM_Standalone, and NM_MAX are each
// distinct from NM_Client and from each other.
// Boundary/ownership: NM_MAX is a bound marker, not a runnable net mode.

namespace TS_UWorld_NamespaceAndGlobalFunctions_02
{
	// ENetMode::NM_ListenServer equals NM_ListenServer and differs from NM_Client.
	bool Observe_Surface013_Nominal()
	{
		ENetMode Value = ENetMode::NM_ListenServer;
		return Value == ENetMode::NM_ListenServer && Value != ENetMode::NM_Client;
	}

	// ENetMode::NM_Standalone equals NM_Standalone and differs from NM_ListenServer.
	bool Observe_Surface014_Nominal()
	{
		ENetMode Value = ENetMode::NM_Standalone;
		return Value == ENetMode::NM_Standalone && Value != ENetMode::NM_ListenServer;
	}

	// ENetMode::NM_MAX equals NM_MAX and differs from NM_Standalone.
	bool Observe_Surface015_Nominal()
	{
		ENetMode Value = ENetMode::NM_MAX;
		return Value == ENetMode::NM_MAX && Value != ENetMode::NM_Standalone;
	}
}
/** @end */
