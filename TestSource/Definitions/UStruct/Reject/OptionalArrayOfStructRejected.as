/**
 * TOptional of a TArray of USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.OptionalArrayOfStructRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.OptionalArrayOfStructRejected
 * @Kind CompileReject
 * @Covers UStruct.OptionalArrayOfStructRejected
 * @Inputs TOptional<TArray<FOptionalArrayPayloadStruct>> Values
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<TArray<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FOptionalArrayPayloadStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalArrayActor : AActor
{
	UPROPERTY()
	TOptional<TArray<FOptionalArrayPayloadStruct>> Values;
}
