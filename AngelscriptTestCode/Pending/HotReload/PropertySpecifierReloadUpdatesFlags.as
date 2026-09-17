/**
 * @version v1
 * @summary HotReload VersionPair Before. Specifier NotEditable -> EditAnywhere.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Specifier NotEditable -> EditAnywhere.
 * @topic Baseline
 */
// Retained on old class: Value storage; CPF_Edit unset (NotEditable).
// Replaced in After: UPROPERTY EditAnywhere; Value default 1 -> 2.
// Oracle Before: CPF_Edit false.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadSpecifierTarget : UObject
{
	UPROPERTY(NotEditable)
	int Value;

	default Value = 1;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Specifier NotEditable -> EditAnywhere.
 * @topic HotReload
 */
// Oracle After: FullReload handled; replacement flags include CPF_Edit.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UFullReloadSpecifierTarget : UObject
{
	UPROPERTY(EditAnywhere)
	int Value;

	default Value = 2;
}
/** @end */
