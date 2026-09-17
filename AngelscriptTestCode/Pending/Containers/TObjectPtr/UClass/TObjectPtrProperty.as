/**
 * @version v1
 * @summary TObjectPtr<T> as a UPROPERTY on a script UCLASS. The property starts null and is per-instance, and it is the shape a strong object reference takes inside a script class. Unlike a weak pointer, an object pointer property.
 * @topic Containers
 */
/**
 * @version root
 * @summary TObjectPtr<T> as a UPROPERTY on a script UCLASS. The property starts null and is per-instance, and it is the shape a strong object reference takes inside a script class. Unlike a weak pointer, an object pointer property.
 * @topic Baseline
 */
UCLASS()
class UTObjectPtrPropertyObject : UObject
{
}

UCLASS()
class UTObjectPtrPropertyHolder : UObject
{
	UPROPERTY()
	TObjectPtr<UObject> ObjectRef;

	UPROPERTY()
	TObjectPtr<UTObjectPtrPropertyObject> TypedRef;

	UPROPERTY()
	TObjectPtr<AActor> ActorRef;
}

namespace TObjectPtrTest
{
	/**
	 * Observe that object pointer UPROPERTYs start null on a fresh instance.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.Construct
	 * @Inputs NewObject of the holder class
	 * @Return true when all three properties are null
	 */
	UFUNCTION()
	bool ObjectPropertiesStartNull()
	{
		UTObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTObjectPtrPropertyHolder::StaticClass(), n"TObjPtrProp_Unset", true);
		if (Holder == nullptr)
		{
			return false;
		}

		return Holder.ObjectRef.Get() == nullptr
			&& Holder.TypedRef.Get() == nullptr
			&& Holder.ActorRef.Get() == nullptr;
	}

	/**
	 * Observe that an object pointer UPROPERTY keeps its target on the instance.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opAssign
	 * @Inputs NewObject of the holder class; assign an object to TypedRef
	 * @Return true when TypedRef returns that object
	 */
	UFUNCTION()
	bool ObjectPropertyKeepsTarget()
	{
		UTObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTObjectPtrPropertyHolder::StaticClass(), n"TObjPtrProp_Set", true);
		if (Holder == nullptr)
		{
			return false;
		}

		UTObjectPtrPropertyObject Target = NewObject(GetTransientPackage(), UTObjectPtrPropertyObject::StaticClass(), n"TObjPtrProp_Target", true);
		if (Target == nullptr)
		{
			return false;
		}

		Holder.TypedRef = Target;
		return Holder.TypedRef.Get() == Target;
	}

	/**
	 * Observe that object pointer property state is per-instance: setting it
	 * on one holder leaves a second holder null.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opAssign
	 * @Inputs Two holder instances; set the property on the first only
	 * @Return true when the first resolves and the second stays null
	 */
	UFUNCTION()
	bool ObjectPropertiesArePerInstance()
	{
		UTObjectPtrPropertyHolder First = NewObject(GetTransientPackage(), UTObjectPtrPropertyHolder::StaticClass(), n"TObjPtrProp_First", true);
		UTObjectPtrPropertyHolder Second = NewObject(GetTransientPackage(), UTObjectPtrPropertyHolder::StaticClass(), n"TObjPtrProp_Second", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		First.TypedRef = NewObject(GetTransientPackage(), UTObjectPtrPropertyObject::StaticClass(), n"TObjPtrProp_Shared", true);
		return First.TypedRef.Get() != nullptr && Second.TypedRef.Get() == nullptr;
	}

	/**
	 * Observe that an object pointer property keeps its target reachable: the
	 * referenced object survives a collection while the property holds it.
	 * This is the property that distinguishes it from a weak pointer.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.Get
	 * @Inputs Holder with a set property; CollectGarbage; re-read the property
	 * @Return true when the property still resolves after collection
	 * @Boundary GC reachability through a strong reference
	 */
	UFUNCTION()
	bool StrongPropertyKeepsTargetAlive()
	{
		UTObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTObjectPtrPropertyHolder::StaticClass(), n"TObjPtrProp_Reach", true);
		if (Holder == nullptr)
		{
			return false;
		}

		Holder.TypedRef = NewObject(GetTransientPackage(), UTObjectPtrPropertyObject::StaticClass(), n"TObjPtrProp_ReachTarget", true);
		if (Holder.TypedRef.Get() == nullptr)
		{
			return false;
		}

		CollectGarbage();

		return Holder.TypedRef.Get() != nullptr;
	}

	/**
	 * Observe that clearing an object pointer property returns it to null.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opAssign
	 * @Inputs Holder with a set property; assign nullptr
	 * @Return true when the property is null afterwards
	 */
	UFUNCTION()
	bool ClearingObjectPropertyReturnsToNull()
	{
		UTObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTObjectPtrPropertyHolder::StaticClass(), n"TObjPtrProp_Clear", true);
		if (Holder == nullptr)
		{
			return false;
		}

		Holder.TypedRef = NewObject(GetTransientPackage(), UTObjectPtrPropertyObject::StaticClass(), n"TObjPtrProp_ClearTarget", true);
		if (Holder.TypedRef.Get() == nullptr)
		{
			return false;
		}

		Holder.TypedRef = nullptr;
		return Holder.TypedRef.Get() == nullptr;
	}
}
/** @end */
