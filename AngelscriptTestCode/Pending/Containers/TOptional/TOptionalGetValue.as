/**
 * @version v1
 * @summary TOptional.GetValue returns a reference to the contained value. The const and non-const overloads share one entry point; the non-const one is observed by mutating through the returned reference. Reading an unset optional.
 * @topic Containers
 */
/**
 * @version root
 * @summary TOptional.GetValue returns a reference to the contained value. The const and non-const overloads share one entry point; the non-const one is observed by mutating through the returned reference. Reading an unset optional.
 * @topic Baseline
 */
UCLASS()
class UTOptionalGetValueObject : UObject
{
}

namespace TOptionalTest
{
	/**
	 * Observe GetValue: it returns the stored value after a set.
	 *
	 * @Kind Observe
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<int>; Set(5)
	 * @Return true when GetValue() is 5
	 */
	UFUNCTION()
	bool GetValueReturnsStoredValue()
	{
		TOptional<int> Opt;
		Opt.Set(5);
		return Opt.GetValue() == 5;
	}

	/**
	 * Observe the non-const overload: mutating through GetValue() writes
	 * through into the optional, not into a copy.
	 *
	 * @Kind Observe
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<int>; Set(5); GetValue() = 11
	 * @Return true when a later GetValue() observes 11
	 */
	UFUNCTION()
	bool NonConstGetValueMutatesInPlace()
	{
		TOptional<int> Opt;
		Opt.Set(5);
		Opt.GetValue() = 11;
		return Opt.GetValue() == 11;
	}

	/**
	 * In-only: read the value out of a const&in TOptional<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Source optional received as const TOptional<int>&in
	 * @Inputs Value holds 5
	 * @Return true when GetValue() is 5
	 */
	UFUNCTION()
	bool ReadStoredValue(const TOptional<int>&in Value)
	{
		return Value.GetValue() == 5;
	}

	/**
	 * Out-only: store into an empty &out TOptional<int> so the caller can GetValue it.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Result Destination received as TOptional<int>&out
	 * @Inputs Empty &out TOptional<int>
	 * @Return void; Result holds 5
	 */
	UFUNCTION()
	void FillForGetValue(TOptional<int>&out Result)
	{
		Result.Set(5);
	}

	/**
	 * Inout: rewrite the value read through GetValue() on an existing optional.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Optional received as TOptional<int>&inout, starts holding 5
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds 11
	 */
	UFUNCTION()
	void MutateThroughGetValue(TOptional<int>&inout Value)
	{
		Value.GetValue() = 11;
	}


	/**
	 * Observe GetValue for FString.
	 *
	 * @Kind Observe
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<FString>; Set("alpha")
	 * @Return true when GetValue() is "alpha"
	 */
	UFUNCTION()
	bool GetValueReturnsStoredValue_FString()
	{
		TOptional<FString> Opt;
		Opt.Set("alpha");
		return Opt.GetValue() == "alpha";
	}

	/**
	 * Observe the non-const overload for FString: assignment through GetValue writes through.
	 *
	 * @Kind Observe
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<FString>; Set("alpha"); GetValue() = "beta"
	 * @Return true when a later GetValue() observes "beta"
	 */
	UFUNCTION()
	bool NonConstGetValueMutatesInPlace_FString()
	{
		TOptional<FString> Opt;
		Opt.Set("alpha");
		Opt.GetValue() = "beta";
		return Opt.GetValue() == "beta";
	}

	/**
	 * In-only: read the value out of a const&in TOptional<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Source optional received as const TOptional<FString>&in
	 * @Inputs Value holds "alpha"
	 * @Return true when GetValue() is "alpha"
	 */
	UFUNCTION()
	bool ReadStoredValue_FString(const TOptional<FString>&in Value)
	{
		return Value.GetValue() == "alpha";
	}

	/**
	 * Out-only: store into an empty &out TOptional<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Result Destination received as TOptional<FString>&out
	 * @Inputs Empty &out TOptional<FString>
	 * @Return void; Result holds "alpha"
	 */
	UFUNCTION()
	void FillForGetValue_FString(TOptional<FString>&out Result)
	{
		Result.Set("alpha");
	}

	/**
	 * Inout: rewrite the value read through GetValue().
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Optional received as TOptional<FString>&inout, starts holding "alpha"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds "beta"
	 */
	UFUNCTION()
	void MutateThroughGetValue_FString(TOptional<FString>&inout Value)
	{
		Value.GetValue() = "beta";
	}


	/**
	 * Observe GetValue for FName.
	 *
	 * @Kind Observe
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<FName>; Set(n"Red")
	 * @Return true when GetValue() is n"Red"
	 */
	UFUNCTION()
	bool GetValueReturnsStoredValue_FName()
	{
		TOptional<FName> Opt;
		Opt.Set(n"Red");
		return Opt.GetValue() == n"Red";
	}

	/**
	 * In-only: read the value out of a const&in TOptional<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Source optional received as const TOptional<FName>&in
	 * @Inputs Value holds n"Red"
	 * @Return true when GetValue() is n"Red"
	 */
	UFUNCTION()
	bool ReadStoredValue_FName(const TOptional<FName>&in Value)
	{
		return Value.GetValue() == n"Red";
	}

	/**
	 * Out-only: store into an empty &out TOptional<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Result Destination received as TOptional<FName>&out
	 * @Inputs Empty &out TOptional<FName>
	 * @Return void; Result holds n"Red"
	 */
	UFUNCTION()
	void FillForGetValue_FName(TOptional<FName>&out Result)
	{
		Result.Set(n"Red");
	}

	/**
	 * Inout: rewrite the value read through GetValue().
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Optional received as TOptional<FName>&inout, starts holding n"Red"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds n"Green"
	 */
	UFUNCTION()
	void MutateThroughGetValue_FName(TOptional<FName>&inout Value)
	{
		Value.GetValue() = n"Green";
	}


	/**
	 * Observe GetValue for bool, including that a stored false reads back as false.
	 *
	 * @Kind Observe
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<bool>; Set(false)
	 * @Return true when GetValue() is false while IsSet() is true
	 */
	UFUNCTION()
	bool GetValueReturnsStoredValue_bool()
	{
		TOptional<bool> Opt;
		Opt.Set(false);
		return Opt.IsSet() && Opt.GetValue() == false;
	}

	/**
	 * In-only: read the value out of a const&in TOptional<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Source optional received as const TOptional<bool>&in
	 * @Inputs Value holds true
	 * @Return true when GetValue() is true
	 */
	UFUNCTION()
	bool ReadStoredValue_bool(const TOptional<bool>&in Value)
	{
		return Value.GetValue() == true;
	}

	/**
	 * Out-only: store into an empty &out TOptional<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Result Destination received as TOptional<bool>&out
	 * @Inputs Empty &out TOptional<bool>
	 * @Return void; Result holds true
	 */
	UFUNCTION()
	void FillForGetValue_bool(TOptional<bool>&out Result)
	{
		Result.Set(true);
	}

	/**
	 * Inout: flip the value read through GetValue().
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Optional received as TOptional<bool>&inout, starts holding true
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds false
	 */
	UFUNCTION()
	void MutateThroughGetValue_bool(TOptional<bool>&inout Value)
	{
		Value.GetValue() = false;
	}


	/**
	 * Observe GetValue for FVector.
	 *
	 * @Kind Observe
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<FVector>; Set(X axis)
	 * @Return true when GetValue() equals the X axis
	 */
	UFUNCTION()
	bool GetValueReturnsStoredValue_FVector()
	{
		TOptional<FVector> Opt;
		Opt.Set(FVector(1.0f, 0.0f, 0.0f));
		return Opt.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
	}

	/**
	 * In-only: read the value out of a const&in TOptional<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Source optional received as const TOptional<FVector>&in
	 * @Inputs Value holds the X axis
	 * @Return true when GetValue() equals the X axis
	 */
	UFUNCTION()
	bool ReadStoredValue_FVector(const TOptional<FVector>&in Value)
	{
		return Value.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
	}

	/**
	 * Out-only: store into an empty &out TOptional<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Result Destination received as TOptional<FVector>&out
	 * @Inputs Empty &out TOptional<FVector>
	 * @Return void; Result holds the X axis
	 */
	UFUNCTION()
	void FillForGetValue_FVector(TOptional<FVector>&out Result)
	{
		Result.Set(FVector(1.0f, 0.0f, 0.0f));
	}

	/**
	 * Inout: rewrite the value read through GetValue().
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Optional received as TOptional<FVector>&inout, starts holding the X axis
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds the Y axis
	 */
	UFUNCTION()
	void MutateThroughGetValue_FVector(TOptional<FVector>&inout Value)
	{
		Value.GetValue() = FVector(0.0f, 1.0f, 0.0f);
	}


	/**
	 * Observe GetValue for UObject: it returns the same pointer that was stored.
	 *
	 * @Kind Observe
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<UObject>; Set(object created via NewObject)
	 * @Return true when GetValue() is that same non-null object
	 */
	UFUNCTION()
	bool GetValueReturnsStoredValue_UObject()
	{
		TOptional<UObject> Opt;
		UObject First = NewObject(GetTransientPackage(), UTOptionalGetValueObject::StaticClass(), n"TOptionalGetValue_First", true);
		if (First == nullptr)
		{
			return false;
		}

		Opt.Set(First);
		return Opt.IsSet() && Opt.GetValue() == First;
	}

	/**
	 * In-only: read the value out of a const&in TOptional<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Source optional received as const TOptional<UObject>&in
	 * @Inputs Value holds a non-null object
	 * @Return true when GetValue() is non-null
	 */
	UFUNCTION()
	bool ReadStoredValue_UObject(const TOptional<UObject>&in Value)
	{
		return Value.GetValue() != nullptr;
	}

	/**
	 * Out-only: store into an empty &out TOptional<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Result Destination received as TOptional<UObject>&out
	 * @Inputs Empty &out TOptional<UObject>
	 * @Return void; Result holds a non-null object
	 */
	UFUNCTION()
	void FillForGetValue_UObject(TOptional<UObject>&out Result)
	{
		Result.Set(NewObject(GetTransientPackage(), UTOptionalGetValueObject::StaticClass(), n"TOptionalGetValue_Fill", true));
	}

	/**
	 * Inout: replace the pointer read through GetValue().
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Optional received as TOptional<UObject>&inout, starts holding an object
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value holds a different non-null object
	 */
	UFUNCTION()
	void MutateThroughGetValue_UObject(TOptional<UObject>&inout Value)
	{
		Value.GetValue() = NewObject(GetTransientPackage(), UTOptionalGetValueObject::StaticClass(), n"TOptionalGetValue_Replace", true);
	}
}
/** @end */
