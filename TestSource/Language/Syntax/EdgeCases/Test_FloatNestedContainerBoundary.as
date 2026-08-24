// Theme: Language.Syntax.EdgeCases. C++ CompileAndExpectFailure despite CSV WorldStory.
// C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatNestedContainerBoundary
// sha256=05a63553dc2beeb674a24d690326b0d1924946a7aa624826a87c7a62ad48c5ad; lines 670-677.
// Expected diagnostic: Containers cannot be nested in other containers
// Isolate this failing program; do not add declarations that would compile it away.

UCLASS()
class ACoverageFloatNestedArrayActor : AActor
{
	UPROPERTY()
	TArray<TArray<float>> Matrix;
}
