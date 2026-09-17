/**
 * @version v1
 * @summary UPROPERTY object handles, upcasting, TSubclassOf and nullptr conversions. BeginPlay assigns each handle, upcasts a derived actor to its base, and exercises the nullable path by assigning nullptr and then casting back.
 * @topic Language
 */
/**
 * @version root
 * @summary UPROPERTY object handles, upcasting, TSubclassOf and nullptr conversions. BeginPlay assigns each handle, upcasts a derived actor to its base, and exercises the nullable path by assigning nullptr and then casting back.
 * @topic Baseline
 */
UCLASS()
class ACoverageReferenceBaseActor : AActor
{
}

UCLASS()
class ACoverageReferenceDerivedActor : ACoverageReferenceBaseActor
{
}

UCLASS()
class UCoverageReferenceMemberObject : UObject
{
}

UCLASS()
class UCoverageReferenceMemberComponent : UActorComponent
{
}

UCLASS()
class ACoverageReferenceOwnerActor : AActor
{
	UPROPERTY()
	UObject ObjectRef;

	UPROPERTY()
	AActor ActorRef;

	UPROPERTY()
	UActorComponent ComponentRef;

	UPROPERTY()
	TSubclassOf<AActor> ActorClassRef;

	UPROPERTY()
	bool ObjectRefAssigned = false;

	UPROPERTY()
	bool ActorUpcastAssigned = false;

	UPROPERTY()
	bool ComponentRefAssigned = false;

	UPROPERTY()
	bool SubclassRefAssigned = false;

	UPROPERTY()
	bool NullComparisonWorked = false;

	UPROPERTY()
	bool CastFromNullableWorked = false;

	UPROPERTY()
	bool IsValidAfterNullReset = false;

	/**
	 * Assigns every handle and records the nullable conversion results.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs none
	 * @Return nothing; the boolean UPROPERTYs record each outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ObjectRef = NewObject(this, UCoverageReferenceMemberObject::StaticClass(), n"CoverageObjectRef", true);

		ACoverageReferenceDerivedActor Derived = Cast<ACoverageReferenceDerivedActor>(SpawnActor(ACoverageReferenceDerivedActor::StaticClass()));
		ActorRef = Derived;

		// UObject and UActorComponent are abstract; NewObject must target concrete script subclasses.
		ComponentRef = Cast<UActorComponent>(NewObject(this, UCoverageReferenceMemberComponent::StaticClass(), n"CoverageComponentRef", true));
		ActorClassRef = ACoverageReferenceDerivedActor::StaticClass();

		ObjectRefAssigned = ObjectRef != nullptr && IsValid(ObjectRef);
		ActorUpcastAssigned = ActorRef != nullptr && ActorRef.IsA(ACoverageReferenceBaseActor::StaticClass());
		ComponentRefAssigned = ComponentRef != nullptr && ComponentRef.IsA(UActorComponent::StaticClass());
		SubclassRefAssigned = ActorClassRef.IsValid() && ActorClassRef.Get() == ACoverageReferenceDerivedActor::StaticClass();

		AActor NullableActor = nullptr;
		NullComparisonWorked = NullableActor == nullptr && !IsValid(NullableActor);
		NullableActor = Derived;
		CastFromNullableWorked = Cast<ACoverageReferenceDerivedActor>(NullableActor) == Derived;
		NullableActor = nullptr;
		IsValidAfterNullReset = !IsValid(NullableActor);

		if (Derived != nullptr)
		{
			Derived.DestroyActor();
		}
	}

	/**
	 * Observe the state of a locally constructed actor before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs a locally constructed actor
	 * @Return true when every reference is null and every flag is false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool MemberReferencesDefaultToNull()
	{
		if (ObjectRef != nullptr)
		{
			return false;
		}

		if (ActorRef != nullptr)
		{
			return false;
		}

		if (ComponentRef != nullptr)
		{
			return false;
		}

		if (ActorClassRef.IsValid())
		{
			return false;
		}

		if (ObjectRefAssigned)
		{
			return false;
		}

		if (ActorUpcastAssigned)
		{
			return false;
		}

		if (ComponentRefAssigned)
		{
			return false;
		}

		if (SubclassRefAssigned)
		{
			return false;
		}

		if (NullComparisonWorked)
		{
			return false;
		}

		if (CastFromNullableWorked)
		{
			return false;
		}

		return !IsValidAfterNullReset;
	}
}
/** @end */
