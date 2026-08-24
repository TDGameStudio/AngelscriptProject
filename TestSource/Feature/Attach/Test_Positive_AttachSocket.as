// Theme: Feature.Attach. WorldStory: DefaultComponent Attach + AttachSocket compiles.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_AttachSocket AssertCompiles.
// Oracle: Child attaches to Root at "Socket1" when components materialize.
// Extra: empty Root/Child may be null before spawn; copy independence.
// FixtureIsolated. Keep Root and Child.

class ADefCompSocketActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root, AttachSocket = "Socket1")
	USceneComponent Child;
}

bool Observe_AttachSocketPositive_EmptyDefault(ADefCompSocketActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_AttachSocket setup: required Actor is null");
	}
	return Actor.Root == nullptr && Actor.Child == nullptr;
}

bool Observe_AttachSocketPositive_RuntimeIfMaterialized(ADefCompSocketActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_AttachSocket setup: required Actor is null");
	}
	if (Actor.Root == nullptr || Actor.Child == nullptr)
	{
		return Actor.Root == nullptr && Actor.Child == nullptr;
	}
	return Actor.Child.GetAttachParent() == Actor.Root
		&& Actor.Child.GetAttachSocketName() == n"Socket1";
}

bool Observe_AttachSocketPositive_CopyIndependence()
{
	ADefCompSocketActor First;
	ADefCompSocketActor Second;
	return First != Second;
}
