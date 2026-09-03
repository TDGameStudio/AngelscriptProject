/**
 * TOptional.Get returns the contained value when set and the supplied
 * fallback when unset. Unlike GetValue it never throws, so the unset path
 * is a legal Observe here rather than an Exception entry.
 * int is canonical; other element shapes repeat the same four entries with
 * a type suffix.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.Get
 * @Harness Function
 * @Tag Containers.TOptional.TOptionalGet
 * @Namespace TOptionalTest
 */

UCLASS()
class UTOptionalGetObject : UObject
{
}

namespace TOptionalTest
{
	/**
	 * Observe Get: a set optional returns its value and ignores the fallback.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs TOptional<int> set to 42; Get(7)
	 * @Return true when Get(7) is 42
	 */
	UFUNCTION()
	bool GetReturnsValueWhenSet()
	{
		TOptional<int> Opt;
		Opt.Set(42);
		return Opt.Get(7) == 42;
	}

	/**
	 * Observe Get: an unset optional returns the fallback instead of throwing.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs Default-constructed TOptional<int>; Get(7)
	 * @Return true when Get(7) is 7 and the optional is still unset
	 */
	UFUNCTION()
	bool GetReturnsFallbackWhenUnset()
	{
		TOptional<int> Opt;
		bool bResult = Opt.Get(7) == 7;
		return bResult && !Opt.IsSet();
	}

	/**
	 * Observe Get after Reset: the fallback is returned once the value is gone.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs TOptional<int> set to 42; Reset(); Get(7)
	 * @Return true when Get(7) is 7 after the reset
	 */
	UFUNCTION()
	bool GetReturnsFallbackAfterReset()
	{
		TOptional<int> Opt;
		Opt.Set(42);
		Opt.Reset();
		return Opt.Get(7) == 7;
	}

	/**
	 * In-only: read through Get on a const&in TOptional<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Source optional received as const TOptional<int>&in
	 * @Inputs Value holds 42
	 * @Return true when Get(7) is 42
	 */
	UFUNCTION()
	bool ReadThroughGet(const TOptional<int>&in Value)
	{
		return Value.Get(7) == 42;
	}

	/**
	 * Out-only: leave the &out unset so the caller sees the fallback branch.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Result Destination received as TOptional<int>&out
	 * @Inputs Empty &out TOptional<int>
	 * @Return void; Result is left unset on purpose
	 */
	UFUNCTION()
	void LeaveUnsetForFallback(TOptional<int>&out Result)
	{
		Result.Reset();
	}

	/**
	 * Inout: replace a set optional with an unset one so Get falls back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Optional received as TOptional<int>&inout, starts holding 42
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset and Get(7) yields 7
	 */
	UFUNCTION()
	void UnsetForFallback(TOptional<int>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Get for FString: set returns the value, unset returns the fallback.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs One TOptional<FString> set to "alpha"; one default-constructed
	 * @Return true when the set one reads "alpha" and the unset one reads "fallback"
	 */
	UFUNCTION()
	bool GetReturnsValueOrFallback_FString()
	{
		TOptional<FString> Set;
		Set.Set("alpha");

		TOptional<FString> Unset;
		return Set.Get("fallback") == "alpha"
			&& Unset.Get("fallback") == "fallback";
	}

	/**
	 * In-only: read through Get on a const&in TOptional<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Source optional received as const TOptional<FString>&in
	 * @Inputs Value holds "alpha"
	 * @Return true when Get("fallback") is "alpha"
	 */
	UFUNCTION()
	bool ReadThroughGet_FString(const TOptional<FString>&in Value)
	{
		return Value.Get("fallback") == "alpha";
	}

	/**
	 * Out-only: leave the &out unset so the caller sees the fallback branch.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Result Destination received as TOptional<FString>&out
	 * @Inputs Empty &out TOptional<FString>
	 * @Return void; Result is left unset on purpose
	 */
	UFUNCTION()
	void LeaveUnsetForFallback_FString(TOptional<FString>&out Result)
	{
		Result.Reset();
	}

	/**
	 * Inout: replace a set optional with an unset one so Get falls back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Optional received as TOptional<FString>&inout, starts holding "alpha"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void UnsetForFallback_FString(TOptional<FString>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Get for FName: set returns the value, unset returns the fallback.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs One TOptional<FName> set to n"Red"; one default-constructed
	 * @Return true when the set one reads n"Red" and the unset one reads n"Fallback"
	 */
	UFUNCTION()
	bool GetReturnsValueOrFallback_FName()
	{
		TOptional<FName> Set;
		Set.Set(n"Red");

		TOptional<FName> Unset;
		return Set.Get(n"Fallback") == n"Red"
			&& Unset.Get(n"Fallback") == n"Fallback";
	}

	/**
	 * In-only: read through Get on a const&in TOptional<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Source optional received as const TOptional<FName>&in
	 * @Inputs Value holds n"Red"
	 * @Return true when Get(n"Fallback") is n"Red"
	 */
	UFUNCTION()
	bool ReadThroughGet_FName(const TOptional<FName>&in Value)
	{
		return Value.Get(n"Fallback") == n"Red";
	}

	/**
	 * Out-only: leave the &out unset so the caller sees the fallback branch.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Result Destination received as TOptional<FName>&out
	 * @Inputs Empty &out TOptional<FName>
	 * @Return void; Result is left unset on purpose
	 */
	UFUNCTION()
	void LeaveUnsetForFallback_FName(TOptional<FName>&out Result)
	{
		Result.Reset();
	}

	/**
	 * Inout: replace a set optional with an unset one so Get falls back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Optional received as TOptional<FName>&inout, starts holding n"Red"
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void UnsetForFallback_FName(TOptional<FName>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Get for bool: a stored false is returned, not the fallback true.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs One TOptional<bool> set to false; one default-constructed
	 * @Return true when the set one reads false and the unset one reads true
	 */
	UFUNCTION()
	bool GetReturnsValueOrFallback_bool()
	{
		TOptional<bool> Set;
		Set.Set(false);

		TOptional<bool> Unset;
		return Set.Get(true) == false
			&& Unset.Get(true) == true;
	}

	/**
	 * In-only: read through Get on a const&in TOptional<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Source optional received as const TOptional<bool>&in
	 * @Inputs Value holds true
	 * @Return true when Get(false) is true
	 */
	UFUNCTION()
	bool ReadThroughGet_bool(const TOptional<bool>&in Value)
	{
		return Value.Get(false) == true;
	}

	/**
	 * Out-only: store false so Get returns the stored false rather than the fallback.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Result Destination received as TOptional<bool>&out
	 * @Inputs Empty &out TOptional<bool>
	 * @Return void; Result holds false
	 */
	UFUNCTION()
	void StoreFalseForGet_bool(TOptional<bool>&out Result)
	{
		Result.Set(false);
	}

	/**
	 * Inout: unset the optional so Get falls back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Optional received as TOptional<bool>&inout, starts holding true
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void UnsetForFallback_bool(TOptional<bool>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Get for FVector: set returns the value, unset returns the fallback.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs One TOptional<FVector> set to the X axis; one default-constructed
	 * @Return true when the set one reads the X axis and the unset one reads the Y axis
	 */
	UFUNCTION()
	bool GetReturnsValueOrFallback_FVector()
	{
		TOptional<FVector> Set;
		Set.Set(FVector(1.0f, 0.0f, 0.0f));

		TOptional<FVector> Unset;
		return Set.Get(FVector(0.0f, 1.0f, 0.0f)).Equals(FVector(1.0f, 0.0f, 0.0f))
			&& Unset.Get(FVector(0.0f, 1.0f, 0.0f)).Equals(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * In-only: read through Get on a const&in TOptional<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Source optional received as const TOptional<FVector>&in
	 * @Inputs Value holds the X axis
	 * @Return true when Get(Y axis) is the X axis
	 */
	UFUNCTION()
	bool ReadThroughGet_FVector(const TOptional<FVector>&in Value)
	{
		return Value.Get(FVector(0.0f, 1.0f, 0.0f)).Equals(FVector(1.0f, 0.0f, 0.0f));
	}

	/**
	 * Out-only: leave the &out unset so the caller sees the fallback branch.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Result Destination received as TOptional<FVector>&out
	 * @Inputs Empty &out TOptional<FVector>
	 * @Return void; Result is left unset on purpose
	 */
	UFUNCTION()
	void LeaveUnsetForFallback_FVector(TOptional<FVector>&out Result)
	{
		Result.Reset();
	}

	/**
	 * Inout: unset the optional so Get falls back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Optional received as TOptional<FVector>&inout, starts holding the X axis
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void UnsetForFallback_FVector(TOptional<FVector>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe Get for UObject: set returns the stored pointer, unset returns the fallback.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs One TOptional<UObject> set to First; one default-constructed
	 * @Return true when the set one reads First and the unset one reads the fallback object
	 */
	UFUNCTION()
	bool GetReturnsValueOrFallback_UObject()
	{
		UObject First = NewObject(GetTransientPackage(), UTOptionalGetObject::StaticClass(), n"TOptionalGet_First", true);
		UObject Fallback = NewObject(GetTransientPackage(), UTOptionalGetObject::StaticClass(), n"TOptionalGet_Fallback", true);
		if (First == nullptr || Fallback == nullptr || First == Fallback)
		{
			return false;
		}

		TOptional<UObject> Set;
		Set.Set(First);

		TOptional<UObject> Unset;
		return Set.Get(Fallback) == First
			&& Unset.Get(Fallback) == Fallback;
	}

	/**
	 * In-only: read through Get on a const&in TOptional<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Source optional received as const TOptional<UObject>&in
	 * @Inputs Value holds a non-null object
	 * @Return true when Get(nullptr) is non-null
	 */
	UFUNCTION()
	bool ReadThroughGet_UObject(const TOptional<UObject>&in Value)
	{
		return Value.Get(nullptr) != nullptr;
	}

	/**
	 * Out-only: leave the &out unset so the caller sees the fallback branch.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Result Destination received as TOptional<UObject>&out
	 * @Inputs Empty &out TOptional<UObject>
	 * @Return void; Result is left unset on purpose
	 */
	UFUNCTION()
	void LeaveUnsetForFallback_UObject(TOptional<UObject>&out Result)
	{
		Result.Reset();
	}

	/**
	 * Inout: unset the optional so Get falls back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Optional received as TOptional<UObject>&inout, starts holding an object
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void UnsetForFallback_UObject(TOptional<UObject>&inout Value)
	{
		Value.Reset();
	}
}
