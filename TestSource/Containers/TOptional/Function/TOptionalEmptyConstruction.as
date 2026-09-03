/**
 * Default-constructed TOptional<T> is unset. IsSet() is false, and an
 * unset optional compares equal to another unset optional of the same T
 * but never to a set one. This file is the empty-invariant template:
 * full shape for int, remaining element shapes assert the unset default.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.Construct
 * @Harness Function
 * @Tag Containers.TOptional.TOptionalEmptyConstruction
 * @Namespace TOptionalTest
 */

UCLASS()
class UTOptionalEmptyConstructionObject : UObject
{
}

namespace TOptionalTest
{
	/**
	 * Observe default construction: a fresh TOptional<int> is unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Default-constructed TOptional<int>
	 * @Return true when IsSet() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsUnset()
	{
		TOptional<int> Opt;
		return !Opt.IsSet();
	}

	/**
	 * Observe unset equality: two unset TOptional<int> compare equal.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opEquals
	 * @Inputs Two default-constructed TOptional<int>
	 * @Return true when the two unset optionals are equal
	 */
	UFUNCTION()
	bool UnsetEqualsUnset()
	{
		TOptional<int> First;
		TOptional<int> Second;
		return First == Second;
	}

	/**
	 * Observe unset vs set: an unset TOptional<int> is not equal to a set one,
	 * even when the set value equals the default value of int.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opEquals
	 * @Inputs One unset TOptional<int>; one set to 0
	 * @Return true when the two optionals differ
	 */
	UFUNCTION()
	bool UnsetDiffersFromSetDefaultValue()
	{
		TOptional<int> Unset;
		TOptional<int> Zero;
		Zero = 0;
		return Unset != Zero;
	}

	/**
	 * Observe copy independence: constructing two optionals and setting only
	 * the first leaves the second unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Two default-constructed TOptional<int>; assign 1 to the first
	 * @Return true when the first is set and the second is still unset
	 */
	UFUNCTION()
	bool DefaultConstructionCopyIndependence()
	{
		TOptional<int> First;
		TOptional<int> Second;
		First = 1;
		return First.IsSet() && !Second.IsSet();
	}


	/**
	 * Observe default construction: a fresh TOptional<FString> is unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Default-constructed TOptional<FString>
	 * @Return true when IsSet() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsUnset_FString()
	{
		TOptional<FString> Opt;
		return !Opt.IsSet();
	}

	/**
	 * Observe copy independence for FString: setting one optional leaves the other unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Two default-constructed TOptional<FString>; assign to the first
	 * @Return true when the first is set and the second is still unset
	 */
	UFUNCTION()
	bool DefaultConstructionCopyIndependence_FString()
	{
		TOptional<FString> First;
		TOptional<FString> Second;
		First = "alpha";
		return First.IsSet() && !Second.IsSet();
	}


	/**
	 * Observe default construction: a fresh TOptional<FName> is unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Default-constructed TOptional<FName>
	 * @Return true when IsSet() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsUnset_FName()
	{
		TOptional<FName> Opt;
		return !Opt.IsSet();
	}

	/**
	 * Observe copy independence for FName: setting one optional leaves the other unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Two default-constructed TOptional<FName>; assign to the first
	 * @Return true when the first is set and the second is still unset
	 */
	UFUNCTION()
	bool DefaultConstructionCopyIndependence_FName()
	{
		TOptional<FName> First;
		TOptional<FName> Second;
		First = n"Red";
		return First.IsSet() && !Second.IsSet();
	}


	/**
	 * Observe default construction: a fresh TOptional<bool> is unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Default-constructed TOptional<bool>
	 * @Return true when IsSet() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsUnset_bool()
	{
		TOptional<bool> Opt;
		return !Opt.IsSet();
	}

	/**
	 * Observe unset vs set for bool: an unset TOptional<bool> is not equal to
	 * one holding false. Presence is tracked separately from the value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opEquals
	 * @Inputs One unset TOptional<bool>; one set to false
	 * @Return true when the two optionals differ
	 */
	UFUNCTION()
	bool UnsetDiffersFromSetFalse_bool()
	{
		TOptional<bool> Unset;
		TOptional<bool> False;
		False = false;
		return Unset != False;
	}


	/**
	 * Observe default construction: a fresh TOptional<FVector> is unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Default-constructed TOptional<FVector>
	 * @Return true when IsSet() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsUnset_FVector()
	{
		TOptional<FVector> Opt;
		return !Opt.IsSet();
	}

	/**
	 * Observe copy independence for FVector: setting one optional leaves the other unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Two default-constructed TOptional<FVector>; assign to the first
	 * @Return true when the first is set and the second is still unset
	 */
	UFUNCTION()
	bool DefaultConstructionCopyIndependence_FVector()
	{
		TOptional<FVector> First;
		TOptional<FVector> Second;
		First = FVector(1.0f, 0.0f, 0.0f);
		return First.IsSet() && !Second.IsSet();
	}


	/**
	 * Observe default construction: a fresh TOptional<UObject> is unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Default-constructed TOptional<UObject>
	 * @Return true when IsSet() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsUnset_UObject()
	{
		TOptional<UObject> Opt;
		return !Opt.IsSet();
	}

	/**
	 * Observe that holding nullptr is still "set": presence is tracked
	 * separately from the pointer value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs Default-constructed TOptional<UObject>; assign nullptr
	 * @Return true when IsSet() is true after assigning nullptr
	 */
	UFUNCTION()
	bool AssigningNullptrStillSets_UObject()
	{
		TOptional<UObject> Opt;
		Opt = nullptr;
		return Opt.IsSet();
	}
}
