/**
 * @version v1
 * @summary UObject, actor, component, and TSubclassOf member references. After BeginPlay, MemberObjectAssigned/ActorReferenceAssigned/ComponentReferenceAssigned/SubclassAssigned are all true. Keep those UPROPERTY names.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UObject, actor, component, and TSubclassOf member references. After BeginPlay, MemberObjectAssigned/ActorReferenceAssigned/ComponentReferenceAssigned/SubclassAssigned are all true. Keep those UPROPERTY names.
 * @topic Baseline
 */
UCLASS()
class UCoverageMemberObject : UObject
{
	UPROPERTY()
	int Value = 31;

	/**
	 * Observe the member-object Value default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Composition
	 * @Inputs a freshly constructed object
	 * @Return Value
	 */
	UFUNCTION()
	int ValueDefault()
	{
		return Value;
	}
}

UCLASS()
class UCoverageMemberComponent : UActorComponent
{
	UPROPERTY()
	int ComponentValue = 41;
}

UCLASS()
class ACoverageCompositionReferenceActor : AActor
{
	UPROPERTY()
	UCoverageMemberObject MemberObject;

	UPROPERTY()
	AActor OtherActor;

	UPROPERTY(DefaultComponent)
	UCoverageMemberComponent MemberComponent;

	UPROPERTY()
	TSubclassOf<AActor> ActorClass;

	UPROPERTY()
	bool MemberObjectAssigned = false;

	UPROPERTY()
	bool ActorReferenceAssigned = false;

	UPROPERTY()
	bool ComponentReferenceAssigned = false;

	UPROPERTY()
	bool SubclassAssigned = false;

	/**
	 * WorldStory: BeginPlay assigns member object, self actor, subclass, and component flags.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Composition
	 * @Inputs NewObject member, this, DefaultComponent, StaticClass
	 * @Return the four Assigned flags set when each reference is valid
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MemberObject = Cast<UCoverageMemberObject>(NewObject(this, UCoverageMemberObject::StaticClass()));
		OtherActor = this;
		ActorClass = ACoverageCompositionReferenceActor::StaticClass();

		MemberObjectAssigned = MemberObject != nullptr && MemberObject.Value == 31;
		ActorReferenceAssigned = OtherActor == this;
		ComponentReferenceAssigned = MemberComponent != nullptr && MemberComponent.ComponentValue == 41;
		SubclassAssigned = ActorClass.Get() == ACoverageCompositionReferenceActor::StaticClass();
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Composition
	 * @Inputs an unset ACoverageCompositionReferenceActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageCompositionReferenceActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the Assigned flags before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.Composition
	 * @Inputs a freshly constructed actor
	 * @Return true when all four flags are false
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool FlagsDefaultFalse()
	{
		if (MemberObjectAssigned)
		{
			return false;
		}
		if (ActorReferenceAssigned)
		{
			return false;
		}
		if (ComponentReferenceAssigned)
		{
			return false;
		}
		return SubclassAssigned == false;
	}
}
/** @end */
