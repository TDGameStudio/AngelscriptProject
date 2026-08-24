// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintCallable collides with native AActor method.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case native callable collision.
// Expected diagnostic: "BlueprintCallable method SetActorHiddenInGame in class ACoverageUFunctionNativeCollisionActor already specified in superclass AActor."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionNativeCollisionActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void SetActorHiddenInGame(bool bNewHidden)
	{
	}
}
