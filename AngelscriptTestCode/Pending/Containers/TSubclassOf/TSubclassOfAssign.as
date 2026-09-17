/**
 * @version v1
 * @summary TSubclassOf.Set / opAssign binds a UClass. The class must be a child of the templated class; a mismatch throws, so that path lives in ../Exception/, not here. A matching class makes the holder valid, and the holder then.
 * @topic Containers
 */
/**
 * @version root
 * @summary TSubclassOf.Set / opAssign binds a UClass. The class must be a child of the templated class; a mismatch throws, so that path lives in ../Exception/, not here. A matching class makes the holder valid, and the holder then.
 * @topic Baseline
 */
UCLASS()
class UTSubclassOfAssignObject : UObject
{
}

UCLASS()
class UTSubclassOfAssignDerived : UTSubclassOfAssignObject
{
}

namespace TSubclassOfTest
{
	/**
	 * Observe opAssign from a UClass: the holder becomes valid and Get()
	 * returns that class back.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.opAssign
	 * @Inputs Default-constructed TSubclassOf<UObject>; assign a UClass
	 * @Return true when IsValid() is true and Get() is that class
	 */
	UFUNCTION()
	bool AssignClassMakesValid()
	{
		TSubclassOf<UObject> Class;
		if (Class.IsValid())
		{
			return false;
		}

		UClass Expected = UTSubclassOfAssignObject::StaticClass();
		Class = Expected;
		return Class.IsValid() && Class.Get() == Expected;
	}

	/**
	 * Observe that a derived class satisfies a base-class template parameter:
	 * TSubclassOf<UObject> accepts a class derived from UObject.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.opAssign
	 * @Inputs Default-constructed TSubclassOf<UObject>; assign a derived class
	 * @Return true when the holder is valid and holds the derived class
	 */
	UFUNCTION()
	bool AssignDerivedClassIntoBaseHolder()
	{
		TSubclassOf<UObject> Class;
		UClass Derived = UTSubclassOfAssignDerived::StaticClass();
		Class = Derived;
		return Class.IsValid() && Class.Get() == Derived;
	}

	/**
	 * Observe Set: it is the explicit write path and behaves like opAssign.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.Set
	 * @Inputs Default-constructed TSubclassOf<UObject>; Set(a UClass)
	 * @Return true when IsValid() is true and Get() is that class
	 */
	UFUNCTION()
	bool SetStoresClass()
	{
		TSubclassOf<UObject> Class;
		UClass Expected = UTSubclassOfAssignObject::StaticClass();
		Class.Set(Expected);
		return Class.IsValid() && Class.Get() == Expected;
	}

	/**
	 * Observe that assigning nullptr clears the holder back to invalid.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.opAssign
	 * @Inputs Holder set to a class; assign nullptr
	 * @Return true when IsValid() is false and Get() is nullptr
	 */
	UFUNCTION()
	bool AssignNullptrClearsHolder()
	{
		TSubclassOf<UObject> Class;
		Class = UTSubclassOfAssignObject::StaticClass();
		if (!Class.IsValid())
		{
			return false;
		}

		Class = nullptr;
		return !Class.IsValid() && Class.Get() == nullptr;
	}

	/**
	 * Observe implicit conversion: a valid holder converts back to UClass and
	 * compares equal against the class it was set from.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.opImplConv
	 * @Inputs Holder set to a class; compare against that class
	 * @Return true when the holder equals the original UClass
	 */
	UFUNCTION()
	bool ImplicitConversionReturnsClass()
	{
		TSubclassOf<UObject> Class;
		UClass Expected = UTSubclassOfAssignObject::StaticClass();
		Class = Expected;
		return Class == Expected;
	}

	/**
	 * Observe opAssign from another holder: the class is copied and the two
	 * holders then compare equal, and stay independent afterwards.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.opAssign
	 * @Inputs Source holder set to a class; assign onto a default target; then reassign the source
	 * @Return true when the copy holds the original class after the source changes
	 */
	UFUNCTION()
	bool AssignHolderCopiesClassAndStaysIndependent()
	{
		TSubclassOf<UObject> Source;
		UClass First = UTSubclassOfAssignObject::StaticClass();
		UClass Second = UTSubclassOfAssignDerived::StaticClass();
		if (First == Second)
		{
			return false;
		}

		Source = First;
		TSubclassOf<UObject> Dest;
		Dest = Source;
		if (!Dest.IsValid() || Dest.Get() != First || Dest != Source)
		{
			return false;
		}

		Source = Second;
		return Dest.Get() == First && Source.Get() == Second && Dest != Source;
	}

	/**
	 * In-only: read the class out of a const&in TSubclassOf<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.opAssign
	 * @Param Value Source received as const TSubclassOf<UObject>&in
	 * @Inputs Value holds a valid class
	 * @Return true when IsValid() is true and Get() is non-null
	 */
	UFUNCTION()
	bool ReadAssignedClass(const TSubclassOf<UObject>&in Value)
	{
		return Value.IsValid() && Value.Get() != nullptr;
	}

	/**
	 * Out-only: fill an empty &out TSubclassOf<UObject> with a class.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.opAssign
	 * @Param Result Destination received as TSubclassOf<UObject>&out
	 * @Inputs Empty &out TSubclassOf<UObject>
	 * @Return void; Result holds a valid class
	 */
	UFUNCTION()
	void FillWithClass(TSubclassOf<UObject>&out Result)
	{
		Result = UTSubclassOfAssignObject::StaticClass();
	}

	/**
	 * Inout: replace the class of an already-set TSubclassOf<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.opAssign
	 * @Param Value Received as TSubclassOf<UObject>&inout, starts set
	 * @Inputs Value.IsValid() is true
	 * @Return void; Value holds a different valid class
	 */
	UFUNCTION()
	void ReplaceClass(TSubclassOf<UObject>&inout Value)
	{
		Value = UTSubclassOfAssignDerived::StaticClass();
	}
}
/** @end */
