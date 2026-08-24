// Purpose: Observe FTopLevelAssetPath equality.
// AS-facing API: bool bEqual = Left == Right;
// Inputs: Two paths constructed from "/Script/Engine.Actor", one from
// "/Script/Engine.Pawn", and a default-empty path as the zero operand.
// Expected observations: Identical actor paths compare true. Actor vs pawn
// is false. Empty vs actor is false. Empty vs empty is true.
// Boundary/ownership: Comparison uses path identity, not formatter text.
// The operator is value-returning and does not mutate either operand.

namespace TS_AssetRegistry_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FTopLevelAssetPath Left("/Script/Engine.Actor");
		FTopLevelAssetPath RightSame("/Script/Engine.Actor");
		FTopLevelAssetPath RightDifferent("/Script/Engine.Pawn");
		FTopLevelAssetPath Empty;
		FTopLevelAssetPath AnotherEmpty;

		return (Left == RightSame) &&
			!(Left == RightDifferent) &&
			!(Left == Empty) &&
			(Empty == AnotherEmpty);
	}
}
