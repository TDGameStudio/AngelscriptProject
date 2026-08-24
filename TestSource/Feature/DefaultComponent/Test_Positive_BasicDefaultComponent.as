// Theme: Feature.DefaultComponent. Positive basic DefaultComponent compiles.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_BasicDefaultComponent
// Oracle: AssertCompiles ADefCompBasicActor. Extra: empty actor is null;
// Root default handle is null. FixtureIsolated.

class ADefCompBasicActor : AActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent Root;
}

bool Observe_DefCompBasic_EmptyDefaultIsNull()
{
	ADefCompBasicActor Actor;
	return Actor == nullptr;
}

bool Observe_DefCompBasic_RootDefaultIsNull(ADefCompBasicActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0284 setup: required ADefCompBasicActor is null");
	}
	return Actor.Root == nullptr;
}
