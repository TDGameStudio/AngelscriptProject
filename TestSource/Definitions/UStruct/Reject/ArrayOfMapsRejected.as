/**
 * TArray of TMap of USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.ArrayOfMapsRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.ArrayOfMapsRejected
 * @Kind CompileReject
 * @Covers UStruct.ArrayOfMapsRejected
 * @Inputs TArray<TMap<int, FNestedArrayMapStruct>> Maps
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TArray<TMap<int,FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FNestedArrayMapStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfMapsActor : AActor
{
	UPROPERTY()
	TArray<TMap<int, FNestedArrayMapStruct>> Maps;
}
