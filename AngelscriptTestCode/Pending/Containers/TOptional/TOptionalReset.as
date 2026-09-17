/**
 * @version v1
 * @summary TOptional.Reset destroys the contained value and marks the optional as unset. Reset on an already-unset optional is a legal no-op, and the optional can be set again afterwards. int is canonical; other element shapes.
 * @topic Containers
 */
/**
 * @version root
 * @summary TOptional.Reset destroys the contained value and marks the optional as unset. Reset on an already-unset optional is a legal no-op, and the optional can be set again afterwards. int is canonical; other element shapes.
 * @topic Baseline
 */
UCLASS()
class UTOptionalResetObject : UObject
{
}

namespace TOptionalTest
{
	/**
	 * Observe Reset: a set optional becomes unset and Get falls back.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs TOptional<int> set to 42; Reset()
	 * @Return true when IsSet() is false and Get(7) is 7
	 */
	UFUNCTION()
	bool ResetUnsetsAndFallsBack()
	{
		TOptional<int> Opt;
		Opt.Set(42);
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		return !Opt.IsSet() && Opt.Get(7) == 7;
	}

	/**
	 * Observe that Reset on an unset optional is a legal no-op.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs Default-constructed TOptional<int>; Reset() twice
	 * @Return true when the optional is still unset after both resets
	 */
	UFUNCTION()
	bool ResetOnUnsetIsNoOp()
	{
		TOptional<int> Opt;
		Opt.Reset();
		Opt.Reset();
		return !Opt.IsSet();
	}

	/**
	 * Observe that an optional can be set again after a Reset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs TOptional<int> set to 42; Reset(); Set(11)
	 * @Return true when GetValue() is 11 after the second set
	 */
	UFUNCTION()
	bool SetAfterResetStoresNewValue()
	{
		TOptional<int> Opt;
		Opt.Set(42);
		Opt.Reset();
		if (Opt.IsSet())
		{
			return false;
		}

		Opt.Set(11);
		return Opt.IsSet() && Opt.GetValue() == 11;
	}

	/**
	 * In-only: confirm a const&in TOptional<int> still reports set (Reset is not reachable here).
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Source optional received as const TOptional<int>&in
	 * @Inputs Value holds 42
	 * @Return true when IsSet() is true and GetValue() is 42
	 */
	UFUNCTION()
	bool ReadBeforeReset(const TOptional<int>&in Value)
	{
		return Value.IsSet() && Value.GetValue() == 42;
	}

	/**
	 * Out-only: set then reset an &out TOptional<int>, leaving it unset.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Result Destination received as TOptional<int>&out
	 * @Inputs Empty &out TOptional<int>
	 * @Return void; Result is set and then reset back to unset
	 */
	UFUNCTION()
	void SetThenReset(TOptional<int>&out Result)
	{
		Result.Set(42);
		Result.Reset();
	}

	/**
	 * Inout: reset an already-set TOptional<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Optional received as TOptional<int>&inout, starts holding 42
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ResetSetState(TOptional<int>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Reset for FString, including re-set afterwards.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs TOptional<FString> set to "alpha"; Reset(); Set("beta")
	 * @Return true when IsSet() is false after the reset and true after the re-set
	 */
	UFUNCTION()
	bool ResetUnsetsAndAllowsResSet_FString()
	{
		TOptional<FString> Opt;
		Opt.Set("alpha");
		Opt.Reset();
		if (Opt.IsSet() || Opt.Get("fallback") != "fallback")
		{
			return false;
		}

		Opt.Set("beta");
		return Opt.IsSet() && Opt.GetValue() == "beta";
	}

	/**
	 * In-only: confirm a const&in TOptional<FString> reports set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Source optional received as const TOptional<FString>&in
	 * @Inputs Value holds "alpha"
	 * @Return true when IsSet() is true and GetValue() is "alpha"
	 */
	UFUNCTION()
	bool ReadBeforeReset_FString(const TOptional<FString>&in Value)
	{
		return Value.IsSet() && Value.GetValue() == "alpha";
	}

	/**
	 * Out-only: set then reset an &out TOptional<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Result Destination received as TOptional<FString>&out
	 * @Inputs Empty &out TOptional<FString>
	 * @Return void; Result is left unset
	 */
	UFUNCTION()
	void SetThenReset_FString(TOptional<FString>&out Result)
	{
		Result.Set("alpha");
		Result.Reset();
	}

	/**
	 * Inout: reset an already-set TOptional<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Optional received as TOptional<FString>&inout, starts holding "alpha"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ResetSetState_FString(TOptional<FString>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Reset for FName.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs TOptional<FName> set to n"Red"; Reset()
	 * @Return true when IsSet() is false and Get falls back
	 */
	UFUNCTION()
	bool ResetUnsetsAndFallsBack_FName()
	{
		TOptional<FName> Opt;
		Opt.Set(n"Red");
		Opt.Reset();
		return !Opt.IsSet() && Opt.Get(n"Fallback") == n"Fallback";
	}

	/**
	 * In-only: confirm a const&in TOptional<FName> reports set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Source optional received as const TOptional<FName>&in
	 * @Inputs Value holds n"Red"
	 * @Return true when IsSet() is true and GetValue() is n"Red"
	 */
	UFUNCTION()
	bool ReadBeforeReset_FName(const TOptional<FName>&in Value)
	{
		return Value.IsSet() && Value.GetValue() == n"Red";
	}

	/**
	 * Out-only: set then reset an &out TOptional<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Result Destination received as TOptional<FName>&out
	 * @Inputs Empty &out TOptional<FName>
	 * @Return void; Result is left unset
	 */
	UFUNCTION()
	void SetThenReset_FName(TOptional<FName>&out Result)
	{
		Result.Set(n"Red");
		Result.Reset();
	}

	/**
	 * Inout: reset an already-set TOptional<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Optional received as TOptional<FName>&inout, starts holding n"Red"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ResetSetState_FName(TOptional<FName>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Reset for bool: a stored false is cleared, not confused with unset.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs TOptional<bool> set to false; Reset()
	 * @Return true when IsSet() is false and Get(true) is true
	 */
	UFUNCTION()
	bool ResetUnsetsAndFallsBack_bool()
	{
		TOptional<bool> Opt;
		Opt.Set(false);
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		return !Opt.IsSet() && Opt.Get(true) == true;
	}

	/**
	 * In-only: confirm a const&in TOptional<bool> reports set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Source optional received as const TOptional<bool>&in
	 * @Inputs Value holds true
	 * @Return true when IsSet() is true and GetValue() is true
	 */
	UFUNCTION()
	bool ReadBeforeReset_bool(const TOptional<bool>&in Value)
	{
		return Value.IsSet() && Value.GetValue() == true;
	}

	/**
	 * Out-only: set then reset an &out TOptional<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Result Destination received as TOptional<bool>&out
	 * @Inputs Empty &out TOptional<bool>
	 * @Return void; Result is left unset
	 */
	UFUNCTION()
	void SetThenReset_bool(TOptional<bool>&out Result)
	{
		Result.Set(true);
		Result.Reset();
	}

	/**
	 * Inout: reset an already-set TOptional<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Optional received as TOptional<bool>&inout, starts holding true
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ResetSetState_bool(TOptional<bool>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Reset for FVector.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs TOptional<FVector> set to the X axis; Reset()
	 * @Return true when IsSet() is false and Get falls back to the Y axis
	 */
	UFUNCTION()
	bool ResetUnsetsAndFallsBack_FVector()
	{
		TOptional<FVector> Opt;
		Opt.Set(FVector(1.0f, 0.0f, 0.0f));
		Opt.Reset();
		return !Opt.IsSet()
			&& Opt.Get(FVector(0.0f, 1.0f, 0.0f)).Equals(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * In-only: confirm a const&in TOptional<FVector> reports set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Source optional received as const TOptional<FVector>&in
	 * @Inputs Value holds the X axis
	 * @Return true when IsSet() is true and GetValue() is the X axis
	 */
	UFUNCTION()
	bool ReadBeforeReset_FVector(const TOptional<FVector>&in Value)
	{
		return Value.IsSet() && Value.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
	}

	/**
	 * Out-only: set then reset an &out TOptional<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Result Destination received as TOptional<FVector>&out
	 * @Inputs Empty &out TOptional<FVector>
	 * @Return void; Result is left unset
	 */
	UFUNCTION()
	void SetThenReset_FVector(TOptional<FVector>&out Result)
	{
		Result.Set(FVector(1.0f, 0.0f, 0.0f));
		Result.Reset();
	}

	/**
	 * Inout: reset an already-set TOptional<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Optional received as TOptional<FVector>&inout, starts holding the X axis
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ResetSetState_FVector(TOptional<FVector>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Reset for UObject, including that a stored nullptr is cleared.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs TOptional<UObject> set to nullptr; Reset(); then set to an object and Reset again
	 * @Return true when IsSet() is false after both resets
	 */
	UFUNCTION()
	bool ResetUnsetsAndFallsBack_UObject()
	{
		TOptional<UObject> Opt;
		Opt = nullptr;
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		if (Opt.IsSet())
		{
			return false;
		}

		UObject First = NewObject(GetTransientPackage(), UTOptionalResetObject::StaticClass(), n"TOptionalReset_First", true);
		if (First == nullptr)
		{
			return false;
		}

		Opt.Set(First);
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		return !Opt.IsSet() && Opt.Get(nullptr) == nullptr;
	}

	/**
	 * In-only: confirm a const&in TOptional<UObject> reports set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Source optional received as const TOptional<UObject>&in
	 * @Inputs Value holds a non-null object
	 * @Return true when IsSet() is true and GetValue() is non-null
	 */
	UFUNCTION()
	bool ReadBeforeReset_UObject(const TOptional<UObject>&in Value)
	{
		return Value.IsSet() && Value.GetValue() != nullptr;
	}

	/**
	 * Out-only: set then reset an &out TOptional<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Result Destination received as TOptional<UObject>&out
	 * @Inputs Empty &out TOptional<UObject>
	 * @Return void; Result is left unset
	 */
	UFUNCTION()
	void SetThenReset_UObject(TOptional<UObject>&out Result)
	{
		Result.Set(NewObject(GetTransientPackage(), UTOptionalResetObject::StaticClass(), n"TOptionalReset_Fill", true));
		Result.Reset();
	}

	/**
	 * Inout: reset an already-set TOptional<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Optional received as TOptional<UObject>&inout, starts holding an object
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ResetSetState_UObject(TOptional<UObject>&inout Value)
	{
		Value.Reset();
	}
}
/** @end */
