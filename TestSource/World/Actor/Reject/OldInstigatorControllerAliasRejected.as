/**
 * The old GetActorInstigatorController alias is no longer bound, so this program is
 * rejected. C++ compiles it as the module
 * TestActorOldInstigatorControllerAliasRejected and expects the diagnostic to name
 * GetActorInstigatorController. Its companion isolates the pawn alias.
 *
 * @Theme World.Actor
 * @Subject Actor.OldInstigatorControllerAliasRejected
 * @Harness CompileReject
 * @Tag World.Actor.OldInstigatorControllerAliasRejected
 * @Provenance Theme: World.Actor. Isolated compile-fail: old GetActorInstigatorController alias is rejected.
 * @Provenance C++: AngelscriptActorPropertyInterfaceTests.cpp::OldInstigatorAliasNamesAreRejected
 * @Provenance Expected diagnostic: No matching signatures to '...::GetActorInstigatorController()'.
 * @Provenance DiagnosticOnly. Do not add extra declarations that would compile this away.
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
