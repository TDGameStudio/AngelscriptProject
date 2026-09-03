/**
 * TArray of TOptional USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.ArrayOfOptionalStructRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.ArrayOfOptionalStructRejected
 * @Kind CompileReject
 * @Covers UStruct.ArrayOfOptionalStructRejected
 * @Inputs TArray<TOptional<FOptionalArrayElementStruct>> Values
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TArray<TOptional<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FOptionalArrayElementStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfOptionalActor : AActor
{
	UPROPERTY()
	TArray<TOptional<FOptionalArrayElementStruct>> Values;
}
