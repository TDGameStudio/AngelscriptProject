/**
 * @version v1
 * @summary Observe EWorldType and ENetMode declaration, copy, and assignment independence.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe EWorldType and ENetMode declaration, copy, and assignment independence.
 * @topic Baseline
 */
// ENetMode::NM_Client, plus copies of each.
// Expected observations: Copied enumerators compare equal to the source.
// Assigning Editor over Game leaves the original Game value unchanged.
// NM_Standalone differs from NM_Client after assignment.
// Boundary/ownership: The enums classify a world; they do not own one.

namespace TS_UWorld_ConstructionAndAssignment_01
{
	// EWorldType copy equals the source; assigning Editor leaves the original Game value unchanged.
	bool Observe_Surface001_Nominal()
	{
		EWorldType Game = EWorldType::Game;
		EWorldType Copied = Game;
		Copied = EWorldType::Editor;
		return Copied == EWorldType::Editor && Game == EWorldType::Game && Game != EWorldType::None;
	}

	// ENetMode copy equals the source; assigning NM_Client leaves NM_Standalone unchanged.
	bool Observe_Surface010_Nominal()
	{
		ENetMode Standalone = ENetMode::NM_Standalone;
		ENetMode Copied = Standalone;
		Copied = ENetMode::NM_Client;
		return Copied == ENetMode::NM_Client && Standalone == ENetMode::NM_Standalone && Standalone != ENetMode::NM_MAX;
	}
}
/** @end */
