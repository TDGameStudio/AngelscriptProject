/**
 * TArray of TSet of USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.ArrayOfSetsRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.ArrayOfSetsRejected
 * @Kind CompileReject
 * @Covers UStruct.ArrayOfSetsRejected
 * @Inputs TArray<TSet<FNestedSetStruct>> Sets
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TArray<TSet<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FNestedSetStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfSetsActor : AActor
{
	UPROPERTY()
	TArray<TSet<FNestedSetStruct>> Sets;
}
