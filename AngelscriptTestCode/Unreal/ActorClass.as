/**
 * @version v1
 * @summary UCLASS actor declaration, inheritance, this, override, and super.
 * @topic Unreal
 * @topic ActorClass
 *
 * operator-state-on-actor
 * abstract-u-class-with-concrete-child
 * actor-members-with-initializers
 * actor-methods-compiling
 * actor-without-prefix-naming
 * class-like-method-execution-round-trip
 * empty-actor-subclass
 * final-actor-subclass
 * multiple-comma-separated-bases
 * script-constructor-assigns-member
 * two-level-inheritance-chain
 * u-object-flag-mutation-and-transient-state
 * u-object-outer-chain-and-path-matrix
 * final-class-modifier
 * super-call-in-blueprint-override
 */
/**
 * @begin operator-state-on-actor
 * @summary Operators applied to state held on a script actor, so the results survive across method calls and C++ can read them by path. The actor accumulates a score through compound assignment, guards a threshold with a.
 * @topic ActorClass
 */
UCLASS()
class ACoverageOperatorStateActor : AActor
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	bool bAboveThreshold = false;

	UPROPERTY()
	int CapabilityMask = 0;

	UPROPERTY()
	bool bHasCapability = false;

	UPROPERTY()
	int GrowthCount = 0;

	/**
	 * Add to the score and count how many times it has grown, using compound
	 * assignment against object state.
	 *
	 * @Covers Operators.Assignment
	 * @Param Amount Added onto the score
	 * @Inputs A positive or negative amount
	 * @Return the score after the addition
	 */
	UFUNCTION()
	int AddScore(int Amount)
	{
		Score += Amount;
		GrowthCount += 1;
		return Score;
	}

	/**
	 * Compare the score against a threshold and record the outcome.
	 *
	 * @Covers Operators.Comparison
	 * @Param Threshold Compared against the current score
	 * @Inputs Any threshold
	 * @Return true when the score is at or above the threshold
	 */
	UFUNCTION()
	bool CheckThreshold(int Threshold)
	{
		bAboveThreshold = (Score >= Threshold);
		return bAboveThreshold;
	}

	/**
	 * Grant one capability by or-ing it into the mask.
	 *
	 * @Covers Operators.Bitwise
	 * @Param Capability The bit to grant
	 * @Inputs A single capability bit
	 * @Return true when the capability is held afterwards
	 */
	UFUNCTION()
	bool GrantCapability(int Capability)
	{
		CapabilityMask |= Capability;
		bHasCapability = ((CapabilityMask & Capability) == Capability);
		return bHasCapability;
	}

	/**
	 * Clear one capability by and-ing it out of the mask.
	 *
	 * @Covers Operators.Bitwise
	 * @Param Capability The bit to clear
	 * @Inputs A single capability bit, held or absent
	 * @Return true when the capability is gone afterwards
	 */
	UFUNCTION()
	bool RevokeCapability(int Capability)
	{
		CapabilityMask &= ~Capability;
		bHasCapability = ((CapabilityMask & Capability) == Capability);
		return !bHasCapability;
	}
}

namespace OperatorsTest
{
	const int Cap_Dash  = 0x01;
	const int Cap_Jump  = 0x02;
	const int Cap_Fly   = 0x04;

	/**
	 * Observe compound assignment against object state: repeated additions
	 * accumulate, and the growth counter tracks them.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Assignment
	 * @Inputs Spawn the actor, add three times, then read score and count
	 * @Return true when the score is 60 and the count is 3
	 */
	UFUNCTION()
	bool CompoundAssignmentAccumulatesOnObject()
	{
		ACoverageOperatorStateActor Actor = SpawnActor(ACoverageOperatorStateActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}

		Actor.AddScore(10);
		Actor.AddScore(20);
		int Final = Actor.AddScore(30);
		if (Final != 60)
		{
			Actor.DestroyActor();
			return false;
		}
		if (Actor.Score != 60)
		{
			Actor.DestroyActor();
			return false;
		}

		bool bOk = (Actor.GrowthCount == 3);
		Actor.DestroyActor();
		return bOk;
	}

	/**
	 * Observe comparison against a threshold, in both directions.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the actor, add 25, then check thresholds of 20 and 30
	 * @Return true when the first passes and the second does not
	 */
	UFUNCTION()
	bool ThresholdComparisonHoldsBothWays()
	{
		ACoverageOperatorStateActor Actor = SpawnActor(ACoverageOperatorStateActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}

		Actor.AddScore(25);
		bool bPassed = Actor.CheckThreshold(20);
		bool bFailed = Actor.CheckThreshold(30);
		if (!bPassed)
		{
			Actor.DestroyActor();
			return false;
		}
		if (bFailed)
		{
			Actor.DestroyActor();
			return false;
		}

		bool bOk = Actor.bAboveThreshold == false;
		Actor.DestroyActor();
		return bOk;
	}

	/**
	 * Observe the bitwise capability protocol against object state: granting
	 * two capabilities leaves both held, and revoking one leaves the other.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Bitwise
	 * @Inputs Spawn the actor, grant dash and fly, then revoke dash
	 * @Return true when fly survives and dash is gone
	 */
	UFUNCTION()
	bool CapabilityMaskSurvivesRevocation()
	{
		ACoverageOperatorStateActor Actor = SpawnActor(ACoverageOperatorStateActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}

		Actor.GrantCapability(Cap_Dash);
		Actor.GrantCapability(Cap_Fly);
		if (Actor.CapabilityMask != (Cap_Dash | Cap_Fly))
		{
			Actor.DestroyActor();
			return false;
		}

		bool bRevoked = Actor.RevokeCapability(Cap_Dash);
		if (!bRevoked)
		{
			Actor.DestroyActor();
			return false;
		}
		if (Actor.CapabilityMask != Cap_Fly)
		{
			Actor.DestroyActor();
			return false;
		}

		bool bOk = (Actor.CapabilityMask & Cap_Dash) == 0;
		Actor.DestroyActor();
		return bOk;
	}

	/**
	 * Observe the default boundary: a freshly spawned actor starts at zero
	 * score and with no capabilities.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Assignment
	 * @Inputs Spawn the actor and read its initial state
	 * @Return true when the score, count, and mask are all zero
	 * @Boundary freshly spawned defaults
	 */
	UFUNCTION()
	bool SpawnedActorStartsAtZeroState()
	{
		ACoverageOperatorStateActor Actor = SpawnActor(ACoverageOperatorStateActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}

		if (Actor.Score != 0)
		{
			Actor.DestroyActor();
			return false;
		}
		if (Actor.GrowthCount != 0)
		{
			Actor.DestroyActor();
			return false;
		}

		bool bOk = (Actor.CapabilityMask == 0);
		Actor.DestroyActor();
		return bOk;
	}
}
/** @end */
/**
 * @begin abstract-u-class-with-concrete-child
 * @summary An Abstract UCLASS paired with a concrete child. The abstract type is declared but not instantiated; the child carries a member that starts at zero and accepts writes.
 * @topic ActorClass
 */
UCLASS(Abstract)
class AMyAbstract : AActor
{
}

UCLASS()
class AMyAbstractConcrete : AMyAbstract
{
	int EmptyFlag = 0;

	/**
	 * Observe the child's initialized member default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed child
	 * @Return the EmptyFlag value
	 */
	UFUNCTION()
	int ConcreteChildDefaultFlag()
	{
		return EmptyFlag;
	}

	/**
	 * Observe that a write lands on the child's member.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EmptyFlag set to 1
	 * @Return the EmptyFlag value
	 * @Boundary non-zero write
	 */
	UFUNCTION()
	int ConcreteChildFlagWriteBoundary()
	{
		EmptyFlag = 1;
		return EmptyFlag;
	}

	/**
	 * Observe that an unset abstract handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AMyAbstract handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int AbstractHandleDefaultsToNull()
	{
		AMyAbstract Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
/**
 * @begin actor-members-with-initializers
 * @summary An AActor subclass whose members carry initializers: an int set to 100 and a float set to 5. The observers read both defaults, push the int to its empty boundary, and show that writing one instance does not write.
 * @topic ActorClass
 */
class AClassMembersActor : AActor
{
	int Health = 100;
	float Speed = 5.0f;

	/**
	 * Observe the initialized integer default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the Health value
	 */
	UFUNCTION()
	int MemberDefaultHealth()
	{
		return Health;
	}

	/**
	 * Observe the initialized float default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the Speed value
	 */
	UFUNCTION()
	float MemberDefaultSpeed()
	{
		return Speed;
	}

	/**
	 * Observe the zero boundary of the integer member.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Health set to 0
	 * @Return the Health value
	 * @Boundary zero value
	 */
	UFUNCTION()
	int MemberHealthZeroBoundary()
	{
		Health = 0;
		return Health;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds 1 and the other holds 100
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool MemberHealthIsIndependentAcrossInstances()
	{
		AClassMembersActor Other;
		Health = 1;
		Other.Health = 100;

		if (Health != 1)
		{
			return false;
		}

		return Other.Health == 100;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassMembersActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int MemberActorDefaultsToNull()
	{
		AClassMembersActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
/**
 * @begin actor-methods-compiling
 * @summary An AActor subclass carrying both an empty void method and one that returns a value. Both bodies must complete, and the return value must survive an interleaved call to the empty method.
 * @topic ActorClass
 */
class AClassMethodsActor : AActor
{
	/**
	 * An empty method whose only job is to complete.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	void Foo()
	{
	}

	/**
	 * A method returning a constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 1
	 */
	int Bar()
	{
		return 1;
	}

	/**
	 * Observe that the value-returning method reports 1.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Bar()
	 * @Return 1
	 */
	UFUNCTION()
	int MethodBarNominal()
	{
		return Bar();
	}

	/**
	 * Observe that the empty method completes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Foo()
	 * @Return 0 once the call completes
	 */
	UFUNCTION()
	int MethodFooEmptyCompletes()
	{
		Foo();
		return 0;
	}

	/**
	 * Observe that calling the empty method first does not corrupt Bar.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Foo() then Bar()
	 * @Return 1
	 * @Boundary interleaved call
	 */
	UFUNCTION()
	int MethodFooThenBarBoundary()
	{
		Foo();
		return Bar();
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassMethodsActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int MethodActorDefaultsToNull()
	{
		AClassMethodsActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
/**
 * @begin actor-without-prefix-naming
 * @summary An actor subclass declared without the A prefix. C++ originally expected the naming convention to be enforced, but the live C++ wraps this in #if 0: the class compiles, so the CSV NegativeDiagnostic is not a.
 * @topic ActorClass
 */
class MyActor : AActor
{
	/**
	 * Observe that the unprefixed class is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed MyActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int UnprefixedActorIsAnActor()
	{
		MyActor Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset MyActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int UnprefixedActorDefaultsToNull()
	{
		MyActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool UnprefixedActorAssignAliases()
	{
		MyActor First;
		MyActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
/**
 * @begin class-like-method-execution-round-trip
 * @summary Class-like values — a plain UClass, a TSubclassOf and a TSoftClassPtr — passed through UFUNCTION signatures and back. Each echo must return the same value it was given, including the null and empty cases.
 * @topic ActorClass
 */
UCLASS()
class UCompilerClassLikeExecutionCarrier : UObject
{
	/**
	 * Echoes a plain UClass value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a UClass
	 * @Return the same UClass
	 * @Param Value the class to echo
	 */
	UFUNCTION()
	UClass EchoPlainClass(UClass Value)
	{
		return Value;
	}

	/**
	 * Echoes a TSubclassOf value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a TSubclassOf<AActor>
	 * @Return the same TSubclassOf
	 * @Param Value the subclass to echo
	 */
	UFUNCTION()
	TSubclassOf<AActor> EchoActorClass(TSubclassOf<AActor> Value)
	{
		return Value;
	}

	/**
	 * Echoes a TSoftClassPtr value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a TSoftClassPtr<AActor>
	 * @Return the same TSoftClassPtr
	 * @Param Value the soft class pointer to echo
	 */
	UFUNCTION()
	TSoftClassPtr<AActor> EchoSoftActorClass(TSoftClassPtr<AActor> Value)
	{
		return Value;
	}

	/**
	 * Verifies all three echoes in sequence.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 1 on success, otherwise 10, 20 or 30 naming the failing echo
	 */
	UFUNCTION()
	int VerifyRoundTrip()
	{
		if (!(EchoPlainClass(AActor::StaticClass()) == AActor::StaticClass()))
			return 10;

		if (!(EchoActorClass(ACameraActor::StaticClass()) == ACameraActor::StaticClass()))
			return 20;

		TSoftClassPtr<AActor> SoftActorClass = TSoftClassPtr<AActor>(AActor::StaticClass());
		if (!(EchoSoftActorClass(SoftActorClass).Get() == AActor::StaticClass()))
			return 30;

		return 1;
	}

	/**
	 * Observe that the full round-trip verification passes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs VerifyRoundTrip()
	 * @Return true when the result is 1
	 */
	UFUNCTION()
	bool ClassLikeVerifyRoundTripSucceeds()
	{
		return VerifyRoundTrip() == 1;
	}

	/**
	 * Observe that echoing a null class stays null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoPlainClass(nullptr)
	 * @Return true when the result is null
	 * @Boundary null class
	 */
	UFUNCTION()
	bool ClassLikePlainNullStaysNull()
	{
		return EchoPlainClass(nullptr) == nullptr;
	}

	/**
	 * Observe that an empty TSubclassOf echoes back empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoActorClass over an empty TSubclassOf
	 * @Return true when the empty value survives
	 * @Boundary empty subclass
	 */
	UFUNCTION()
	bool ClassLikeActorEmptyStaysEmpty()
	{
		TSubclassOf<AActor> Empty;
		return EchoActorClass(Empty) == Empty;
	}

	/**
	 * Observe that a real TSubclassOf echoes back unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoActorClass over the camera actor class
	 * @Return true when the class identity is preserved
	 */
	UFUNCTION()
	bool ClassLikeActorIdentityPreserved()
	{
		return EchoActorClass(ACameraActor::StaticClass()) == ACameraActor::StaticClass();
	}
}
/** @end */
/**
 * @begin empty-actor-subclass
 * @summary An empty AActor subclass. The class must compile and behave as an AActor, with its handle null until assigned.
 * @topic ActorClass
 */
class AClassBasicActor : AActor
{
	/**
	 * Observe that the empty subclass is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AClassBasicActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int EmptySubclassIsAnActor()
	{
		AClassBasicActor Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassBasicActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptySubclassDefaultsToNull()
	{
		AClassBasicActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool EmptySubclassAssignAliases()
	{
		AClassBasicActor First;
		AClassBasicActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
/**
 * @begin final-actor-subclass
 * @summary A final AActor subclass. The modifier must yield a valid type whose handle is null until assigned and aliases correctly when copied.
 * @topic ActorClass
 */
class AFinalClassActor : AActor final
{
	/**
	 * Observe that the final class is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AFinalClassActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int FinalActorIsAnActor()
	{
		AFinalClassActor Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AFinalClassActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int FinalActorDefaultsToNull()
	{
		AFinalClassActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool FinalActorAssignAliases()
	{
		AFinalClassActor First;
		AFinalClassActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
/**
 * @begin multiple-comma-separated-bases
 * @summary A class declaring two comma-separated base classes. C++ originally expected multi-base inheritance to be rejected, but the live C++ wraps this in #if 0 because structural validation is absent: the class compiles. The.
 * @topic ActorClass
 */
class AClassMultiBaseActor : AActor, APawn
{
	/**
	 * Observe that the multi-base class is still an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AClassMultiBaseActor handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int MultiBaseActorIsAnActor()
	{
		AClassMultiBaseActor Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassMultiBaseActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int MultiBaseActorDefaultsToNull()
	{
		AClassMultiBaseActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool MultiBaseActorAssignAliases()
	{
		AClassMultiBaseActor First;
		AClassMultiBaseActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
/**
 * @begin script-constructor-assigns-member
 * @summary A script-level constructor that assigns a member. The constructor must run at construction time, so the member is neither left at zero nor clobbered by a later write.
 * @topic ActorClass
 */
class AClassCtorActor : AActor
{
	int X;

	/**
	 * Initializes the member at construction time.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return a new AClassCtorActor with X set to 10
	 */
	AClassCtorActor()
	{
		X = 10;
	}

	/**
	 * Observe the value the constructor stored.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the X value
	 */
	UFUNCTION()
	int ConstructorStoredValue()
	{
		return X;
	}

	/**
	 * Observe that the member was not left at the zero default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the X value, or 0 if it is still zero
	 * @Boundary non-zero after construction
	 */
	UFUNCTION()
	int ConstructorNotLeftAtZero()
	{
		if (X == 0)
		{
			return 0;
		}
		return X;
	}

	/**
	 * Observe that a later write replaces the constructed value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs X set to 1 after construction
	 * @Return the X value
	 * @Boundary post-construction write
	 */
	UFUNCTION()
	int ConstructorWriteAfterConstruct()
	{
		X = 1;
		return X;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassCtorActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int ConstructorActorDefaultsToNull()
	{
		AClassCtorActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
/**
 * @begin two-level-inheritance-chain
 * @summary A two-level inheritance chain. A child handle must upcast to its base, stay null until assigned, and alias correctly when copied.
 * @topic ActorClass
 */
class ABaseChainActor : AActor
{
}

class AChildChainActor : ABaseChainActor
{
	/**
	 * Observe that a child handle upcasts to the base type.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a child handle assigned to a base handle
	 * @Return 1 when the base handle is an ABaseChainActor, otherwise 0
	 */
	UFUNCTION()
	int ChainChildUpcastsToBase()
	{
		AChildChainActor Child;
		ABaseChainActor Base = Child;
		if (Base is ABaseChainActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset child handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AChildChainActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int ChainChildDefaultsToNull()
	{
		AChildChainActor Child;
		if (Child is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool ChainChildAssignAliases()
	{
		AChildChainActor First;
		AChildChainActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
/**
 * @begin u-object-flag-mutation-and-transient-state
 * @summary UObject flag mutation: NewObject's transient flag, SetTransactional turning a flag on, and setting the same flag on and then off again.
 * @topic ActorClass
 */
UCLASS()
class ACoverageHandleUObjectFlagsActor : AActor
{
	UPROPERTY()
	UObject TransientObject;

	UPROPERTY()
	UObject TransactionalObject;

	UPROPERTY()
	UObject ClearedTransactionalObject;

	UPROPERTY()
	bool ScriptTransientMatched = false;

	/**
	 * Creates the three objects with their flag configurations.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the handles and flag record the outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TransientObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageHandleTransientObject", true);
		ScriptTransientMatched = TransientObject != nullptr && TransientObject.IsTransient();

		TransactionalObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageHandleTransactionalObject");
		TransactionalObject.SetTransactional(true);

		ClearedTransactionalObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageHandleClearedTransactionalObject");
		ClearedTransactionalObject.SetTransactional(true);
		ClearedTransactionalObject.SetTransactional(false);
	}

	/**
	 * Observe that a locally constructed actor holds no objects.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three handles are null and the flag is false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool UObjectFlagsDefaultEmpty()
	{
		if (TransientObject != nullptr)
		{
			return false;
		}

		if (TransactionalObject != nullptr)
		{
			return false;
		}

		if (ClearedTransactionalObject != nullptr)
		{
			return false;
		}

		return !ScriptTransientMatched;
	}
}
/** @end */
/**
 * @begin u-object-outer-chain-and-path-matrix
 * @summary A three-level NewObject outer chain with its path matrix: each object's outer is its parent, the outermost is the transient package, the depth is two, and the name path spells out all three names.
 * @topic ActorClass
 */
UCLASS()
class ACoverageHandleUObjectOuterChainActor : AActor
{
	UPROPERTY()
	UObject ChainRoot;

	UPROPERTY()
	UObject ChainChild;

	UPROPERTY()
	UObject ChainLeaf;

	UPROPERTY()
	bool ChainOutersMatched = false;

	UPROPERTY()
	bool ChainOutermostMatched = false;

	UPROPERTY()
	bool ChainPathContainsNames = false;

	UPROPERTY()
	int ChainDepth = 0;

	UPROPERTY()
	FString ChainNamePath = "";

	/**
	 * Counts an object's outer chain depth, stopping at the package.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the object to measure
	 * @Return the number of non-package outers
	 * @Param Obj the object whose chain is counted
	 */
	int CountOuterDepth(UObject Obj)
	{
		int Depth = 0;
		UObject Current = Obj;
		for (int Step = 0; Step < 20; ++Step)
		{
			UObject Outer = Current.GetOuter();
			if (Outer == nullptr)
			{
				break;
			}
			if (Outer.IsA(UPackage::StaticClass()))
			{
				break;
			}
			Depth++;
			Current = Outer;
		}
		return Depth;
	}

	/**
	 * Collects an object's name and its outer names joined by '>'.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the object to name
	 * @Return the chain names joined by '>'
	 * @Param Obj the object whose chain is named
	 */
	FString CollectChainNames(UObject Obj)
	{
		FString Result = Obj.GetName().ToString();
		UObject Current = Obj;
		for (int Step = 0; Step < 20; ++Step)
		{
			UObject Outer = Current.GetOuter();
			if (Outer == nullptr)
			{
				break;
			}
			if (Outer.IsA(UPackage::StaticClass()))
			{
				break;
			}
			Result += ">" + Outer.GetName().ToString();
			Current = Outer;
		}
		return Result;
	}

	/**
	 * Builds the chain and records the outer, depth and path matrix.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the properties record each measurement
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ChainRoot = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageHandleChainRoot");
		ChainChild = NewObject(ChainRoot, UTexture2D::StaticClass(), n"CoverageHandleChainChild");
		ChainLeaf = NewObject(ChainChild, UTexture2D::StaticClass(), n"CoverageHandleChainLeaf");

		ChainOutersMatched =
			ChainRoot.GetOuter() == GetTransientPackage() &&
			ChainChild.GetOuter() == ChainRoot &&
			ChainLeaf.GetOuter() == ChainChild;
		ChainOutermostMatched = ChainLeaf.GetOutermost() == GetTransientPackage();
		ChainDepth = CountOuterDepth(ChainLeaf);
		ChainNamePath = CollectChainNames(ChainLeaf);

		FString LeafPath = ChainLeaf.GetPathName();
		ChainPathContainsNames =
			LeafPath.Contains("CoverageHandleChainRoot") &&
			LeafPath.Contains("CoverageHandleChainChild") &&
			LeafPath.Contains("CoverageHandleChainLeaf");
	}

	/**
	 * Observe that a locally constructed actor holds no chain.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the objects are null, flags false, depth 0 and path empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool UObjectOuterChainDefaultEmpty()
	{
		if (ChainRoot != nullptr)
		{
			return false;
		}

		if (ChainChild != nullptr)
		{
			return false;
		}

		if (ChainLeaf != nullptr)
		{
			return false;
		}

		if (ChainOutersMatched)
		{
			return false;
		}

		if (ChainDepth != 0)
		{
			return false;
		}

		return ChainNamePath.Len() == 0;
	}
}
/** @end */
/**
 * @begin final-class-modifier
 * @summary The final class modifier applied to an actor subclass. The modifier must produce a valid type without preventing the class from being used as an actor.
 * @topic ActorClass
 */
class AFinalActorMisc : AActor final
{
	/**
	 * Observe that the final class is still usable as an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs a default-constructed AFinalActorMisc handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int FinalClassHandleIsAnActor()
	{
		AFinalActorMisc Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs an unset AFinalActorMisc handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int FinalClassHandleDefaultsToNull()
	{
		AFinalActorMisc Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool FinalClassHandleAssignAliases()
	{
		AFinalActorMisc First;
		AFinalActorMisc Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
/**
 * @begin super-call-in-blueprint-override
 * @summary A Super:: call made from inside a BlueprintOverride. C++ currently wraps this AssertCompiles in #if 0 because of how Super:: interacts with BlueprintOverride, but the source itself is the positive fixture.
 * @topic ActorClass
 */
class AActorSuper : AActor
{
	/**
	 * Chains to the parent implementation through Super::.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
	}

	/**
	 * Observe that the handle typed as this class is usable as an AActor.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs a default-constructed AActorSuper handle
	 * @Return 1 when the value is an AActor, otherwise 0
	 */
	UFUNCTION()
	int SuperHandleIsAnActor()
	{
		AActorSuper Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs an unset AActorSuper handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int SuperHandleDefaultsToNull()
	{
		AActorSuper Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool SuperHandleAssignAliases()
	{
		AActorSuper First;
		AActorSuper Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
