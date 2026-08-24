// Theme: Feature.Attach. WorldStory: AttachSocket on default and runtime attachments.
// C++: AngelscriptCoverageSceneComponentTests.cpp::SceneComponentSocketAttachment.
// Oracle after BeginPlay: DefaultAttachSocket n"CoverageSocket"; RuntimeAttachSocket n"RuntimeSocket";
// DefaultChildAttached/RuntimeChildAttached/RootSocketLocationMatchesRoot/ChildSocketLocationMatchesChild true.
// Extra: CDO attached flags false; FName defaults NAME_None.
// FixtureIsolated. Keep the C++ UPROPERTY names.

UCLASS()
class ACoverageSceneComponentSocketAttachmentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="CoverageSocket")
	USceneComponent SocketChild;

	UPROPERTY(DefaultComponent)
	USceneComponent RuntimeAttached;

	UPROPERTY()
	FName DefaultAttachSocket;

	UPROPERTY()
	FName RuntimeAttachSocket;

	UPROPERTY()
	bool DefaultChildAttached = false;

	UPROPERTY()
	bool RuntimeChildAttached = false;

	UPROPERTY()
	bool RootSocketLocationMatchesRoot = false;

	UPROPERTY()
	bool ChildSocketLocationMatchesChild = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DefaultChildAttached = SocketChild.GetAttachParent() == Root;
		DefaultAttachSocket = SocketChild.GetAttachSocketName();

		RuntimeAttached.AttachToComponent(Root, n"RuntimeSocket",
			EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);
		RuntimeChildAttached = RuntimeAttached.GetAttachParent() == Root;
		RuntimeAttachSocket = RuntimeAttached.GetAttachSocketName();

		FVector RootLocation = Root.GetWorldLocation();
		RootSocketLocationMatchesRoot = Root.GetSocketLocation(n"CoverageSocket").Equals(RootLocation, 0.01f);

		FVector ChildLocation = SocketChild.GetWorldLocation();
		ChildSocketLocationMatchesChild = SocketChild.GetSocketLocation(NAME_None).Equals(ChildLocation, 0.01f);
	}
}

bool Observe_SocketAttachment_CDODefaults(ACoverageSceneComponentSocketAttachmentActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SceneComponentSocketAttachment setup: required Actor is null");
	}
	return Actor.DefaultChildAttached == false
		&& Actor.RuntimeChildAttached == false
		&& Actor.RootSocketLocationMatchesRoot == false
		&& Actor.ChildSocketLocationMatchesChild == false
		&& Actor.DefaultAttachSocket == NAME_None
		&& Actor.RuntimeAttachSocket == NAME_None;
}

bool Observe_SocketAttachment_CopyIndependence(ACoverageSceneComponentSocketAttachmentActor Original, ACoverageSceneComponentSocketAttachmentActor Copy)
{
	if (Original is null)
	{
		throw("Test_SceneComponentSocketAttachment setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_SceneComponentSocketAttachment setup: required Copy is null");
	}
	Copy.DefaultChildAttached = true;
	Copy.DefaultAttachSocket = n"CoverageSocket";
	return Original.DefaultChildAttached == false
		&& Original.DefaultAttachSocket == NAME_None
		&& Copy.DefaultChildAttached
		&& Copy.DefaultAttachSocket == n"CoverageSocket";
}
