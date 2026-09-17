/**
 * @version v1
 * @summary The old GetActorInstigatorController alias is no longer bound, so this program is rejected. C++ compiles it as the module TestActorOldInstigatorControllerAliasRejected and expects the diagnostic to name.
 * @topic World
 */
/**
 * @version root
 * @summary The old GetActorInstigatorController alias is no longer bound, so this program is rejected. C++ compiles it as the module TestActorOldInstigatorControllerAliasRejected and expects the diagnostic to name.
 * @topic Negative
 */
UCLASS()
class ATestActorOldInstigatorControllerAliasRejected : AActor
{
	/**
	 * The isolated failing program: the GetActorInstigatorController alias has no
	 * matching signature.
	 *
	 * @Kind CompileReject
	 * @Covers Actor.OldInstigatorControllerAliasRejected
	 * @Inputs none
	 * @Return does not compile; "No matching signatures to 'ATestActorOldInstigatorControllerAliasRejected::GetActorInstigatorController()'"
	 */
	UFUNCTION()
	bool CheckOldControllerAlias()
	{
		return GetActorInstigatorController() == nullptr;
	}
}
/** @end */
