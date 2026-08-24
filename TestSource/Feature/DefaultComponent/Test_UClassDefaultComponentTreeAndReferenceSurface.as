// Theme: Feature.DefaultComponent. WorldStory default-component tree plus object/class references.
// C++: AngelscriptCoverageUClassTests.cpp::UClassDefaultComponentTreeAndReferenceSurface
// After BeginPlay: RootValid/ChildAttached/GrandchildAttached/GrandchildReadable/LogicValid
// ObjectReferenceValid/ActorReferenceValid/ComponentReferenceValid/ClassReferenceValid all true.
// Extra: unset handle is null; MemberObject is null before BeginPlay. Keep those UPROPERTY names.
// FixtureIsolated.

UCLASS()
class UCoverageUClassReferenceObject : UObject
{
	UPROPERTY()
	int ObjectValue = 31;

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
}

bool Observe_ReferenceSurface_EmptyDefaultIsNull()
{
	ACoverageUClassReferenceActor Actor;
	return Actor == nullptr;
}

bool Observe_ReferenceSurface_MemberObjectNullBeforeBeginPlay(ACoverageUClassReferenceActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0119 setup: required ACoverageUClassReferenceActor is null");
	}
	return Actor.MemberObject == nullptr && !Actor.ObjectReferenceValid;
}

int Observe_ReferenceSurface_MultiplyZeroBoundary(ACoverageUClassReferenceActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0119 setup: required ACoverageUClassReferenceActor is null");
	}
	if (Actor.Logic == nullptr)
	{
		throw("TS-FEAT-0119 setup: required Logic component is null");
	}
	return Actor.Logic.Multiply(0);
}

bool Observe_ReferenceSurface_CopyIndependent(
	ACoverageUClassReferenceActor First,
	ACoverageUClassReferenceActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0119 setup: required ACoverageUClassReferenceActor pair is null");
	}
	bool Saved = Second.RootValid;
	First.RootValid = false;
	return Second.RootValid == Saved;
}
