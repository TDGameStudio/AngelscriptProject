// Theme: Definitions.UClass. NegativeDiagnostic: TickComponent + PrimaryComponentTick.bCanEverTick.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::ComponentLifecycle CompileAndExpectFailure.
// Expected diagnostic: Identifier 'ELevelTick' is not a data type;
// 'bCanEverTick' is not a member of 'FActorComponentTickFunction'.
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ULifecycleComponentUnsupportedTickSurface : UActorComponent
{
	default PrimaryComponentTick.bCanEverTick = true;

	UFUNCTION(BlueprintOverride)
	void TickComponent(float DeltaSeconds, ELevelTick TickType, FActorComponentTickFunction& ThisTickFunction)
	{
	}
}
