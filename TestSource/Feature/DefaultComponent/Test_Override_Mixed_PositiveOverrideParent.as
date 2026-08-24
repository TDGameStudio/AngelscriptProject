// Theme: Feature.DefaultComponent. OverrideComponent from parent Root.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Override_Mixed_PositiveOverrideParent
// Oracle: C++ AssertCompiles (currently #if 0, #as-engine-behavior feature-not-supported).
// Extra: empty child actor is null; Root default handle is null. FixtureIsolated.

class ADefCompBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

class ADefCompChildActor : ADefCompBaseActor
{
	UPROPERTY(OverrideComponent = Root)
	UStaticMeshComponent Root;
}

bool Observe_DefCompOverride_EmptyDefaultIsNull()
{
	ADefCompChildActor Actor;
	return Actor == nullptr;
}

bool Observe_DefCompOverride_RootDefaultIsNull(ADefCompChildActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0301 setup: required ADefCompChildActor is null");
	}
	return Actor.Root == nullptr;
}
