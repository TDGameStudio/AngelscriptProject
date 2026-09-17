/**
 * @version v1
 * @summary The old GetActorInstigator alias is no longer bound, so this program is rejected. C++ compiles it as the module TestActorOldInstigatorPawnAliasRejected and expects the diagnostic to name GetActorInstigator. Its companion.
 * @topic World
 */
/**
 * @version root
 * @summary The old GetActorInstigator alias is no longer bound, so this program is rejected. C++ compiles it as the module TestActorOldInstigatorPawnAliasRejected and expects the diagnostic to name GetActorInstigator. Its companion.
 * @topic Negative
 */
UCLASS()
class ATestActorOldInstigatorPawnAliasRejected : AActor
{
	/**
	 * The isolated failing program: the GetActorInstigator alias has no matching
	 * signature.
	 *
	 * @Kind CompileReject
	 * @Covers Actor.OldInstigatorPawnAliasRejected
	 * @Inputs none
	 * @Return does not compile; "No matching signatures to 'ATestActorOldInstigatorPawnAliasRejected::GetActorInstigator()'"
	 */
	UFUNCTION()
	bool CheckOldPawnAlias()
	{
		return GetActorInstigator() == nullptr;
	}
}
/** @end */
