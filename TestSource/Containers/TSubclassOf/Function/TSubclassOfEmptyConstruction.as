/**
 * TSubclassOf<T> default-constructs to null: Get() is nullptr, IsValid() is
 * false, and IsChildOf() is false because there is no class to test. The
 * null state is distinct from holding a class, and GetDefaultObject()
 * returns nullptr while null rather than throwing.
 * int-like type suffixes do not apply here; the dimension is the class
 * hierarchy, covered in ../UClass/.
 *
 * @Theme Containers.TSubclassOf
 * @Subject TSubclassOf.Construct
 * @Harness Function
 * @Tag Containers.TSubclassOf.TSubclassOfEmptyConstruction
 * @Namespace TSubclassOfTest
 */

UCLASS()
class UTSubclassOfEmptyConstructionObject : UObject
{
}

namespace TSubclassOfTest
{
	/**
	 * Observe default construction: a fresh TSubclassOf is null and invalid.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.Construct
	 * @Inputs Default-constructed TSubclassOf<UObject>
	 * @Return true when Get() is nullptr and IsValid() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsNull()
	{
		TSubclassOf<UObject> Class;
		return Class.Get() == nullptr && !Class.IsValid();
	}

	/**
	 * Observe that IsChildOf is false while null; there is no class to test.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.IsChildOf
	 * @Inputs Default-constructed TSubclassOf<UObject>; IsChildOf(UObject)
	 * @Return true when IsChildOf() is false
	 */
	UFUNCTION()
	bool NullIsChildOfNothing()
	{
		TSubclassOf<UObject> Class;
		return !Class.IsChildOf(UObject::StaticClass());
	}

	/**
	 * Observe that GetDefaultObject returns nullptr while null, rather than throwing.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.GetDefaultObject
	 * @Inputs Default-constructed TSubclassOf<UObject>
	 * @Return true when GetDefaultObject() is nullptr
	 */
	UFUNCTION()
	bool NullGetDefaultObjectIsNull()
	{
		TSubclassOf<UObject> Class;
		return Class.GetDefaultObject() == nullptr;
	}

	/**
	 * Observe copy independence: constructing two TSubclassOf and setting only
	 * the first leaves the second null.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.Construct
	 * @Inputs Two default-constructed TSubclassOf<UObject>; set the first
	 * @Return true when the first is valid and the second is still null
	 */
	UFUNCTION()
	bool DefaultConstructionCopyIndependence()
	{
		TSubclassOf<UObject> First;
		TSubclassOf<UObject> Second;
		First = UTSubclassOfEmptyConstructionObject::StaticClass();
		return First.IsValid() && !Second.IsValid();
	}

	/**
	 * In-only: read the state of a const&in TSubclassOf<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.Construct
	 * @Param Value Source received as const TSubclassOf<UObject>&in
	 * @Inputs Value is default-constructed and therefore null
	 * @Return true when Get() is nullptr and IsValid() is false
	 */
	UFUNCTION()
	bool ReadDefaultConstructed(const TSubclassOf<UObject>&in Value)
	{
		return Value.Get() == nullptr && !Value.IsValid();
	}

	/**
	 * Out-only: leave an &out TSubclassOf<UObject> in its default null state.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.Construct
	 * @Param Result Destination received as TSubclassOf<UObject>&out
	 * @Inputs Empty &out TSubclassOf<UObject>
	 * @Return void; Result stays null
	 */
	UFUNCTION()
	void LeaveDefaultConstructed(TSubclassOf<UObject>&out Result)
	{
		Result = TSubclassOf<UObject>();
	}

	/**
	 * Inout: reset a TSubclassOf<UObject> back to the default null state.
	 *
	 * @Kind RoundTrip
	 * @Covers TSubclassOf.Construct
	 * @Param Value Received as TSubclassOf<UObject>&inout, starts set
	 * @Inputs Value.IsValid() is true
	 * @Return void; Value is null again
	 */
	UFUNCTION()
	void ResetToDefaultState(TSubclassOf<UObject>&inout Value)
	{
		Value = TSubclassOf<UObject>();
	}
}
