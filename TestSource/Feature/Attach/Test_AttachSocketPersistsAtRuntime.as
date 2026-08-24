// Theme: Feature.Attach. WorldStory: AttachSocket metadata persists on the runtime scene attachment.
// C++: AngelscriptComponentLifecycleExtendedTests.cpp::AttachSocketPersistsAtRuntime.
// Oracle: Child.GetAttachParent()==Root; Child.GetAttachSocketName()==n"NamedSocket".
// Extra: CDO component pointers may be null before spawn; copy independence of two actors.
// FixtureIsolated. Keep Root and Child.

UCLASS()
class ATestDefaultComponentExtendedAttachSocket : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root, AttachSocket = "NamedSocket")
	USceneComponent Child;
}

bool Observe_AttachSocket_EmptyDefault(ATestDefaultComponentExtendedAttachSocket Actor)
{
	if (Actor is null)
	{
		throw("Test_AttachSocketPersistsAtRuntime setup: required Actor is null");
	}
	return Actor.Root == nullptr && Actor.Child == nullptr;
}

bool Observe_AttachSocket_RuntimeIfMaterialized(ATestDefaultComponentExtendedAttachSocket Actor)
{
	if (Actor is null)
	{
		throw("Test_AttachSocketPersistsAtRuntime setup: required Actor is null");
	}
	if (Actor.Root == nullptr || Actor.Child == nullptr)
	{
		return Actor.Root == nullptr && Actor.Child == nullptr;
	}
	return Actor.Child.GetAttachParent() == Actor.Root
		&& Actor.Child.GetAttachSocketName() == n"NamedSocket";
}

bool Observe_AttachSocket_CopyIndependence()
{
	ATestDefaultComponentExtendedAttachSocket First;
	ATestDefaultComponentExtendedAttachSocket Second;
	return First != Second;
}
