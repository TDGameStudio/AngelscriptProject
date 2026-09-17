/**
 * @version v1
 * @summary Composite positive: multi-step TSubclassOf lifecycles that the single-API Function entries do not cover on their own — repeated set/clear cycles, handing a class holder across UFUNCTION boundaries, and using one holder.
 * @topic Containers
 */
/**
 * @version root
 * @summary Composite positive: multi-step TSubclassOf lifecycles that the single-API Function entries do not cover on their own — repeated set/clear cycles, handing a class holder across UFUNCTION boundaries, and using one holder.
 * @topic Baseline
 */
UCLASS()
class UTSubclassOfSequenceBase : UObject
{
}

UCLASS()
class UTSubclassOfSequenceDerived : UTSubclassOfSequenceBase
{
}

namespace TSubclassOfTest
{
	/**
	 * Repeated set/clear cycles keep the holder usable and the state correct.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.opAssign
	 * @Inputs One holder cycled through set, clear, set, clear, set
	 * @Return true when the final state is valid and holds the base class
	 */
	UFUNCTION()
	bool RepeatedSetClearCyclesKeepStateCorrect()
	{
		UClass Base = UTSubclassOfSequenceBase::StaticClass();
		UClass Derived = UTSubclassOfSequenceDerived::StaticClass();

		TSubclassOf<UObject> Class;

		Class = Base;
		if (!Class.IsValid() || Class.Get() != Base)
		{
			return false;
		}

		Class = nullptr;
		if (Class.IsValid())
		{
			return false;
		}

		Class = Derived;
		if (!Class.IsValid() || Class.Get() != Derived)
		{
			return false;
		}

		Class = nullptr;
		if (Class.IsValid())
		{
			return false;
		}

		Class = Base;
		return Class.IsValid() && Class.Get() == Base;
	}

	/**
	 * "Configured factory" slot: reassigning replaces the previous class, and
	 * the holder can then be used to produce an instance of the configured class.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.GetDefaultObject
	 * @Inputs One holder assigned Derived, then used as a factory argument
	 * @Return true when the produced object is an instance of the configured class
	 */
	UFUNCTION()
	bool LatestAssignConfiguresFactory()
	{
		TSubclassOf<UObject> Class;
		Class = UTSubclassOfSequenceBase::StaticClass();
		Class = UTSubclassOfSequenceDerived::StaticClass();
		if (Class.Get() != UTSubclassOfSequenceDerived::StaticClass())
		{
			return false;
		}

		UObject Produced = NewObject(GetTransientPackage(), Class, n"TSubclassSeq_Produced", true);
		return Produced != nullptr
			&& Cast<UTSubclassOfSequenceDerived>(Produced) != nullptr;
	}

	/**
	 * Hand a class holder across a UFUNCTION boundary and query its hierarchy
	 * on the receiving side.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.IsChildOf
	 * @Param Value Holder received as const TSubclassOf<UObject>&in
	 * @Inputs Value holds the derived class
	 * @Return true when the holder is a child of the base class
	 */
	UFUNCTION()
	bool ReadAndQueryHierarchy(const TSubclassOf<UObject>&in Value)
	{
		return Value.IsValid()
			&& Value.IsChildOf(UTSubclassOfSequenceBase::StaticClass());
	}

	/**
	 * Out-only: publish a class through an &out holder so the caller can
	 * query and use it.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.opAssign
	 * @Param Result Destination received as TSubclassOf<UObject>&out
	 * @Inputs Empty &out TSubclassOf<UObject>
	 * @Return void; Result holds the derived class
	 */
	UFUNCTION()
	void PublishDerivedClass(TSubclassOf<UObject>&out Result)
	{
		Result = UTSubclassOfSequenceDerived::StaticClass();
	}

	/**
	 * Inout: narrow a holder from the base class to the derived class,
	 * keeping it valid and still a child of the base.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.IsChildOf
	 * @Param Value Holder received as TSubclassOf<UObject>&inout, starts holding the base class
	 * @Inputs Value.IsValid() is true
	 * @Return void; Value holds the derived class, still a child of the base
	 */
	UFUNCTION()
	void NarrowToDerivedClass(TSubclassOf<UObject>&inout Value)
	{
		Value = UTSubclassOfSequenceDerived::StaticClass();
	}
}
/** @end */
