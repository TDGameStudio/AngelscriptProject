/**
 * @version v1
 * @summary Observe EStringTableLoadingPolicy as the string-table lookup loading policy enum, including copy assignment.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe EStringTableLoadingPolicy as the string-table lookup loading policy enum, including copy assignment.
 * @topic Baseline
 */
// FindOrLoad.
// Expected observations: Copied Find equals the source. Assigned FindOrLoad
// differs from Find. FindOrFullyLoad is a distinct third enumerator.
// Boundary/ownership: The enum only selects lookup behavior. It does not own
// a string-table asset.

namespace TS_FStringTableRegistry_ConstructionAndAssignment_01
{
	// EStringTableLoadingPolicy copy and assignment. Inputs Find, then assign
	// FindOrLoad, plus FindOrFullyLoad. Copied Find stays Find; assigned value
	// is FindOrLoad; Fully is distinct. Enum value type; no table ownership.
	bool Observe_Surface001_Nominal()
	{
		EStringTableLoadingPolicy Policy = EStringTableLoadingPolicy::Find;
		EStringTableLoadingPolicy Copied = Policy;
		Copied = EStringTableLoadingPolicy::FindOrLoad;
		EStringTableLoadingPolicy Fully = EStringTableLoadingPolicy::FindOrFullyLoad;
		return Policy == EStringTableLoadingPolicy::Find && Copied == EStringTableLoadingPolicy::FindOrLoad && Fully != Policy && Fully != Copied;
	}
}
/** @end */
