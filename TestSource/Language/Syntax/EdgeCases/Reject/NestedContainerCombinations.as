/**
 * Nesting one container type inside another, here a TMap inside a TArray, is
 * rejected. This file is the illegal program itself; do not unwrap the map into
 * a flat structure, since the nesting is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.NestedContainerCombinations
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.NestedContainerCombinations
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a TArray whose element type is TMap
 * @Return does not compile; diagnostic "Containers cannot be nested in other containers"
 * @Provenance C++: AngelscriptCoverageContainerAdvancedTests.cpp::NestedContainerCombinationsUnsupported
 * @Provenance sha256=81c9921fca1f6b16b34a37ae4bdaa8f371c55208c4867f79299a1ad0d8f60dac; lines 408-415.
 * @Provenance Expected diagnostic: Containers cannot be nested in other containers.
 * @Provenance Isolate this failing UCLASS. DiagnosticOnly.
 */

/**
 * The actor whose property nests a map inside an array.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
UCLASS()
class ACoverageContainerArrayOfMapsActor : AActor
{
	/**
	 * The nested container property whose declaration is illegal.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UPROPERTY()
	TArray<TMap<int, FString>> ArrayOfMaps;
}
