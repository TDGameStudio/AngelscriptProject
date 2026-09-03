/**
 * TSubclassOf<T> as a UPROPERTY on a script UCLASS. The property starts null
 * and per-instance, and it is the shape a designer-facing "pick a class"
 * field takes. SpawnActor / NewObject accept the holder directly through
 * implicit conversion, so the property can be used as a factory without
 * unwrapping it by hand.
 *
 * @Theme Containers.TSubclassOf
 * @Subject TSubclassOf.Property
 * @Harness UClass
 * @Tag Containers.TSubclassOf.TSubclassOfProperty
 * @Namespace TSubclassOfTest
 */

UCLASS()
class UTSubclassOfPropertyBase : UObject
{
}

UCLASS()
class UTSubclassOfPropertyDerived : UTSubclassOfPropertyBase
{
}

UCLASS()
class UTSubclassOfPropertyHolder : UObject
{
	UPROPERTY()
	TSubclassOf<UObject> ObjectClass;

	UPROPERTY()
	TSubclassOf<UTSubclassOfPropertyBase> BaseClass;

	UPROPERTY()
	TSubclassOf<AActor> ActorClass;
}

namespace TSubclassOfTest
{
	/**
	 * Observe that TSubclassOf UPROPERTYs start null on a fresh instance.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.Construct
	 * @Inputs NewObject of the holder class
	 * @Return true when all three properties report invalid and null
	 */
	UFUNCTION()
	bool SubclassPropertiesStartNull()
	{
		UTSubclassOfPropertyHolder Holder = NewObject(GetTransientPackage(), UTSubclassOfPropertyHolder::StaticClass(), n"TSubclassProp_Unset", true);
		if (Holder == nullptr)
		{
			return false;
		}

		return !Holder.ObjectClass.IsValid() && Holder.ObjectClass.Get() == nullptr
			&& !Holder.BaseClass.IsValid() && Holder.BaseClass.Get() == nullptr
			&& !Holder.ActorClass.IsValid() && Holder.ActorClass.Get() == nullptr;
	}

	/**
	 * Observe that a TSubclassOf UPROPERTY keeps its class and reports the
	 * right hierarchy once set.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.IsChildOf
	 * @Inputs NewObject of the holder class; set BaseClass to the derived class
	 * @Return true when BaseClass is valid, is a child of the base, and Get() matches
	 */
	UFUNCTION()
	bool SubclassPropertyKeepsClassAndHierarchy()
	{
		UTSubclassOfPropertyHolder Holder = NewObject(GetTransientPackage(), UTSubclassOfPropertyHolder::StaticClass(), n"TSubclassProp_Set", true);
		if (Holder == nullptr)
		{
			return false;
		}

		UClass Derived = UTSubclassOfPropertyDerived::StaticClass();
		Holder.BaseClass = Derived;

		return Holder.BaseClass.IsValid()
			&& Holder.BaseClass.Get() == Derived
			&& Holder.BaseClass.IsChildOf(UTSubclassOfPropertyBase::StaticClass());
	}

	/**
	 * Observe that a TSubclassOf UPROPERTY can be used directly as a factory
	 * argument, via implicit conversion to UClass.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.opImplConv
	 * @Inputs NewObject of the holder class; set ObjectClass; NewObject from it
	 * @Return true when the produced object is an instance of the held class
	 */
	UFUNCTION()
	bool SubclassPropertyActsAsFactory()
	{
		UTSubclassOfPropertyHolder Holder = NewObject(GetTransientPackage(), UTSubclassOfPropertyHolder::StaticClass(), n"TSubclassProp_Factory", true);
		if (Holder == nullptr)
		{
			return false;
		}

		Holder.ObjectClass = UTSubclassOfPropertyDerived::StaticClass();

		UObject Produced = NewObject(GetTransientPackage(), Holder.ObjectClass, n"TSubclassProp_Produced", true);
		return Produced != nullptr
			&& Cast<UTSubclassOfPropertyDerived>(Produced) != nullptr;
	}

	/**
	 * Observe that TSubclassOf property state is per-instance: setting it on
	 * one holder leaves a second holder null.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.opAssign
	 * @Inputs Two holder instances; set the property on the first only
	 * @Return true when the first is valid and the second stays null
	 */
	UFUNCTION()
	bool SubclassPropertiesArePerInstance()
	{
		UTSubclassOfPropertyHolder First = NewObject(GetTransientPackage(), UTSubclassOfPropertyHolder::StaticClass(), n"TSubclassProp_First", true);
		UTSubclassOfPropertyHolder Second = NewObject(GetTransientPackage(), UTSubclassOfPropertyHolder::StaticClass(), n"TSubclassProp_Second", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		First.ObjectClass = UTSubclassOfPropertyBase::StaticClass();
		return First.ObjectClass.IsValid() && !Second.ObjectClass.IsValid();
	}

	/**
	 * Observe that clearing a TSubclassOf UPROPERTY returns it to null and
	 * invalidates the hierarchy query.
	 *
	 * @Kind Observe
	 * @Covers TSubclassOf.opAssign
	 * @Inputs NewObject of the holder class; set BaseClass; assign nullptr
	 * @Return true when the property is null and IsChildOf is false afterwards
	 */
	UFUNCTION()
	bool ClearingSubclassPropertyInvalidatesHierarchy()
	{
		UTSubclassOfPropertyHolder Holder = NewObject(GetTransientPackage(), UTSubclassOfPropertyHolder::StaticClass(), n"TSubclassProp_Clear", true);
		if (Holder == nullptr)
		{
			return false;
		}

		Holder.BaseClass = UTSubclassOfPropertyDerived::StaticClass();
		if (!Holder.BaseClass.IsChildOf(UTSubclassOfPropertyBase::StaticClass()))
		{
			return false;
		}

		Holder.BaseClass = nullptr;
		return !Holder.BaseClass.IsValid()
			&& Holder.BaseClass.Get() == nullptr
			&& !Holder.BaseClass.IsChildOf(UTSubclassOfPropertyBase::StaticClass());
	}
}
