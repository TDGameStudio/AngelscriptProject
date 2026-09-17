/**
 * @version v1
 * @summary Observe equality of FPrimaryAssetType and FPrimaryAssetId.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe equality of FPrimaryAssetType and FPrimaryAssetId.
 * @topic Baseline
 */
// bool bEqual = LeftId == RightId;
// Inputs: Matching n"Weapon" types, a different n"Armor" type, matching
// "Weapon:Sword" ids, a different "Weapon:Axe" id, and default-empty
// operands.
// Expected observations: Same type/id compares true. Different name or empty
// vs nominal compares false. Two empty values compare true.
// Boundary/ownership: Comparison uses interned type and asset names. The
// operators do not mutate either operand.

namespace TS_UAssetManager_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FPrimaryAssetType LeftType(n"Weapon");
		FPrimaryAssetType RightType(n"Weapon");
		FPrimaryAssetType OtherType(n"Armor");
		FPrimaryAssetType EmptyType;
		FPrimaryAssetType AnotherEmptyType;

		FPrimaryAssetId LeftId("Weapon:Sword");
		FPrimaryAssetId RightId("Weapon:Sword");
		FPrimaryAssetId OtherId("Weapon:Axe");
		FPrimaryAssetId EmptyId;
		FPrimaryAssetId AnotherEmptyId;

		return LeftType == RightType &&
			!(LeftType == OtherType) &&
			!(LeftType == EmptyType) &&
			EmptyType == AnotherEmptyType &&
			LeftId == RightId &&
			!(LeftId == OtherId) &&
			!(LeftId == EmptyId) &&
			EmptyId == AnotherEmptyId;
	}
}
/** @end */
