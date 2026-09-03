/**
 * TOptional<T> as a UPROPERTY on a script UCLASS. The property starts unset,
 * and the set/unset state survives on the instance across method calls.
 * Element shapes that a property can hold: int, FString, FName, bool,
 * FVector, and a UObject pointer.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.Property
 * @Harness UClass
 * @Tag Containers.TOptional.TOptionalProperty
 * @Namespace TOptionalTest
 */

UCLASS()
class UTOptionalPropertyHolder : UObject
{
	UPROPERTY()
	TOptional<int> IntValue;

	UPROPERTY()
	TOptional<FString> StringValue;

	UPROPERTY()
	TOptional<FName> NameValue;

	UPROPERTY()
	TOptional<bool> BoolValue;

	UPROPERTY()
	TOptional<FVector> VectorValue;

	UPROPERTY()
	TOptional<UObject> ObjectValue;

	/**
	 * Observe that every optional UPROPERTY starts unset on a fresh instance.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Construct
	 * @Inputs NewObject of this class
	 * @Return true when all six optional properties report unset
	 */
	UFUNCTION()
	bool OptionalPropertiesStartUnset()
	{
		UTOptionalPropertyHolder Holder = NewObject(GetTransientPackage(), UTOptionalPropertyHolder::StaticClass(), n"TOptionalProperty_Unset", true);
		if (Holder == nullptr)
		{
			return false;
		}

		return !Holder.IntValue.IsSet()
			&& !Holder.StringValue.IsSet()
			&& !Holder.NameValue.IsSet()
			&& !Holder.BoolValue.IsSet()
			&& !Holder.VectorValue.IsSet()
			&& !Holder.ObjectValue.IsSet();
	}

	/**
	 * Observe that a set optional UPROPERTY keeps its state on the instance.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Set
	 * @Inputs NewObject of this class; set each property
	 * @Return true when all six properties are set and hold the stored values
	 */
	UFUNCTION()
	bool OptionalPropertiesKeepSetState()
	{
		UTOptionalPropertyHolder Holder = NewObject(GetTransientPackage(), UTOptionalPropertyHolder::StaticClass(), n"TOptionalProperty_Set", true);
		if (Holder == nullptr)
		{
			return false;
		}

		Holder.IntValue.Set(42);
		Holder.StringValue.Set("alpha");
		Holder.NameValue.Set(n"Red");
		Holder.BoolValue.Set(true);
		Holder.VectorValue.Set(FVector(1.0f, 0.0f, 0.0f));
		Holder.ObjectValue.Set(NewObject(GetTransientPackage(), UTOptionalPropertyHolder::StaticClass(), n"TOptionalProperty_Inner", true));

		return Holder.IntValue.IsSet() && Holder.IntValue.GetValue() == 42
			&& Holder.StringValue.IsSet() && Holder.StringValue.GetValue() == "alpha"
			&& Holder.NameValue.IsSet() && Holder.NameValue.GetValue() == n"Red"
			&& Holder.BoolValue.IsSet() && Holder.BoolValue.GetValue() == true
			&& Holder.VectorValue.IsSet() && Holder.VectorValue.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f))
			&& Holder.ObjectValue.IsSet() && Holder.ObjectValue.GetValue() != nullptr;
	}

	/**
	 * Observe that Reset on an optional UPROPERTY clears the instance state,
	 * and that Get then returns the fallback rather than throwing.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs NewObject of this class; set IntValue; Reset it
	 * @Return true when the property is unset and Get returns the fallback
	 */
	UFUNCTION()
	bool ResetOptionalPropertyClearsState()
	{
		UTOptionalPropertyHolder Holder = NewObject(GetTransientPackage(), UTOptionalPropertyHolder::StaticClass(), n"TOptionalProperty_Reset", true);
		if (Holder == nullptr)
		{
			return false;
		}

		Holder.IntValue.Set(42);
		if (!Holder.IntValue.IsSet())
		{
			return false;
		}

		Holder.IntValue.Reset();
		return !Holder.IntValue.IsSet() && Holder.IntValue.Get(7) == 7;
	}

	/**
	 * Observe that two instances hold independent optional property state.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Two NewObject instances; set the property on the first only
	 * @Return true when the first is set and the second remains unset
	 */
	UFUNCTION()
	bool OptionalPropertiesArePerInstance()
	{
		UTOptionalPropertyHolder First = NewObject(GetTransientPackage(), UTOptionalPropertyHolder::StaticClass(), n"TOptionalProperty_First", true);
		UTOptionalPropertyHolder Second = NewObject(GetTransientPackage(), UTOptionalPropertyHolder::StaticClass(), n"TOptionalProperty_Second", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		First.IntValue.Set(42);
		return First.IntValue.IsSet()
			&& First.IntValue.GetValue() == 42
			&& !Second.IntValue.IsSet();
	}
}
