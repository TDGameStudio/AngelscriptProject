/**
 * Inherited and forward-declared Attach targets. C++ checks after BeginPlay
 * that BaseAttachmentsPreserved and ImplicitSceneAttached are true. The
 * observers cover the local construct default, the forward-child socket, and
 * copy independence.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.DefaultComponentInheritanceAndForwardAttachMatrix
 * @Harness UClass
 * @Tag Feature.DefaultComponent.DefaultComponentInheritanceAndForwardAttachMatrix
 * @Provenance Theme: Feature.DefaultComponent. WorldStory inherited and forward-declared Attach targets.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInheritanceAndForwardAttachMatrix
 * @Provenance After BeginPlay: BaseAttachmentsPreserved true; ImplicitSceneAttached true.
 * @Provenance Extra: unset handle is null; ForwardChild attaches to ForwardParent + ForwardSocket.
 * @Provenance Keep BaseAttachmentsPreserved/ImplicitSceneAttached. FixtureIsolated.
 */

UCLASS()
class ACoverageUClassDefaultComponentBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="BaseSocket")
	USceneComponent BaseChild;
}

UCLASS()
class ACoverageUClassDefaultComponentDerivedActor : ACoverageUClassDefaultComponentBaseActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent FirstImplicitScene;

	UPROPERTY(DefaultComponent)
	USceneComponent ForwardParent;

	UPROPERTY(DefaultComponent, Attach=ForwardParent, AttachSocket="ForwardSocket")
	USceneComponent ForwardChild;

	UPROPERTY(DefaultComponent)
	USceneComponent DerivedChild;

	UPROPERTY()
	bool BaseAttachmentsPreserved = false;

	UPROPERTY()
	bool ImplicitSceneAttached = false;

	/**
	 * WorldStory: BeginPlay records that the inherited root/child attachments
	 * survived and that the first implicit scene attached to Root.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.DefaultComponentInheritanceAndForwardAttachMatrix
	 * @Inputs inherited Root/BaseChild plus FirstImplicitScene
	 * @Return BaseAttachmentsPreserved and ImplicitSceneAttached true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BaseAttachmentsPreserved =
			Root != nullptr &&
			BaseChild != nullptr &&
			Root.GetAttachParent() == nullptr &&
			BaseChild.GetAttachParent() == Root &&
			BaseChild.GetAttachSocketName() == n"BaseSocket";

		ImplicitSceneAttached =
			FirstImplicitScene != nullptr &&
			Root != nullptr &&
			FirstImplicitScene.GetAttachParent() == Root;
	}

	/**
	 * Observe that a locally constructed derived actor has not recorded either
	 * inheritance flag.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentInheritanceAndForwardAttachMatrix
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (BaseAttachmentsPreserved)
		{
			return false;
		}
		return !ImplicitSceneAttached;
	}

	/**
	 * Observe that ForwardChild attaches to ForwardParent at ForwardSocket.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentInheritanceAndForwardAttachMatrix
	 * @Inputs a spawned derived actor whose forward pair has materialized
	 * @Return true when ForwardChild's parent is ForwardParent and the socket is ForwardSocket
	 */
	UFUNCTION()
	bool ForwardChildSocket()
	{
		if (ForwardChild == nullptr)
		{
			return false;
		}
		if (ForwardParent == nullptr)
		{
			return false;
		}
		if (ForwardChild.GetAttachParent() != ForwardParent)
		{
			return false;
		}
		return ForwardChild.GetAttachSocketName() == n"ForwardSocket";
	}

	/**
	 * Observe that writing this actor leaves a second actor's flags untouched.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentInheritanceAndForwardAttachMatrix
	 * @Inputs this actor plus a second actor
	 * @Return true when the second actor keeps its saved BaseAttachmentsPreserved
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassDefaultComponentDerivedActor Second)
	{
		if (Second is null)
		{
			throw("DefaultComponentInheritanceAndForwardAttachMatrix setup: required Second is null");
		}
		bool Saved = Second.BaseAttachmentsPreserved;
		BaseAttachmentsPreserved = false;
		return Second.BaseAttachmentsPreserved == Saved;
	}
}
