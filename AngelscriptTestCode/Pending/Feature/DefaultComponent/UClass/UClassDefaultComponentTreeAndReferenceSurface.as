/**
 * @version v1
 * @summary A default-component tree plus object and class references. C++ checks after BeginPlay that RootValid, ChildAttached, GrandchildAttached, GrandchildReadable, LogicValid, ObjectReferenceValid, ActorReferenceValid.
 * @topic Feature
 */
/**
 * @version root
 * @summary A default-component tree plus object and class references. C++ checks after BeginPlay that RootValid, ChildAttached, GrandchildAttached, GrandchildReadable, LogicValid, ObjectReferenceValid, ActorReferenceValid.
 * @topic Baseline
 */
UCLASS()
class UCoverageUClassReferenceObject : UObject
{
	UPROPERTY()
	int ObjectValue = 31;

	/**
	 * Read the stored object value.
	 *
	 * @Kind Action
	 * @Covers DefaultComponent.UClassDefaultComponentTreeAndReferenceSurface
	 * @Inputs none
	 * @Return ObjectValue
	 */
	UFUNCTION()
	int ReadValue()
	{
		return ObjectValue;
	}
}

UCLASS()
class UCoverageUClassReferenceComponent : UActorComponent
{
	UPROPERTY()
	int ComponentValue = 41;

	/**
	 * Multiply the stored component value by a factor.
	 *
	 * @Kind Action
	 * @Covers DefaultComponent.UClassDefaultComponentTreeAndReferenceSurface
	 * @Param Factor the multiplier
	 * @Inputs a factor applied to ComponentValue
	 * @Return ComponentValue * Factor
	 */
	UFUNCTION()
	int Multiply(int Factor)
	{
		return ComponentValue * Factor;
	}
}

UCLASS()
class UCoverageUClassReferenceSceneComponent : USceneComponent
{
	UPROPERTY()
	int SceneValue = 53;

	/**
	 * Read the stored scene value.
	 *
	 * @Kind Action
	 * @Covers DefaultComponent.UClassDefaultComponentTreeAndReferenceSurface
	 * @Inputs none
	 * @Return SceneValue
	 */
	UFUNCTION()
	int ReadSceneValue()
	{
		return SceneValue;
	}
}

UCLASS()
class ACoverageUClassReferenceActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="CoverageSocket")
	USceneComponent Child;

	UPROPERTY(DefaultComponent, Attach=Child, ShowOnActor, EditAnywhere, BlueprintReadOnly)
	UCoverageUClassReferenceSceneComponent VisibleGrandchild;

	UPROPERTY(DefaultComponent)
	UCoverageUClassReferenceComponent Logic;

	UPROPERTY()
	UCoverageUClassReferenceObject MemberObject;

	UPROPERTY()
	AActor ActorRef;

	UPROPERTY()
	UCoverageUClassReferenceComponent ComponentRef;

	UPROPERTY()
	TSubclassOf<AActor> ActorClass;

	UPROPERTY()
	bool RootValid = false;

	UPROPERTY()
	bool ChildAttached = false;

	UPROPERTY()
	bool GrandchildAttached = false;

	UPROPERTY()
	bool GrandchildReadable = false;

	UPROPERTY()
	bool LogicValid = false;

	UPROPERTY()
	bool ObjectReferenceValid = false;

	UPROPERTY()
	bool ActorReferenceValid = false;

	UPROPERTY()
	bool ComponentReferenceValid = false;

	UPROPERTY()
	bool ClassReferenceValid = false;

	/**
	 * WorldStory: BeginPlay wires object, actor, component and class references,
	 * then records the tree and reference flags.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.UClassDefaultComponentTreeAndReferenceSurface
	 * @Inputs Root, Child, VisibleGrandchild and Logic default components
	 * @Return all nine flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MemberObject = Cast<UCoverageUClassReferenceObject>(
			NewObject(this, UCoverageUClassReferenceObject::StaticClass(), n"CoverageUClassReferenceObject"));
		ActorRef = this;
		ComponentRef = Logic;
		ActorClass = ACoverageUClassReferenceActor::StaticClass();

		RootValid = Root != nullptr && Root.GetOwner() == this;
		ChildAttached = Child != nullptr && Root != nullptr &&
			Child.GetAttachParent() == Root &&
			Child.GetAttachSocketName() == n"CoverageSocket";
		GrandchildAttached = VisibleGrandchild != nullptr && Child != nullptr &&
			VisibleGrandchild.GetAttachParent() == Child;
		GrandchildReadable = VisibleGrandchild != nullptr &&
			VisibleGrandchild.GetOwner() == this &&
			VisibleGrandchild.ReadSceneValue() == 53;
		LogicValid = Logic != nullptr &&
			Logic.GetOwner() == this &&
			Logic.ComponentValue == 41;
		ObjectReferenceValid = MemberObject != nullptr &&
			MemberObject.GetOuter() == this &&
			MemberObject.ReadValue() == 31;
		ActorReferenceValid = ActorRef == this;
		ComponentReferenceValid = ComponentRef == Logic &&
			ComponentRef.Multiply(2) == 82;
		ClassReferenceValid = ActorClass.Get() == ACoverageUClassReferenceActor::StaticClass() &&
			ActorClass.IsChildOf(AActor::StaticClass());
	}

	/**
	 * Observe that a locally constructed actor has no MemberObject and has not
	 * recorded ObjectReferenceValid.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.UClassDefaultComponentTreeAndReferenceSurface
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when MemberObject is null and ObjectReferenceValid is false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (MemberObject != nullptr)
		{
			return false;
		}
		return !ObjectReferenceValid;
	}

	/**
	 * Observe the zero boundary of Logic.Multiply.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.UClassDefaultComponentTreeAndReferenceSurface
	 * @Inputs a spawned actor whose Logic component has materialized
	 * @Return Logic.Multiply(0), expected to be 0
	 * @Boundary zero factor
	 */
	UFUNCTION()
	int MultiplyZeroBoundary()
	{
		if (Logic is null)
		{
			throw("UClassDefaultComponentTreeAndReferenceSurface setup: required Logic component is null");
		}
		return Logic.Multiply(0);
	}

	/**
	 * Observe that writing this actor leaves a second actor's flags untouched.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.UClassDefaultComponentTreeAndReferenceSurface
	 * @Inputs this actor plus a second actor
	 * @Return true when the second actor keeps its saved RootValid
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassReferenceActor Second)
	{
		if (Second is null)
		{
			throw("UClassDefaultComponentTreeAndReferenceSurface setup: required Second is null");
		}
		bool Saved = Second.RootValid;
		RootValid = false;
		return Second.RootValid == Saved;
	}
}
/** @end */
