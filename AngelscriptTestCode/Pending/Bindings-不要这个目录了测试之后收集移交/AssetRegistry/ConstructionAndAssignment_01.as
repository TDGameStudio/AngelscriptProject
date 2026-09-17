/**
 * @version v1
 * @summary Observe FTopLevelAssetPath string assignment and formatter interpolation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTopLevelAssetPath string assignment and formatter interpolation.
 * @topic Baseline
 */
// "/Script/Engine.Actor", a copy of that string assigned again, and empty
// string assignment as restoration.
// Expected observations: Assigning the actor path makes IsValid true and
// f"{Path}" non-empty. Reassignment of the same string keeps identity.
// Assigning "" clears the path so IsNull is true.
// Boundary/ownership: Assignment parses a copied string; the source FString
// is not retained. f"{Path}" returns a new FString.

namespace TS_AssetRegistry_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FTopLevelAssetPath Path;
		bool bDefaultIsNull = Path.IsNull();
		FString ActorPath = "/Script/Engine.Actor";
		Path = ActorPath;
		FString Formatted = f"{Path}";
		bool bAssignedIsValid = Path.IsValid();
		bool bFormatterNonEmpty = Formatted.Len() > 0;

		FTopLevelAssetPath Copy;
		Copy = ActorPath;
		bool bCopyMatches = Copy == Path;
		ActorPath = "/Script/Engine.Pawn";
		bool bAssignmentCopiedString = Path.IsValid() && Copy.IsValid();

		FString EmptyPath = "";
		Path = EmptyPath;
		FString EmptyFormatted = f"{Path}";
		bool bEmptyAssignmentClears = Path.IsNull();
		bool bEmptyFormatterConsumed = EmptyFormatted.IsEmpty() || EmptyFormatted != Formatted;

		return bDefaultIsNull &&
			bAssignedIsValid &&
			bFormatterNonEmpty &&
			bCopyMatches &&
			bAssignmentCopiedString &&
			bEmptyAssignmentClears &&
			bEmptyFormatterConsumed;
	}
}
/** @end */
