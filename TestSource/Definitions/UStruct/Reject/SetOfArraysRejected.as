/**
 * TSet of TArray of USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.SetOfArraysRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.SetOfArraysRejected
 * @Kind CompileReject
 * @Covers UStruct.SetOfArraysRejected
 * @Inputs TSet<TArray<FNestedSetArrayStruct>> Groups
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TSet<TArray<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FNestedSetArrayStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructSetOfArraysActor : AActor
{
	UPROPERTY()
	TSet<TArray<FNestedSetArrayStruct>> Groups;
}
