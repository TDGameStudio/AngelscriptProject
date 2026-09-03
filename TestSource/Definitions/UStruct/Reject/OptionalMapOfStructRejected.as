/**
 * TOptional of a TMap of USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.OptionalMapOfStructRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.OptionalMapOfStructRejected
 * @Kind CompileReject
 * @Covers UStruct.OptionalMapOfStructRejected
 * @Inputs TOptional<TMap<int, FOptionalMapPayloadStruct>> Values
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<TMap<int,FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FOptionalMapPayloadStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalMapActor : AActor
{
	UPROPERTY()
	TOptional<TMap<int, FOptionalMapPayloadStruct>> Values;
}
