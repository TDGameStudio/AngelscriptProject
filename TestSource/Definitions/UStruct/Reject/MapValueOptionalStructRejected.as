/**
 * TMap with a TOptional USTRUCT value is a nested container, so this program
 * is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.MapValueOptionalStructRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.MapValueOptionalStructRejected
 * @Kind CompileReject
 * @Covers UStruct.MapValueOptionalStructRejected
 * @Inputs TMap<int, TOptional<FOptionalMapValueStruct>> Values
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TMap<int,TOptional<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FOptionalMapValueStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapValueOptionalActor : AActor
{
	UPROPERTY()
	TMap<int, TOptional<FOptionalMapValueStruct>> Values;
}
