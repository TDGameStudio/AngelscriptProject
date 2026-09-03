/**
 * TMap of TSet of USTRUCT is a nested container, so this program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.MapOfSetsRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.MapOfSetsRejected
 * @Kind CompileReject
 * @Covers UStruct.MapOfSetsRejected
 * @Inputs TMap<int, TSet<FNestedMapSetStruct>> Groups
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TMap<int,TSet<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FNestedMapSetStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapOfSetsActor : AActor
{
	UPROPERTY()
	TMap<int, TSet<FNestedMapSetStruct>> Groups;
}
