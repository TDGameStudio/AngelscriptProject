/**
 * Nesting a TArray inside another TArray is rejected: containers cannot be
 * nested in other containers. This file is the illegal program itself; do not
 * change the element type, since the nesting is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatNestedContainerBoundary
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.FloatNestedContainerBoundary
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a TArray of TArray
 * @Return does not compile; diagnostic "Containers cannot be nested"
 * @Provenance C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatNestedContainerBoundary
 * @Provenance C++ CompileAndExpectFailure despite CSV WorldStory.
 * @Provenance sha256=05a63553dc2beeb674a24d690326b0d1924946a7aa624826a87c7a62ad48c5ad; lines 670-677.
 * @Provenance Expected diagnostic: Containers cannot be nested in other containers
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 */

UCLASS()
class ACoverageFloatNestedArrayActor : AActor
{
	UPROPERTY()
	TArray<TArray<float>> Matrix;
}
