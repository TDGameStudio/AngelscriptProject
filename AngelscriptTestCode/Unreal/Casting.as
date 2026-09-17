/**
 * @version v1
 * @summary UCLASS object casts, handle casts, and handle comparison.
 * @topic Unreal
 * @topic Casting
 *
 * object-cast-and-type-checks
 * handle-comparison
 * handle-as-parameter
 * handle-as-property
 * handle-basics
 * handle-cast
 * handle-in-containers
 * handle-operations
 * member-reference-and-nullable-handle-conversions
 */
/**
 * @begin object-cast-and-type-checks
 * @summary Object casting and type checks on generated actors: Cast<T> between a base and a derived script class, IsA, IsChildOf, and GetClass. A downcast to a type the object is not yields null rather than throwing, which is what.
 * @topic Casting
 */
UCLASS()
class ACoverageCastBaseActor : AActor
{
}

UCLASS()
class ACoverageCastDerivedActor : ACoverageCastBaseActor
{
	UPROPERTY()
	int DerivedValue = 77;
}

UCLASS()
class ACoverageCastOtherActor : AActor
{
}

namespace CastingTest
{
	/**
	 * Observe that a derived actor downcasts back from its base handle and
	 * keeps its property value.
	 *
	 * @Kind WorldStory
	 * @Covers Casting.Cast
	 * @Inputs Spawn the derived actor, widen to the base, then narrow back
	 * @Return true when the downcast succeeds and the property still reads 77
	 */
	UFUNCTION()
	bool DowncastFromBaseKeepsProperty()
	{
		ACoverageCastDerivedActor Derived = Cast<ACoverageCastDerivedActor>(SpawnActor(ACoverageCastDerivedActor::StaticClass()));
		if (Derived == nullptr)
		{
			return false;
		}
		Derived.DerivedValue = 77;

		ACoverageCastBaseActor AsBase = Derived;
		ACoverageCastDerivedActor Downcasted = Cast<ACoverageCastDerivedActor>(AsBase);
		if (Downcasted == nullptr)
		{
			Derived.DestroyActor();
			return false;
		}

		bool bOk = Downcasted.DerivedValue == 77;
		Derived.DestroyActor();
		return bOk;
	}

	/**
	 * Observe that a cast to an unrelated type yields null rather than throwing.
	 *
	 * @Kind WorldStory
	 * @Covers Casting.Cast
	 * @Inputs Spawn the derived actor, widen to AActor, then cast to an unrelated actor class
	 * @Return true when the unrelated cast is nullptr
	 */
	UFUNCTION()
	bool InvalidCastReturnsNull()
	{
		ACoverageCastDerivedActor Derived = Cast<ACoverageCastDerivedActor>(SpawnActor(ACoverageCastDerivedActor::StaticClass()));
		if (Derived == nullptr)
		{
			return false;
		}

		AActor AsActor = Derived;
		ACoverageCastOtherActor Invalid = Cast<ACoverageCastOtherActor>(AsActor);
		bool bOk = Invalid == nullptr;
		Derived.DestroyActor();
		return bOk;
	}

	/**
	 * Observe IsA: a derived instance reports true for its base class.
	 *
	 * @Kind WorldStory
	 * @Covers Casting.TypeCheck
	 * @Inputs Spawn the derived actor, widen to AActor, then call IsA on the base class
	 * @Return true when IsA reports the base
	 */
	UFUNCTION()
	bool IsAReportsBaseClass()
	{
		ACoverageCastDerivedActor Derived = Cast<ACoverageCastDerivedActor>(SpawnActor(ACoverageCastDerivedActor::StaticClass()));
		if (Derived == nullptr)
		{
			return false;
		}

		AActor AsActor = Derived;
		bool bOk = AsActor.IsA(ACoverageCastBaseActor::StaticClass());
		Derived.DestroyActor();
		return bOk;
	}

	/**
	 * Observe IsChildOf: the derived class reports as a child of the base.
	 *
	 * @Kind Observe
	 * @Covers Casting.TypeCheck
	 * @Inputs Compare the derived static class against the base static class
	 * @Return true when IsChildOf reports the inheritance
	 */
	UFUNCTION()
	bool DerivedClassIsChildOfBase()
	{
		return ACoverageCastDerivedActor::StaticClass().IsChildOf(ACoverageCastBaseActor::StaticClass());
	}

	/**
	 * Observe GetClass: a spawned instance reports its exact generated class.
	 *
	 * @Kind WorldStory
	 * @Covers Casting.TypeCheck
	 * @Inputs Spawn the derived actor and read its class
	 * @Return true when GetClass equals the derived static class
	 */
	UFUNCTION()
	bool GetClassReportsExactClass()
	{
		ACoverageCastDerivedActor Derived = Cast<ACoverageCastDerivedActor>(SpawnActor(ACoverageCastDerivedActor::StaticClass()));
		if (Derived == nullptr)
		{
			return false;
		}

		bool bOk = Derived.GetClass() == ACoverageCastDerivedActor::StaticClass();
		Derived.DestroyActor();
		return bOk;
	}

	/**
	 * Observe the null default: casting nullptr yields a null handle.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Inputs Cast<ACoverageCastDerivedActor>(nullptr)
	 * @Return true when the result is nullptr
	 * @Boundary null source
	 */
	UFUNCTION()
	bool CastNullIsNull()
	{
		ACoverageCastDerivedActor Downcasted = Cast<ACoverageCastDerivedActor>(nullptr);
		return Downcasted == nullptr;
	}

	/**
	 * Observe the other-type boundary: a base handle that is not the unrelated
	 * type casts to null.
	 *
	 * @Kind Observe
	 * @Covers Casting.Cast
	 * @Param AsBase Base handle supplied by the runner
	 * @Inputs Cast the base handle to the unrelated actor class
	 * @Return true when the result is nullptr
	 * @Boundary unrelated target type
	 */
	UFUNCTION()
	bool UnrelatedCastFromBaseIsNull(ACoverageCastBaseActor AsBase)
	{
		ACoverageCastOtherActor Invalid = Cast<ACoverageCastOtherActor>(AsBase);
		return Invalid == nullptr;
	}
}
/** @end */
/**
 * @begin handle-comparison
 * @summary Object handles compare with == and != by reference identity, not by value: two handles to the same actor are equal, a handle compared against nullptr reports whether it is null, and handles to two different actors are.
 * @topic Casting
 */
UCLASS()
class ACoverageHandleComparisonActor : AActor
{
	UPROPERTY()
	bool SameRefEqual = false;

	UPROPERTY()
	bool NullComparison = false;

	UPROPERTY()
	bool DifferentRefNotEqual = false;

	UPROPERTY()
	AActor OtherActor;

	UPROPERTY()
	bool OtherActorStartedNull = false;

	/**
	 * Run the handle comparisons once at play time, so the C++ fixture can read
	 * the resulting property values by path.
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Handle1 = this;
		AActor Handle2 = this;

		// Same object should be equal
		if (Handle1 == Handle2)
		{
			SameRefEqual = true;
		}

		// Null comparisons
		AActor NullHandle = nullptr;
		if (NullHandle == nullptr && this != nullptr)
		{
			NullComparison = true;
		}

		OtherActorStartedNull = (OtherActor == nullptr);

		// Different objects should not be equal
		OtherActor = SpawnActor(AActor::StaticClass());
		if (this != OtherActor && OtherActor != nullptr)
		{
			DifferentRefNotEqual = true;
		}
	}
}

namespace OperatorsTest
{
	/**
	 * Observe reference equality: two handles to the same object are equal.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the comparison actor and read its SameRefEqual property
	 * @Return true when the two handles to the same actor compared equal
	 */
	UFUNCTION()
	bool HandlesToSameObjectAreEqual()
	{
		ACoverageHandleComparisonActor Actor = SpawnActor(ACoverageHandleComparisonActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		return Actor.SameRefEqual;
	}

	/**
	 * Observe null comparison: a null handle equals nullptr while a live actor
	 * does not.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the comparison actor and read its NullComparison property
	 * @Return true when the null check behaved as expected
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullHandleComparesEqualToNullptr()
	{
		ACoverageHandleComparisonActor Actor = SpawnActor(ACoverageHandleComparisonActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		return Actor.NullComparison;
	}

	/**
	 * Observe the default-null boundary: an unset actor property is null before
	 * anything is spawned into it.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the comparison actor and read its OtherActorStartedNull property
	 * @Return true when the property started null
	 * @Boundary unset actor property
	 */
	UFUNCTION()
	bool UnsetActorPropertyStartsNull()
	{
		ACoverageHandleComparisonActor Actor = SpawnActor(ACoverageHandleComparisonActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		return Actor.OtherActorStartedNull;
	}

	/**
	 * Observe reference inequality: handles to two different objects compare
	 * unequal.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the comparison actor and read its DifferentRefNotEqual property
	 * @Return true when the two distinct actors compared unequal
	 */
	UFUNCTION()
	bool HandlesToDifferentObjectsAreUnequal()
	{
		ACoverageHandleComparisonActor Actor = SpawnActor(ACoverageHandleComparisonActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		return Actor.DifferentRefNotEqual;
	}
}
/** @end */
/**
 * @begin handle-as-parameter
 * @summary Actor handles flowing through all three parameter directions: by value, as a return value, and through an out parameter.
 * @topic Casting
 */
UCLASS()
class ACoverageHandleParameterActor : AActor
{
	UPROPERTY()
	bool InputParamWorked = false;

	UPROPERTY()
	bool ReturnValueWorked = false;

	UPROPERTY()
	bool OutParamWorked = false;

	/**
	 * Receives a handle by value and compares it to this actor.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an actor handle
	 * @Return nothing; InputParamWorked records the match
	 * @Param InActor the handle received by value
	 */
	void ProcessActor(AActor InActor)
	{
		if (InActor != nullptr && InActor == this)
		{
			InputParamWorked = true;
		}
	}

	/**
	 * Returns this actor's own handle.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return this actor
	 */
	AActor GetSelf()
	{
		return this;
	}

	/**
	 * Writes this actor's handle through an out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; OutActor receives this actor
	 * @Param OutActor the out parameter
	 */
	void GetActorOut(AActor&out OutActor)
	{
		OutActor = this;
	}

	/**
	 * Exercises all three parameter directions.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all three flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test input parameter
		ProcessActor(this);

		// Test return value
		AActor Returned = GetSelf();
		if (Returned == this)
		{
			ReturnValueWorked = true;
		}

		// Test out parameter
		AActor OutResult;
		GetActorOut(OutResult);
		if (OutResult == this)
		{
			OutParamWorked = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has run no direction.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleAsParameterFlagsDefaultToFalse()
	{
		if (InputParamWorked)
		{
			return false;
		}

		if (ReturnValueWorked)
		{
			return false;
		}

		return !OutParamWorked;
	}
}
/** @end */
/**
 * @begin handle-as-property
 * @summary Handle UPROPERTYs carrying different specifiers: an EditAnywhere actor handle, a BlueprintReadWrite pawn handle, and a categorized component handle. BeginPlay assigns the first two from the world.
 * @topic Casting
 */
UCLASS()
class ACoverageHandlePropertyActor : AActor
{
	UPROPERTY(EditAnywhere)
	AActor TargetActor;

	UPROPERTY(BlueprintReadWrite)
	APawn TargetPawn;

	UPROPERTY(Category="Refs")
	UActorComponent TargetComponent;

	UPROPERTY()
	bool PropertiesAssigned = false;

	/**
	 * Assigns the actor and pawn handles.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; PropertiesAssigned records both assignments
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TargetActor = this;
		TargetPawn = Cast<APawn>(SpawnActor(APawn::StaticClass()));

		if (TargetActor != nullptr && TargetPawn != nullptr)
		{
			PropertiesAssigned = true;
		}
	}

	/**
	 * Observe that a locally constructed actor leaves every handle null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three handles are null and the flag is false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleAsPropertyDefaultEmpty()
	{
		if (TargetActor != nullptr)
		{
			return false;
		}

		if (TargetPawn != nullptr)
		{
			return false;
		}

		if (TargetComponent != nullptr)
		{
			return false;
		}

		return !PropertiesAssigned;
	}
}
/** @end */
/**
 * @begin handle-basics
 * @summary Actor handle basics: null by default, valid after assignment, and null again after clearing. The results encode the last observed state of each check.
 * @topic Casting
 */
UCLASS()
class ACoverageHandleBasicsActor : AActor
{
	UPROPERTY()
	bool TestPassed = false;

	UPROPERTY()
	AActor TargetActor;

	UPROPERTY()
	int NullCheckResult = 0;

	UPROPERTY()
	int IsValidResult = 0;

	/**
	 * Runs the null, assign, valid and clear sequence.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the results record the final state
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test null by default
		if (TargetActor == nullptr)
		{
			NullCheckResult = 1;
		}

		// Test IsValid with nullptr
		if (!IsValid(TargetActor))
		{
			IsValidResult = 1;
		}

		// Assign self
		TargetActor = this;

		// Test non-null after assignment
		if (TargetActor != nullptr)
		{
			NullCheckResult = 2;
		}

		// Test IsValid with valid object
		if (IsValid(TargetActor))
		{
			IsValidResult = 2;
		}

		// Assign back to null
		TargetActor = nullptr;

		// Verify null again
		if (TargetActor == nullptr)
		{
			NullCheckResult = 3;
		}

		TestPassed = (NullCheckResult == 3 && IsValidResult == 2);
	}

	/**
	 * Observe that a locally constructed actor has run no checks.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the target is null, both results are 0 and TestPassed is false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleBasicsDefaultEmpty()
	{
		if (TestPassed)
		{
			return false;
		}

		if (TargetActor != nullptr)
		{
			return false;
		}

		if (NullCheckResult != 0)
		{
			return false;
		}

		return IsValidResult == 0;
	}
}
/** @end */
/**
 * @begin handle-cast
 * @summary Handle casts between derived, base and unrelated types: upcasting always succeeds, downcasting back succeeds, and casting to an unrelated type yields nullptr.
 * @topic Casting
 */
UCLASS()
class ACoverageHandleCastActor : APawn
{
	UPROPERTY()
	bool CastToBaseSucceeded = false;

	UPROPERTY()
	bool CastToDerivedSucceeded = false;

	UPROPERTY()
	bool CastToUnrelatedFailed = false;

	/**
	 * Runs the upcast, downcast and unrelated-cast sequence.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all three flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Cast derived to base (always succeeds)
		AActor ActorRef = Cast<AActor>(this);
		if (ActorRef != nullptr)
		{
			CastToBaseSucceeded = true;
		}

		// Cast base back to derived (should succeed since it's actually a Pawn)
		APawn PawnRef = Cast<APawn>(ActorRef);
		if (PawnRef != nullptr)
		{
			CastToDerivedSucceeded = true;
		}

		// Cast to unrelated type (should fail)
		APlayerController ControllerRef = Cast<APlayerController>(this);
		if (ControllerRef == nullptr)
		{
			CastToUnrelatedFailed = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has run no cast.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleCastFlagsDefaultToFalse()
	{
		if (CastToBaseSucceeded)
		{
			return false;
		}

		if (CastToDerivedSucceeded)
		{
			return false;
		}

		return !CastToUnrelatedFailed;
	}
}
/** @end */
/**
 * @begin handle-in-containers
 * @summary Actor handles stored in containers: a TArray holding a null handle mid-sequence, and two TMaps keyed by int and string. A stored null is a value, not a missing key.
 * @topic Casting
 */
UCLASS()
class ACoverageHandleContainerActor : AActor
{
	UPROPERTY()
	TArray<AActor> ActorArray;

	UPROPERTY()
	TMap<int, AActor> IntToActorMap;

	UPROPERTY()
	TMap<FString, AActor> StringToActorMap;

	/**
	 * Populates all three containers with handles including a null.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the containers hold self, spawned actors and null
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Populate TArray with handles
		ActorArray.Add(this);
		ActorArray.Add(SpawnActor(AActor::StaticClass()));
		ActorArray.Add(nullptr);
		ActorArray.Add(SpawnActor(AActor::StaticClass()));

		// Populate TMap<int, AActor>
		IntToActorMap.Add(1, this);
		IntToActorMap.Add(2, ActorArray[1]);
		IntToActorMap.Add(3, nullptr);

		// Populate TMap<FString, AActor>
		StringToActorMap.Add("Self", this);
		StringToActorMap.Add("Other", ActorArray[1]);
	}

	/**
	 * Observe that a locally constructed actor leaves all containers empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleInContainersDefaultEmpty()
	{
		if (ActorArray.Num() != 0)
		{
			return false;
		}

		if (IntToActorMap.Num() != 0)
		{
			return false;
		}

		return StringToActorMap.Num() == 0;
	}

	/**
	 * Observe that a null handle can be stored and read back.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a script-side array holding self, an actor and null
	 * @Return true when the null sits at index 2 and the count is 3
	 * @Boundary stored null
	 */
	UFUNCTION()
	bool HandleInContainersStoredNull()
	{
		TArray<AActor> Local;
		Local.Add(this);
		Local.Add(nullptr);
		Local.Add(SpawnActor(AActor::StaticClass()));

		if (Local.Num() != 3)
		{
			return false;
		}

		if (Local[0] != this)
		{
			return false;
		}

		return Local[1] == nullptr;
	}
}
/** @end */
/**
 * @begin handle-operations
 * @summary Handle introspection: GetClass, GetName and IsA on an actor handle, with the observed name stored for C++ to verify.
 * @topic Casting
 */
UCLASS()
class ACoverageHandleOperationsActor : AActor
{
	UPROPERTY()
	bool GetClassWorked = false;

	UPROPERTY()
	bool GetNameWorked = false;

	UPROPERTY()
	bool IsAWorked = false;

	UPROPERTY()
	FString ActorName;

	/**
	 * Runs GetClass, GetName and IsA over this handle.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the flags and name record each outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test GetClass
		UClass MyClass = GetClass();
		if (MyClass != nullptr)
		{
			GetClassWorked = true;
		}

		// Test GetName
		FString Name = GetName().ToString();
		if (!Name.IsEmpty())
		{
			GetNameWorked = true;
			ActorName = Name;
		}

		// Test IsA check
		AActor ActorRef = this;
		if (ActorRef.IsA(AActor::StaticClass()))
		{
			IsAWorked = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has run no operation.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all flags are false and the name is empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleOperationsDefaultEmpty()
	{
		if (GetClassWorked)
		{
			return false;
		}

		if (GetNameWorked)
		{
			return false;
		}

		if (IsAWorked)
		{
			return false;
		}

		return ActorName.Len() == 0;
	}
}
/** @end */
/**
 * @begin member-reference-and-nullable-handle-conversions
 * @summary UPROPERTY object handles, upcasting, TSubclassOf and nullptr conversions. BeginPlay assigns each handle, upcasts a derived actor to its base, and exercises the nullable path by assigning nullptr and then casting back.
 * @topic Casting
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
