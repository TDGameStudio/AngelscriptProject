// Theme: World.Actor. Isolated compile-fail: old GetActorInstigator alias is rejected.
// C++: AngelscriptActorPropertyInterfaceTests.cpp::OldInstigatorAliasNamesAreRejected
// Expected diagnostic: No matching signatures to '...::GetActorInstigator()'.
// DiagnosticOnly. Do not add extra declarations that would compile this away.

UCLASS()
class ATestActorOldInstigatorPawnAliasRejected : AActor
{
	UFUNCTION()
	bool CheckOldPawnAlias()
	{
		return GetActorInstigator() == nullptr;
	}
}
