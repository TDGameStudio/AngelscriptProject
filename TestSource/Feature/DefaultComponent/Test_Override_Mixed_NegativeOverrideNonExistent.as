// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Override_Mixed_NegativeOverrideNonExistent
// Expected diagnostic: Override non-existent component should fail.
// DiagnosticOnly. Isolation=none.

class ADefCompBaseBadActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

class ADefCompChildBadActor : ADefCompBaseBadActor
{
	UPROPERTY(OverrideComponent = NonExistent)
	UStaticMeshComponent Mesh;
}
