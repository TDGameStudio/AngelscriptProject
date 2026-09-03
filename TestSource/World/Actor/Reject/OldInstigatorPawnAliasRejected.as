/**
 * The old GetActorInstigator alias is no longer bound, so this program is rejected.
 * C++ compiles it as the module TestActorOldInstigatorPawnAliasRejected and expects
 * the diagnostic to name GetActorInstigator. Its companion isolates the controller
 * alias.
 *
 * @Theme World.Actor
 * @Subject Actor.OldInstigatorPawnAliasRejected
 * @Harness CompileReject
 * @Tag World.Actor.OldInstigatorPawnAliasRejected
 * @Provenance Theme: World.Actor. Isolated compile-fail: old GetActorInstigator alias is rejected.
 * @Provenance C++: AngelscriptActorPropertyInterfaceTests.cpp::OldInstigatorAliasNamesAreRejected
 * @Provenance Expected diagnostic: No matching signatures to '...::GetActorInstigator()'.
 * @Provenance DiagnosticOnly. Do not add extra declarations that would compile this away.
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
