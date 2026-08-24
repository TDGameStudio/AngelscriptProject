// Theme: World.Actor. Isolated compile-fail: old GetActorInstigatorController alias is rejected.
// C++: AngelscriptActorPropertyInterfaceTests.cpp::OldInstigatorAliasNamesAreRejected
// Expected diagnostic: No matching signatures to '...::GetActorInstigatorController()'.
// DiagnosticOnly. Do not add extra declarations that would compile this away.

UCLASS()
class ATestActorOldInstigatorControllerAliasRejected : AActor
{
	UFUNCTION()
	bool CheckOldControllerAlias()
	{
		return GetActorInstigatorController() == nullptr;
	}
}
