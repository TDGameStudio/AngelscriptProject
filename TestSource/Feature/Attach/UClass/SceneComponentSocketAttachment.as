/**
 * AttachSocket on default and runtime attachments. C++ reads DefaultAttachSocket,
 * RuntimeAttachSocket and the attached/location flags after BeginPlay. The
 * observers cover the CDO defaults and copy independence.
 *
 * @Theme Feature.Attach
 * @Subject Attach.SceneComponentSocketAttachment
 * @Harness UClass
 * @Tag Feature.Attach.SceneComponentSocketAttachment
 * @Provenance Theme: Feature.Attach. WorldStory: AttachSocket on default and runtime attachments.
 * @Provenance C++: AngelscriptCoverageSceneComponentTests.cpp::SceneComponentSocketAttachment.
 * @Provenance Oracle after BeginPlay: DefaultAttachSocket n"CoverageSocket"; RuntimeAttachSocket n"RuntimeSocket";
 * @Provenance DefaultChildAttached/RuntimeChildAttached/RootSocketLocationMatchesRoot/ChildSocketLocationMatchesChild true.
 * @Provenance Extra: CDO attached flags false; FName defaults NAME_None.
 * @Provenance FixtureIsolated. Keep the C++ UPROPERTY names.
 */

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

	/**
	 * WorldStory: BeginPlay records the default CoverageSocket attachment, then
	 * attaches RuntimeAttached at n"RuntimeSocket" and compares socket locations.
	 *
	 * @Kind WorldStory
	 * @Covers Attach.SceneComponentSocketAttachment
	 * @Inputs Root, SocketChild attached at CoverageSocket, and RuntimeAttached
	 * @Return DefaultAttachSocket n"CoverageSocket"; RuntimeAttachSocket n"RuntimeSocket"; all four flags true
	 */
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

	/**
	 * Observe that a locally constructed actor still holds the CDO flags and NAME_None sockets.
	 *
	 * @Kind Observe
	 * @Covers Attach.SceneComponentSocketAttachment
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four flags are false and both socket names are NAME_None
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (DefaultChildAttached)
		{
			return false;
		}
		if (RuntimeChildAttached)
		{
			return false;
		}
		if (RootSocketLocationMatchesRoot)
		{
			return false;
		}
		if (ChildSocketLocationMatchesChild)
		{
			return false;
		}
		if (DefaultAttachSocket != NAME_None)
		{
			return false;
		}
		return RuntimeAttachSocket == NAME_None;
	}

	/**
	 * Observe that writing the second actor leaves this actor at its CDO values.
	 *
	 * @Kind Observe
	 * @Covers Attach.SceneComponentSocketAttachment
	 * @Inputs this actor plus a second actor
	 * @Return true when this stays at CDO values and Second holds the written default-socket state
	 * @Param Second the other actor, written then compared
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentSocketAttachmentActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentSocketAttachment setup: required Second is null");
		}
		Second.DefaultChildAttached = true;
		Second.DefaultAttachSocket = n"CoverageSocket";
		if (DefaultChildAttached)
		{
			return false;
		}
		if (DefaultAttachSocket != NAME_None)
		{
			return false;
		}
		if (!Second.DefaultChildAttached)
		{
			return false;
		}
		return Second.DefaultAttachSocket == n"CoverageSocket";
	}
}
