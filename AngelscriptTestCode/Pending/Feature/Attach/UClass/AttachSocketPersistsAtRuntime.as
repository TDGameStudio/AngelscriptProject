/**
 * @version v1
 * @summary AttachSocket metadata persists on the runtime scene attachment. C++ spawns the actor and checks Child.GetAttachParent()==Root and GetAttachSocketName() == n"NamedSocket". The observers cover the local-construct default.
 * @topic Feature
 */
/**
 * @version root
 * @summary AttachSocket metadata persists on the runtime scene attachment. C++ spawns the actor and checks Child.GetAttachParent()==Root and GetAttachSocketName() == n"NamedSocket". The observers cover the local-construct default.
 * @topic Baseline
 */
UCLASS()
class ATestDefaultComponentExtendedAttachSocket : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root, AttachSocket = "NamedSocket")
	USceneComponent Child;

	/**
	 * Observe that a locally constructed actor has not materialized Root or Child.
	 *
	 * @Kind Observe
	 * @Covers Attach.AttachSocketPersistsAtRuntime
	 * @Inputs an actor that has not been spawned
	 * @Return true when Root and Child are both null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Root != nullptr)
		{
			return false;
		}
		return Child == nullptr;
	}

	/**
	 * Observe the named-socket attachment when both components have materialized,
	 * and the joint-null case when they have not.
	 *
	 * @Kind Observe
	 * @Covers Attach.AttachSocketPersistsAtRuntime
	 * @Inputs this actor after spawn, or a local construct whose handles are still null
	 * @Return true when Child is attached to Root at n"NamedSocket", or both handles are null
	 * @Boundary components may be null before spawn
	 */
	UFUNCTION()
	bool RuntimeIfMaterialized()
	{
		if (Root == nullptr)
		{
			return Child == nullptr;
		}
		if (Child == nullptr)
		{
			return false;
		}
		if (Child.GetAttachParent() != Root)
		{
			return false;
		}
		return Child.GetAttachSocketName() == n"NamedSocket";
	}

	/**
	 * Observe that a second instance is a different object.
	 *
	 * @Kind Observe
	 * @Covers Attach.AttachSocketPersistsAtRuntime
	 * @Inputs this actor plus a second actor
	 * @Return true when the two actors are not the same object
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDefaultComponentExtendedAttachSocket Second)
	{
		if (Second is null)
		{
			throw("AttachSocketPersistsAtRuntime setup: required Second is null");
		}
		return this != Second;
	}
}
/** @end */
