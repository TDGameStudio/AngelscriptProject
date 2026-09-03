/**
 * TMap with a TOptional USTRUCT key is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.MapKeyOptionalStructRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.MapKeyOptionalStructRejected
 * @Kind CompileReject
 * @Covers UStruct.MapKeyOptionalStructRejected
 * @Inputs TMap<TOptional<FOptionalMapKeyStruct>, int> Values
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TMap<TOptional<FStruct>,int> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FOptionalMapKeyStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapKeyOptionalActor : AActor
{
	UPROPERTY()
	TMap<TOptional<FOptionalMapKeyStruct>, int> Values;
}
