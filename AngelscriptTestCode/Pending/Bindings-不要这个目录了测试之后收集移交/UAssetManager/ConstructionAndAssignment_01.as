/**
 * @version v1
 * @summary Observe formatter contributions for FPrimaryAssetType and FPrimaryAssetId.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe formatter contributions for FPrimaryAssetType and FPrimaryAssetId.
 * @topic Baseline
 */
// default-empty type/id, and a copy assigned from the nominal values.
// Expected observations: Nominal Type formats to a non-empty string containing
// Weapon. Nominal Id formats as Type:Name text containing Weapon and Sword.
// Empty values still produce a consumed FString distinct from the nominal
// text. Copy assignment keeps the formatted identity independent of later
// mutation of the source.
// Boundary/ownership: Formatters copy name text into a new FString. They do
// not retain the identifier.

namespace TS_UAssetManager_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FPrimaryAssetType Type(n"Weapon");
		FString TypeText = f"{Type}";
		FPrimaryAssetType CopiedType = Type;
		FString CopiedTypeText = f"{CopiedType}";
		FPrimaryAssetType EmptyType;
		FString EmptyTypeText = f"{EmptyType}";

		FPrimaryAssetId Id("Weapon:Sword");
		FString IdText = f"{Id}";
		FPrimaryAssetId CopiedId = Id;
		FString CopiedIdText = f"{CopiedId}";
		FPrimaryAssetId EmptyId;
		FString EmptyIdText = f"{EmptyId}";

		Type = FPrimaryAssetType(n"Armor");
		Id = FPrimaryAssetId("Armor:Shield");
		return TypeText.Len() > 0 &&
			TypeText.Contains("Weapon") &&
			CopiedTypeText.Contains("Weapon") &&
			CopiedType.GetName() == n"Weapon" &&
			IdText.Len() > 0 &&
			IdText.Contains("Weapon") &&
			IdText.Contains("Sword") &&
			CopiedIdText.Contains("Sword") &&
			CopiedId.IsValid() &&
			EmptyTypeText != TypeText &&
			EmptyIdText != IdText;
	}
}
/** @end */
