/**
 * TArray of TArray of USTRUCT is a nested container, so this program is
 * rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.ArrayOfArraysRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.ArrayOfArraysRejected
 * @Kind CompileReject
 * @Covers UStruct.ArrayOfArraysRejected
 * @Inputs TArray<TArray<FNestedContainerStruct>> Matrix
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TArray<TArray<FStruct>> nested containers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FNestedContainerStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfArraysActor : AActor
{
	UPROPERTY()
	TArray<TArray<FNestedContainerStruct>> Matrix;
}
