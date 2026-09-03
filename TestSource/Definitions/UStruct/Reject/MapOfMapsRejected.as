/**
 * TMap of TMap of USTRUCT is a nested container, so this program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.MapOfMapsRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.MapOfMapsRejected
 * @Kind CompileReject
 * @Covers UStruct.MapOfMapsRejected
 * @Inputs TMap<int, TMap<int, FNestedMapMapStruct>> Groups
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TMap<int,TMap<int,FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FNestedMapMapStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapOfMapsActor : AActor
{
	UPROPERTY()
	TMap<int, TMap<int, FNestedMapMapStruct>> Groups;
}
