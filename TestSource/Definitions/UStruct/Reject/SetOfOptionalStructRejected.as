/**
 * TSet of TOptional USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.SetOfOptionalStructRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.SetOfOptionalStructRejected
 * @Kind CompileReject
 * @Covers UStruct.SetOfOptionalStructRejected
 * @Inputs TSet<TOptional<FOptionalSetElementStruct>> Values
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TSet<TOptional<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FOptionalSetElementStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructSetOfOptionalActor : AActor
{
	UPROPERTY()
	TSet<TOptional<FOptionalSetElementStruct>> Values;
}
