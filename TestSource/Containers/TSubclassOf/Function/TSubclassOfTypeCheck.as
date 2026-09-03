/**
 * TSubclassOf.IsChildOf / IsValid / Get / GetDefaultObject answer questions
 * about the held class without mutating it. IsChildOf is the hierarchy
 * query that makes TSubclassOf more than a raw UClass handle: a derived
 * class satisfies a base-class template, and GetDefaultObject exposes the
 * CDO of the held class.
 *
 * @Theme Containers.TSubclassOf
 * @Subject TSubclassOf.IsChildOf
 * @Harness Function
 * @Tag Containers.TSubclassOf.TSubclassOfTypeCheck
 * @Namespace TSubclassOfTest
 */

UCLASS()
class UTSubclassOfTypeCheckBase : UObject
{
}

UCLASS()
class UTSubclassOfTypeCheckDerived : UTSubclassOfTypeCheckBase
{
}

UCLASS()
class UTSubclassOfTypeCheckUnrelated : UObject
{
}

namespace TSubclassOfTest
{
	/**
	 * Observe IsChildOf: a derived class reports as a child of its base.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.IsChildOf
	 * @Inputs TSubclassOf<UObject> set to the derived class
	 * @Return true when IsChildOf(base) is true
	 */
	UFUNCTION()
	bool DerivedIsChildOfBase()
	{
		TSubclassOf<UObject> Class;
		Class = UTSubclassOfTypeCheckDerived::StaticClass();
		return Class.IsChildOf(UTSubclassOfTypeCheckBase::StaticClass());
	}

	/**
	 * Observe IsChildOf is reflexive: a class is a child of itself.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.IsChildOf
	 * @Inputs TSubclassOf<UObject> set to the base class
	 * @Return true when IsChildOf(base) is true for the same class
	 */
	UFUNCTION()
	bool ClassIsChildOfItself()
	{
		TSubclassOf<UObject> Class;
		Class = UTSubclassOfTypeCheckBase::StaticClass();
		return Class.IsChildOf(UTSubclassOfTypeCheckBase::StaticClass());
	}

	/**
	 * Observe IsChildOf is false for an unrelated class.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.IsChildOf
	 * @Inputs TSubclassOf<UObject> set to the unrelated class
	 * @Return true when IsChildOf(base) is false
	 */
	UFUNCTION()
	bool UnrelatedClassIsNotChildOfBase()
	{
		TSubclassOf<UObject> Class;
		Class = UTSubclassOfTypeCheckUnrelated::StaticClass();
		return Class.IsValid()
			&& !Class.IsChildOf(UTSubclassOfTypeCheckBase::StaticClass());
	}

	/**
	 * Observe IsChildOf against nullptr is false rather than throwing.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.IsChildOf
	 * @Inputs TSubclassOf<UObject> set to a class; IsChildOf(nullptr)
	 * @Return true when IsChildOf(nullptr) is false
	 * @Boundary nullptr argument
	 */
	UFUNCTION()
	bool IsChildOfNullptrIsFalse()
	{
		TSubclassOf<UObject> Class;
		Class = UTSubclassOfTypeCheckBase::StaticClass();
		return !Class.IsChildOf(nullptr);
	}

	/**
	 * Observe GetDefaultObject: it returns the CDO of the held class, and the
	 * same CDO is returned on repeated calls.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.GetDefaultObject
	 * @Inputs TSubclassOf<UObject> set to a concrete class
	 * @Return true when GetDefaultObject() is non-null and stable across calls
	 */
	UFUNCTION()
	bool GetDefaultObjectReturnsStableCdo()
	{
		TSubclassOf<UObject> Class;
		Class = UTSubclassOfTypeCheckBase::StaticClass();

		UObject First = Class.GetDefaultObject();
		UObject Second = Class.GetDefaultObject();
		return First != nullptr && First == Second;
	}

	/**
	 * Observe GetDefaultObject against the declared class: the CDO is of the
	 * held class, not of the template parameter.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.GetDefaultObject
	 * @Inputs TSubclassOf<UObject> set to the derived class
	 * @Return true when the CDO is an instance of the derived class
	 */
	UFUNCTION()
	bool GetDefaultObjectIsOfHeldClass()
	{
		TSubclassOf<UObject> Class;
		Class = UTSubclassOfTypeCheckDerived::StaticClass();

		UObject Cdo = Class.GetDefaultObject();
		return Cdo != nullptr && Cast<UTSubclassOfTypeCheckDerived>(Cdo) != nullptr;
	}

	/**
	 * In-only: run the hierarchy query against a const&in TSubclassOf<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.IsChildOf
	 * @Param Value Source received as const TSubclassOf<UObject>&in
	 * @Inputs Value holds the derived class
	 * @Return true when IsChildOf(base) is true
	 */
	UFUNCTION()
	bool ReadHierarchy(const TSubclassOf<UObject>&in Value)
	{
		return Value.IsValid()
			&& Value.IsChildOf(UTSubclassOfTypeCheckBase::StaticClass());
	}

	/**
	 * Out-only: fill an &out with a class that satisfies a base-class query.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.IsChildOf
	 * @Param Result Destination received as TSubclassOf<UObject>&out
	 * @Inputs Empty &out TSubclassOf<UObject>
	 * @Return void; Result holds the derived class
	 */
	UFUNCTION()
	void FillWithDerivedClass(TSubclassOf<UObject>&out Result)
	{
		Result = UTSubclassOfTypeCheckDerived::StaticClass();
	}

	/**
	 * Inout: swap a base class for a derived one, keeping the holder valid
	 * and still a child of the base.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.IsChildOf
	 * @Param Value Received as TSubclassOf<UObject>&inout, starts holding the base class
	 * @Inputs Value.IsValid() is true
	 * @Return void; Value holds the derived class, still a child of the base
	 */
	UFUNCTION()
	void SwapBaseForDerived(TSubclassOf<UObject>&inout Value)
	{
		Value = UTSubclassOfTypeCheckDerived::StaticClass();
	}
}
