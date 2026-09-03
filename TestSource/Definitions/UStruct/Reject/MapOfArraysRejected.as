/**
 * TMap of TArray of USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.MapOfArraysRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.MapOfArraysRejected
 * @Kind CompileReject
 * @Covers UStruct.MapOfArraysRejected
 * @Inputs TMap<int, TArray<FNestedMapStruct>> Groups
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TMap<int,TArray<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FNestedMapStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapOfArraysActor : AActor
{
	UPROPERTY()
	TMap<int, TArray<FNestedMapStruct>> Groups;
}
