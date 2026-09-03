/**
 * TOptional of a TSet of USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.OptionalSetOfStructRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.OptionalSetOfStructRejected
 * @Kind CompileReject
 * @Covers UStruct.OptionalSetOfStructRejected
 * @Inputs TOptional<TSet<FOptionalSetPayloadStruct>> Values
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<TSet<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FOptionalSetPayloadStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalSetActor : AActor
{
	UPROPERTY()
	TOptional<TSet<FOptionalSetPayloadStruct>> Values;
}
