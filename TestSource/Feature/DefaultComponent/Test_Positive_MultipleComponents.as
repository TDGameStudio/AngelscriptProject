// Theme: Feature.DefaultComponent. Positive two children attached to one root.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_MultipleComponents
// Oracle: AssertCompiles ADefCompMultiActor. Extra: empty actor is null;
// Child1/Child2 default handles are null. FixtureIsolated.

class ADefCompMultiActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	USceneComponent Child1;

	UPROPERTY(DefaultComponent, Attach = Root)
	USceneComponent Child2;
}

bool Observe_DefCompMulti_EmptyDefaultIsNull()
{
	ADefCompMultiActor Actor;
	return Actor == nullptr;
}

bool Observe_DefCompMulti_Child1DefaultIsNull(ADefCompMultiActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0288 setup: required ADefCompMultiActor is null");
	}
	return Actor.Child1 == nullptr;
}

bool Observe_DefCompMulti_Child2DefaultIsNull(ADefCompMultiActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0288 setup: required ADefCompMultiActor is null");
	}
	return Actor.Child2 == nullptr;
}
