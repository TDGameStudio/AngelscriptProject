/**
 * @version v1
 * @summary Object casting and type checks on generated actors: Cast<T> between a base and a derived script class, IsA, IsChildOf, and GetClass. A downcast to a type the object is not yields null rather than throwing, which is what.
 * @topic Language
 */
/**
 * @version root
 * @summary Object casting and type checks on generated actors: Cast<T> between a base and a derived script class, IsA, IsChildOf, and GetClass. A downcast to a type the object is not yields null rather than throwing, which is what.
 * @topic Baseline
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
