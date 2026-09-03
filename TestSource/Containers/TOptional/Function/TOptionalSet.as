/**
 * TOptional.Set and opAssign store a value and mark the optional as set.
 * Set() and `Opt = Value` are the two write paths; both flip IsSet() from
 * false to true. Presence is then observed through IsSet and GetValue, then
 * through UFUNCTION in, out, and inout directions.
 * int is canonical; other element shapes repeat the same four entries with
 * a type suffix.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.Set
 * @Harness Function
 * @Tag Containers.TOptional.TOptionalSet
 * @Namespace TOptionalTest
 */

UCLASS()
class UTOptionalSetObject : UObject
{
}

namespace TOptionalTest
{
	/**
	 * Observe Set: an unset optional becomes set and holds the stored value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Set
	 * @Inputs Default-constructed TOptional<int>; Set(42)
	 * @Return true when IsSet() is true and GetValue() is 42
	 */
	UFUNCTION()
	bool SetStoresValueAndMarksSet()
	{
		TOptional<int> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt.Set(42);
		return Opt.IsSet() && Opt.GetValue() == 42;
	}

	/**
	 * Observe opAssign: `Opt = 42` behaves like Set and overwrites a previous value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Default-constructed TOptional<int>; assign 42; reassign 7
	 * @Return true when the optional stays set and GetValue() reflects the last write
	 */
	UFUNCTION()
	bool AssignValueStoresAndOverwrites()
	{
		TOptional<int> Opt;
		Opt = 42;
		if (!Opt.IsSet() || Opt.GetValue() != 42)
		{
			return false;
		}

		Opt = 7;
		return Opt.IsSet() && Opt.GetValue() == 7;
	}

	/**
	 * In-only: read a set TOptional<int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Source optional received as const TOptional<int>&in
	 * @Inputs Value holds 42
	 * @Return true when IsSet() is true and GetValue() is 42
	 */
	UFUNCTION()
	bool ReadSetValue(const TOptional<int>&in Value)
	{
		return Value.IsSet() && Value.GetValue() == 42;
	}

	/**
	 * Out-only: fill an empty &out TOptional<int> with Set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Result Destination received as TOptional<int>&out
	 * @Inputs Empty &out TOptional<int>
	 * @Return void; Result is set and holds 42
	 */
	UFUNCTION()
	void FillOptionalBySet(TOptional<int>&out Result)
	{
		Result.Set(42);
	}

	/**
	 * Inout: overwrite the value of an already-set TOptional<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Optional received as TOptional<int>&inout, starts holding 42
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value still set and holds 7
	 */
	UFUNCTION()
	void OverwriteWithSet(TOptional<int>&inout Value)
	{
		Value.Set(7);
	}


	/**
	 * Observe Set: an unset TOptional<FString> becomes set and holds the stored value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Set
	 * @Inputs Default-constructed TOptional<FString>; Set("alpha")
	 * @Return true when IsSet() is true and GetValue() is "alpha"
	 */
	UFUNCTION()
	bool SetStoresValueAndMarksSet_FString()
	{
		TOptional<FString> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt.Set("alpha");
		return Opt.IsSet() && Opt.GetValue() == "alpha";
	}

	/**
	 * Observe opAssign: assigning another string overwrites the stored value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Default-constructed TOptional<FString>; assign "alpha"; reassign "beta"
	 * @Return true when GetValue() reflects the last write
	 */
	UFUNCTION()
	bool AssignValueStoresAndOverwrites_FString()
	{
		TOptional<FString> Opt;
		Opt = "alpha";
		if (!Opt.IsSet() || Opt.GetValue() != "alpha")
		{
			return false;
		}

		Opt = "beta";
		return Opt.IsSet() && Opt.GetValue() == "beta";
	}

	/**
	 * In-only: read a set TOptional<FString> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Source optional received as const TOptional<FString>&in
	 * @Inputs Value holds "alpha"
	 * @Return true when IsSet() is true and GetValue() is "alpha"
	 */
	UFUNCTION()
	bool ReadSetValue_FString(const TOptional<FString>&in Value)
	{
		return Value.IsSet() && Value.GetValue() == "alpha";
	}

	/**
	 * Out-only: fill an empty &out TOptional<FString> with Set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Result Destination received as TOptional<FString>&out
	 * @Inputs Empty &out TOptional<FString>
	 * @Return void; Result is set and holds "alpha"
	 */
	UFUNCTION()
	void FillOptionalBySet_FString(TOptional<FString>&out Result)
	{
		Result.Set("alpha");
	}

	/**
	 * Inout: overwrite the value of an already-set TOptional<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Optional received as TOptional<FString>&inout, starts holding "alpha"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value still set and holds "beta"
	 */
	UFUNCTION()
	void OverwriteWithSet_FString(TOptional<FString>&inout Value)
	{
		Value.Set("beta");
	}


	/**
	 * Observe Set: an unset TOptional<FName> becomes set and holds the stored value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Set
	 * @Inputs Default-constructed TOptional<FName>; Set(n"Red")
	 * @Return true when IsSet() is true and GetValue() is n"Red"
	 */
	UFUNCTION()
	bool SetStoresValueAndMarksSet_FName()
	{
		TOptional<FName> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt.Set(n"Red");
		return Opt.IsSet() && Opt.GetValue() == n"Red";
	}

	/**
	 * Observe opAssign: assigning another name overwrites the stored value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Default-constructed TOptional<FName>; assign n"Red"; reassign n"Green"
	 * @Return true when GetValue() reflects the last write
	 */
	UFUNCTION()
	bool AssignValueStoresAndOverwrites_FName()
	{
		TOptional<FName> Opt;
		Opt = n"Red";
		if (!Opt.IsSet() || Opt.GetValue() != n"Red")
		{
			return false;
		}

		Opt = n"Green";
		return Opt.IsSet() && Opt.GetValue() == n"Green";
	}

	/**
	 * In-only: read a set TOptional<FName> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Source optional received as const TOptional<FName>&in
	 * @Inputs Value holds n"Red"
	 * @Return true when IsSet() is true and GetValue() is n"Red"
	 */
	UFUNCTION()
	bool ReadSetValue_FName(const TOptional<FName>&in Value)
	{
		return Value.IsSet() && Value.GetValue() == n"Red";
	}

	/**
	 * Out-only: fill an empty &out TOptional<FName> with Set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Result Destination received as TOptional<FName>&out
	 * @Inputs Empty &out TOptional<FName>
	 * @Return void; Result is set and holds n"Red"
	 */
	UFUNCTION()
	void FillOptionalBySet_FName(TOptional<FName>&out Result)
	{
		Result.Set(n"Red");
	}

	/**
	 * Inout: overwrite the value of an already-set TOptional<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Optional received as TOptional<FName>&inout, starts holding n"Red"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value still set and holds n"Green"
	 */
	UFUNCTION()
	void OverwriteWithSet_FName(TOptional<FName>&inout Value)
	{
		Value.Set(n"Green");
	}


	/**
	 * Observe Set: storing false is a real set, not a no-op.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Set
	 * @Inputs Default-constructed TOptional<bool>; Set(false)
	 * @Return true when IsSet() is true and GetValue() is false
	 */
	UFUNCTION()
	bool SetStoresValueAndMarksSet_bool()
	{
		TOptional<bool> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt.Set(false);
		return Opt.IsSet() && Opt.GetValue() == false;
	}

	/**
	 * Observe opAssign: assigning true over a stored false overwrites it.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Default-constructed TOptional<bool>; assign false; reassign true
	 * @Return true when GetValue() reflects the last write
	 */
	UFUNCTION()
	bool AssignValueStoresAndOverwrites_bool()
	{
		TOptional<bool> Opt;
		Opt = false;
		if (!Opt.IsSet() || Opt.GetValue() != false)
		{
			return false;
		}

		Opt = true;
		return Opt.IsSet() && Opt.GetValue() == true;
	}

	/**
	 * In-only: read a set TOptional<bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Source optional received as const TOptional<bool>&in
	 * @Inputs Value holds true
	 * @Return true when IsSet() is true and GetValue() is true
	 */
	UFUNCTION()
	bool ReadSetValue_bool(const TOptional<bool>&in Value)
	{
		return Value.IsSet() && Value.GetValue() == true;
	}

	/**
	 * Out-only: fill an empty &out TOptional<bool> with Set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Result Destination received as TOptional<bool>&out
	 * @Inputs Empty &out TOptional<bool>
	 * @Return void; Result is set and holds true
	 */
	UFUNCTION()
	void FillOptionalBySet_bool(TOptional<bool>&out Result)
	{
		Result.Set(true);
	}

	/**
	 * Inout: overwrite the value of an already-set TOptional<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Optional received as TOptional<bool>&inout, starts holding true
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value still set and holds false
	 */
	UFUNCTION()
	void OverwriteWithSet_bool(TOptional<bool>&inout Value)
	{
		Value.Set(false);
	}


	/**
	 * Observe Set: an unset TOptional<FVector> becomes set and holds the stored value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Set
	 * @Inputs Default-constructed TOptional<FVector>; Set(FVector(1,0,0))
	 * @Return true when IsSet() is true and GetValue() equals the stored vector
	 */
	UFUNCTION()
	bool SetStoresValueAndMarksSet_FVector()
	{
		TOptional<FVector> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt.Set(FVector(1.0f, 0.0f, 0.0f));
		return Opt.IsSet() && Opt.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
	}

	/**
	 * Observe opAssign: assigning another vector overwrites the stored value.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Default-constructed TOptional<FVector>; assign X axis; reassign Y axis
	 * @Return true when GetValue() reflects the last write
	 */
	UFUNCTION()
	bool AssignValueStoresAndOverwrites_FVector()
	{
		TOptional<FVector> Opt;
		Opt = FVector(1.0f, 0.0f, 0.0f);
		if (!Opt.IsSet() || !Opt.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f)))
		{
			return false;
		}

		Opt = FVector(0.0f, 1.0f, 0.0f);
		return Opt.IsSet() && Opt.GetValue().Equals(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * In-only: read a set TOptional<FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Source optional received as const TOptional<FVector>&in
	 * @Inputs Value holds the X axis
	 * @Return true when IsSet() is true and GetValue() equals the X axis
	 */
	UFUNCTION()
	bool ReadSetValue_FVector(const TOptional<FVector>&in Value)
	{
		return Value.IsSet() && Value.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
	}

	/**
	 * Out-only: fill an empty &out TOptional<FVector> with Set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Result Destination received as TOptional<FVector>&out
	 * @Inputs Empty &out TOptional<FVector>
	 * @Return void; Result is set and holds the X axis
	 */
	UFUNCTION()
	void FillOptionalBySet_FVector(TOptional<FVector>&out Result)
	{
		Result.Set(FVector(1.0f, 0.0f, 0.0f));
	}

	/**
	 * Inout: overwrite the value of an already-set TOptional<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Optional received as TOptional<FVector>&inout, starts holding the X axis
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value still set and holds the Y axis
	 */
	UFUNCTION()
	void OverwriteWithSet_FVector(TOptional<FVector>&inout Value)
	{
		Value.Set(FVector(0.0f, 1.0f, 0.0f));
	}


	/**
	 * Observe Set: an unset TOptional<UObject> becomes set and holds the pointer.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Set
	 * @Inputs Default-constructed TOptional<UObject>; Set(object created via NewObject)
	 * @Return true when IsSet() is true and GetValue() is that object
	 */
	UFUNCTION()
	bool SetStoresValueAndMarksSet_UObject()
	{
		TOptional<UObject> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		UObject First = NewObject(GetTransientPackage(), UTOptionalSetObject::StaticClass(), n"TOptionalSet_First", true);
		if (First == nullptr)
		{
			return false;
		}

		Opt.Set(First);
		return Opt.IsSet() && Opt.GetValue() == First;
	}

	/**
	 * Observe opAssign: assigning a second object overwrites the stored pointer.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs Default-constructed TOptional<UObject>; assign First; reassign Second
	 * @Return true when GetValue() is Second and not First
	 */
	UFUNCTION()
	bool AssignValueStoresAndOverwrites_UObject()
	{
		UObject First = NewObject(GetTransientPackage(), UTOptionalSetObject::StaticClass(), n"TOptionalSet_Over_0", true);
		UObject Second = NewObject(GetTransientPackage(), UTOptionalSetObject::StaticClass(), n"TOptionalSet_Over_1", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		TOptional<UObject> Opt;
		Opt = First;
		if (!Opt.IsSet() || Opt.GetValue() != First)
		{
			return false;
		}

		Opt = Second;
		return Opt.IsSet() && Opt.GetValue() == Second && Opt.GetValue() != First;
	}

	/**
	 * In-only: read a set TOptional<UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Source optional received as const TOptional<UObject>&in
	 * @Inputs Value holds a non-null object
	 * @Return true when IsSet() is true and GetValue() is non-null
	 */
	UFUNCTION()
	bool ReadSetValue_UObject(const TOptional<UObject>&in Value)
	{
		return Value.IsSet() && Value.GetValue() != nullptr;
	}

	/**
	 * Out-only: fill an empty &out TOptional<UObject> with Set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Result Destination received as TOptional<UObject>&out
	 * @Inputs Empty &out TOptional<UObject>
	 * @Return void; Result is set and holds a non-null object
	 */
	UFUNCTION()
	void FillOptionalBySet_UObject(TOptional<UObject>&out Result)
	{
		Result.Set(NewObject(GetTransientPackage(), UTOptionalSetObject::StaticClass(), n"TOptionalSet_Fill", true));
	}

	/**
	 * Inout: overwrite the value of an already-set TOptional<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Optional received as TOptional<UObject>&inout, starts holding an object
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value still set and holds a different non-null object
	 */
	UFUNCTION()
	void OverwriteWithSet_UObject(TOptional<UObject>&inout Value)
	{
		Value.Set(NewObject(GetTransientPackage(), UTOptionalSetObject::StaticClass(), n"TOptionalSet_Overwrite", true));
	}
}
