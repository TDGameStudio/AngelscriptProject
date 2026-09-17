/**
 * @version v1
 * @summary Member handles for a UObject, an AActor and a UActorComponent, assigned from NewObject, SpawnActor and CreateComponent. C++ verifies the four flags by path. The observers cover the local-construct default and copy.
 * @topic World
 */
/**
 * @version root
 * @summary Member handles for a UObject, an AActor and a UActorComponent, assigned from NewObject, SpawnActor and CreateComponent. C++ verifies the four flags by path. The observers cover the local-construct default and copy.
 * @topic Baseline
 */
UCLASS()
class ACoverageHandleMemberReferenceActor : AActor
{
	UPROPERTY()
	UObject MemberObject;

	UPROPERTY()
	AActor MemberActor;

	UPROPERTY()
	UActorComponent MemberComponent;

	UPROPERTY()
	bool ObjectReferenceWorked = false;

	UPROPERTY()
	bool ActorReferenceWorked = false;

	UPROPERTY()
	bool ComponentReferenceWorked = false;

	UPROPERTY()
	bool ComponentOwnerWorked = false;

	/**
	 * WorldStory: BeginPlay assigns all three member handles and records that each
	 * one landed where it should.
	 *
	 * @Kind WorldStory
	 * @Covers Component.MemberObjectActorComponentReferences
	 * @Inputs none
	 * @Return all four flags true; the object is outer-ed to this, the actor is not this,
	 * the component is named and owned by this
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MemberObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageMemberObject");
		MemberActor = SpawnActor(AActor::StaticClass());
		MemberComponent = CreateComponent(USceneComponent::StaticClass(), n"CoverageMemberComponent");

		ObjectReferenceWorked = MemberObject != nullptr && MemberObject.GetOuter() == this;
		ActorReferenceWorked = MemberActor != nullptr && MemberActor != this;
		ComponentReferenceWorked = MemberComponent != nullptr && MemberComponent.GetName() == n"CoverageMemberComponent";
		ComponentOwnerWorked = MemberComponent != nullptr && MemberComponent.GetOwner() == this;
	}

	/**
	 * Observe that a locally constructed actor holds no handles and no flags.
	 *
	 * @Kind Observe
	 * @Covers Component.MemberObjectActorComponentReferences
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three handles are null and all flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (MemberObject != nullptr)
		{
			return false;
		}
		if (MemberActor != nullptr)
		{
			return false;
		}
		if (MemberComponent != nullptr)
		{
			return false;
		}
		if (ObjectReferenceWorked)
		{
			return false;
		}
		if (ActorReferenceWorked)
		{
			return false;
		}
		if (ComponentReferenceWorked)
		{
			return false;
		}
		return !ComponentOwnerWorked;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.MemberObjectActorComponentReferences
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays at its defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageHandleMemberReferenceActor Second)
	{
		if (Second is null)
		{
			throw("MemberObjectActorComponentReferences setup: required Second is null");
		}
		ObjectReferenceWorked = true;
		ActorReferenceWorked = true;

		if (!ObjectReferenceWorked)
		{
			return false;
		}
		if (!ActorReferenceWorked)
		{
			return false;
		}
		if (Second.ObjectReferenceWorked)
		{
			return false;
		}
		if (Second.ActorReferenceWorked)
		{
			return false;
		}
		return Second.MemberObject == nullptr;
	}
}
/** @end */
