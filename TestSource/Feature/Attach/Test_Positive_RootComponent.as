// Theme: Feature.Attach. WorldStory: DefaultComponent + RootComponent compiles.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_RootComponent AssertCompiles.
// Oracle: ADefCompRootActor constructs; Root is the declared scene root.
// Extra: empty Root may be null before spawn; copy independence of two actors.
// FixtureIsolated. Keep Root.

class ADefCompRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

bool Observe_RootComponent_EmptyDefault(ADefCompRootActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_RootComponent setup: required Actor is null");
	}
	return Actor.Root == nullptr;
}

bool Observe_RootComponent_CopyIndependence()
{
	ADefCompRootActor First;
	ADefCompRootActor Second;
	return First != Second;
}
