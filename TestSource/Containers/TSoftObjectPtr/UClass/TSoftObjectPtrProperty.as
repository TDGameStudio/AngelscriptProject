/**
 * TSoftObjectPtr<T> as a UPROPERTY on a script UCLASS. The property starts
 * null and is per-instance. A soft property is the shape an asset reference
 * field takes: it names an asset without pinning it in memory, so the
 * referencing object can be loaded without loading the asset too.
 *
 * @Theme Containers.TSoftObjectPtr
 * @Subject TSoftObjectPtr.Property
 * @Harness UClass
 * @Tag Containers.TSoftObjectPtr.TSoftObjectPtrProperty
 * @Namespace TSoftObjectPtrTest
 */

UCLASS()
class UTSoftObjectPtrPropertyObject : UObject
{
}

UCLASS()
class UTSoftObjectPtrPropertyHolder : UObject
{
	UPROPERTY()
	TSoftObjectPtr<UObject> ObjectRef;

	UPROPERTY()
	TSoftObjectPtr<UTSoftObjectPtrPropertyObject> TypedRef;

	UPROPERTY()
	TSoftObjectPtr<AActor> ActorRef;
}

namespace TSoftObjectPtrTest
{
	/**
	 * Observe that soft UPROPERTYs start null on a fresh instance.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.IsNull
	 * @Inputs NewObject of the holder class
	 * @Return true when all three properties are null and not pending
	 */
	UFUNCTION()
	bool SoftPropertiesStartNull()
	{
		UTSoftObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTSoftObjectPtrPropertyHolder::StaticClass(), n"TSoftPtrProp_Unset", true);
		if (Holder == nullptr)
		{
			return false;
		}

		return Holder.ObjectRef.IsNull() && !Holder.ObjectRef.IsPending()
			&& Holder.TypedRef.IsNull() && !Holder.TypedRef.IsPending()
			&& Holder.ActorRef.IsNull() && !Holder.ActorRef.IsPending();
	}

	/**
	 * Observe that a soft UPROPERTY keeps its path on the instance.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.opAssign
	 * @Inputs NewObject of the holder class; assign a path to ObjectRef
	 * @Return true when the path round-trips and the property is no longer null
	 */
	UFUNCTION()
	bool SoftPropertyKeepsPath()
	{
		UTSoftObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTSoftObjectPtrPropertyHolder::StaticClass(), n"TSoftPtrProp_Set", true);
		if (Holder == nullptr)
		{
			return false;
		}

		FSoftObjectPath Path("/Game/AngelscriptTest/SomePackage.SomeAsset");
		Holder.ObjectRef = Path;

		return !Holder.ObjectRef.IsNull()
			&& Holder.ObjectRef.ToSoftObjectPath() == Path;
	}

	/**
	 * Observe that assigning a live object to a soft UPROPERTY captures its
	 * path and resolves back to it while loaded.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Get
	 * @Inputs NewObject of the holder class; assign a live object to TypedRef
	 * @Return true when the property is valid and Get() returns that object
	 */
	UFUNCTION()
	bool SoftPropertyResolvesAssignedObject()
	{
		UTSoftObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTSoftObjectPtrPropertyHolder::StaticClass(), n"TSoftPtrProp_Resolve", true);
		if (Holder == nullptr)
		{
			return false;
		}

		UTSoftObjectPtrPropertyObject Target = NewObject(GetTransientPackage(), UTSoftObjectPtrPropertyObject::StaticClass(), n"TSoftPtrProp_Target", true);
		if (Target == nullptr)
		{
			return false;
		}

		Holder.TypedRef = Target;
		return Holder.TypedRef.IsValid() && Holder.TypedRef.Get() == Target;
	}

	/**
	 * Observe that soft property state is per-instance: setting it on one
	 * holder leaves a second holder null.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.opAssign
	 * @Inputs Two holder instances; assign the property on the first only
	 * @Return true when the first holds a path and the second stays null
	 */
	UFUNCTION()
	bool SoftPropertiesArePerInstance()
	{
		UTSoftObjectPtrPropertyHolder First = NewObject(GetTransientPackage(), UTSoftObjectPtrPropertyHolder::StaticClass(), n"TSoftPtrProp_First", true);
		UTSoftObjectPtrPropertyHolder Second = NewObject(GetTransientPackage(), UTSoftObjectPtrPropertyHolder::StaticClass(), n"TSoftPtrProp_Second", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		First.ObjectRef = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");
		return !First.ObjectRef.IsNull() && Second.ObjectRef.IsNull();
	}

	/**
	 * Observe that a soft UPROPERTY does not pin its asset: the property names
	 * the asset without making it reachable, which is the whole point of a
	 * soft reference in a loaded object.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.IsPending
	 * @Inputs Holder with a path-only property; confirm it stays pending
	 * @Return true when the property is pending and not valid
	 * @Boundary soft reference vs strong reference
	 */
	UFUNCTION()
	bool SoftPropertyDoesNotPinAsset()
	{
		UTSoftObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTSoftObjectPtrPropertyHolder::StaticClass(), n"TSoftPtrProp_Pending", true);
		if (Holder == nullptr)
		{
			return false;
		}

		Holder.ObjectRef = FSoftObjectPath("/Game/AngelscriptTest/NotLoaded.Never");

		return Holder.ObjectRef.IsPending()
			&& !Holder.ObjectRef.IsNull()
			&& !Holder.ObjectRef.IsValid();
	}

	/**
	 * Observe that Reset on a soft UPROPERTY returns it to null.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Reset
	 * @Inputs Holder with a path property; Reset()
	 * @Return true when the property is null and its path is empty afterwards
	 */
	UFUNCTION()
	bool ResetSoftPropertyReturnsToNull()
	{
		UTSoftObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTSoftObjectPtrPropertyHolder::StaticClass(), n"TSoftPtrProp_Reset", true);
		if (Holder == nullptr)
		{
			return false;
		}

		Holder.ObjectRef = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");
		if (Holder.ObjectRef.IsNull())
		{
			return false;
		}

		Holder.ObjectRef.Reset();
		return Holder.ObjectRef.IsNull() && Holder.ObjectRef.ToString() == "";
	}
}
