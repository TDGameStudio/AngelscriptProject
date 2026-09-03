/**
 * TOptional.IsSet reports presence, which is tracked independently of the
 * stored value. Set()/opAssign flip it on, Reset() flips it off, and
 * opAssign from an unset optional propagates the unset state.
 * int is canonical; other element shapes repeat the same four entries with
 * a type suffix.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.IsSet
 * @Harness Function
 * @Tag Containers.TOptional.TOptionalIsSet
 * @Namespace TOptionalTest
 */

UCLASS()
class UTOptionalIsSetObject : UObject
{
}

namespace TOptionalTest
{
	/**
	 * Observe IsSet across the set/unset lifecycle.
	 *
	 * @Kind Observe
	 * @Covers TOptional.IsSet
	 * @Inputs Default-constructed TOptional<int>; assign 5; Reset; assign again
	 * @Return true when IsSet() tracks each transition
	 */
	UFUNCTION()
	bool IsSetTracksAssignAndReset()
	{
		TOptional<int> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt = 5;
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		if (Opt.IsSet())
		{
			return false;
		}

		Opt = 9;
		return Opt.IsSet();
	}

	/**
	 * Observe that storing the default value of int still reports set.
	 *
	 * @Kind Observe
	 * @Covers TOptional.IsSet
	 * @Inputs Default-constructed TOptional<int>; assign 0
	 * @Return true when IsSet() is true for a stored 0
	 */
	UFUNCTION()
	bool IsSetTrueForStoredZero()
	{
		TOptional<int> Opt;
		Opt = 0;
		return Opt.IsSet();
	}

	/**
	 * In-only: read the presence of a const&in TOptional<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Source optional received as const TOptional<int>&in
	 * @Inputs Value holds 5
	 * @Return true when IsSet() is true
	 */
	UFUNCTION()
	bool ReadIsSet(const TOptional<int>&in Value)
	{
		return Value.IsSet();
	}

	/**
	 * Out-only: mark an empty &out TOptional<int> as set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Result Destination received as TOptional<int>&out
	 * @Inputs Empty &out TOptional<int>
	 * @Return void; Result is set
	 */
	UFUNCTION()
	void FillAndMarkSet(TOptional<int>&out Result)
	{
		Result.Set(5);
	}

	/**
	 * Inout: unset an already-set TOptional<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Optional received as TOptional<int>&inout, starts set
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ClearSetState(TOptional<int>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe IsSet across the set/unset lifecycle for FString.
	 *
	 * @Kind Observe
	 * @Covers TOptional.IsSet
	 * @Inputs Default-constructed TOptional<FString>; assign "alpha"; Reset
	 * @Return true when IsSet() tracks each transition
	 */
	UFUNCTION()
	bool IsSetTracksAssignAndReset_FString()
	{
		TOptional<FString> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt = "alpha";
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		return !Opt.IsSet();
	}

	/**
	 * Observe that storing an empty string still reports set.
	 *
	 * @Kind Observe
	 * @Covers TOptional.IsSet
	 * @Inputs Default-constructed TOptional<FString>; assign ""
	 * @Return true when IsSet() is true for a stored empty string
	 */
	UFUNCTION()
	bool IsSetTrueForStoredEmptyString_FString()
	{
		TOptional<FString> Opt;
		Opt = "";
		return Opt.IsSet();
	}

	/**
	 * In-only: read the presence of a const&in TOptional<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Source optional received as const TOptional<FString>&in
	 * @Inputs Value holds "alpha"
	 * @Return true when IsSet() is true
	 */
	UFUNCTION()
	bool ReadIsSet_FString(const TOptional<FString>&in Value)
	{
		return Value.IsSet();
	}

	/**
	 * Out-only: mark an empty &out TOptional<FString> as set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Result Destination received as TOptional<FString>&out
	 * @Inputs Empty &out TOptional<FString>
	 * @Return void; Result is set
	 */
	UFUNCTION()
	void FillAndMarkSet_FString(TOptional<FString>&out Result)
	{
		Result.Set("alpha");
	}

	/**
	 * Inout: unset an already-set TOptional<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Optional received as TOptional<FString>&inout, starts set
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ClearSetState_FString(TOptional<FString>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe IsSet across the set/unset lifecycle for FName.
	 *
	 * @Kind Observe
	 * @Covers TOptional.IsSet
	 * @Inputs Default-constructed TOptional<FName>; assign n"Red"; Reset
	 * @Return true when IsSet() tracks each transition
	 */
	UFUNCTION()
	bool IsSetTracksAssignAndReset_FName()
	{
		TOptional<FName> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt = n"Red";
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		return !Opt.IsSet();
	}

	/**
	 * In-only: read the presence of a const&in TOptional<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Source optional received as const TOptional<FName>&in
	 * @Inputs Value holds n"Red"
	 * @Return true when IsSet() is true
	 */
	UFUNCTION()
	bool ReadIsSet_FName(const TOptional<FName>&in Value)
	{
		return Value.IsSet();
	}

	/**
	 * Out-only: mark an empty &out TOptional<FName> as set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Result Destination received as TOptional<FName>&out
	 * @Inputs Empty &out TOptional<FName>
	 * @Return void; Result is set
	 */
	UFUNCTION()
	void FillAndMarkSet_FName(TOptional<FName>&out Result)
	{
		Result.Set(n"Red");
	}

	/**
	 * Inout: unset an already-set TOptional<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Optional received as TOptional<FName>&inout, starts set
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ClearSetState_FName(TOptional<FName>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe IsSet across the set/unset lifecycle for bool.
	 *
	 * @Kind Observe
	 * @Covers TOptional.IsSet
	 * @Inputs Default-constructed TOptional<bool>; assign false; Reset; assign true
	 * @Return true when IsSet() tracks each transition
	 */
	UFUNCTION()
	bool IsSetTracksAssignAndReset_bool()
	{
		TOptional<bool> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt = false;
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		if (Opt.IsSet())
		{
			return false;
		}

		Opt = true;
		return Opt.IsSet();
	}

	/**
	 * In-only: read the presence of a const&in TOptional<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Source optional received as const TOptional<bool>&in
	 * @Inputs Value holds true
	 * @Return true when IsSet() is true
	 */
	UFUNCTION()
	bool ReadIsSet_bool(const TOptional<bool>&in Value)
	{
		return Value.IsSet();
	}

	/**
	 * Out-only: mark an empty &out TOptional<bool> as set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Result Destination received as TOptional<bool>&out
	 * @Inputs Empty &out TOptional<bool>
	 * @Return void; Result is set
	 */
	UFUNCTION()
	void FillAndMarkSet_bool(TOptional<bool>&out Result)
	{
		Result.Set(true);
	}

	/**
	 * Inout: unset an already-set TOptional<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Optional received as TOptional<bool>&inout, starts set
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ClearSetState_bool(TOptional<bool>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe IsSet across the set/unset lifecycle for FVector.
	 *
	 * @Kind Observe
	 * @Covers TOptional.IsSet
	 * @Inputs Default-constructed TOptional<FVector>; assign zero vector; Reset
	 * @Return true when IsSet() tracks each transition
	 */
	UFUNCTION()
	bool IsSetTracksAssignAndReset_FVector()
	{
		TOptional<FVector> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

		Opt = FVector(0.0f, 0.0f, 0.0f);
		if (!Opt.IsSet())
		{
			return false;
		}

		Opt.Reset();
		return !Opt.IsSet();
	}

	/**
	 * In-only: read the presence of a const&in TOptional<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Source optional received as const TOptional<FVector>&in
	 * @Inputs Value holds the X axis
	 * @Return true when IsSet() is true
	 */
	UFUNCTION()
	bool ReadIsSet_FVector(const TOptional<FVector>&in Value)
	{
		return Value.IsSet();
	}

	/**
	 * Out-only: mark an empty &out TOptional<FVector> as set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Result Destination received as TOptional<FVector>&out
	 * @Inputs Empty &out TOptional<FVector>
	 * @Return void; Result is set
	 */
	UFUNCTION()
	void FillAndMarkSet_FVector(TOptional<FVector>&out Result)
	{
		Result.Set(FVector(1.0f, 0.0f, 0.0f));
	}

	/**
	 * Inout: unset an already-set TOptional<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Optional received as TOptional<FVector>&inout, starts set
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ClearSetState_FVector(TOptional<FVector>&inout Value)
	{
		Value.Reset();
	}


	/**
	 * Observe IsSet for UObject, including that a stored nullptr counts as set.
	 *
	 * @Kind Observe
	 * @Covers TOptional.IsSet
	 * @Inputs Default-constructed TOptional<UObject>; assign nullptr; assign an object; Reset
	 * @Return true when IsSet() tracks each transition
	 */
	UFUNCTION()
	bool IsSetTracksAssignAndReset_UObject()
	{
		TOptional<UObject> Opt;
		if (Opt.IsSet())
		{
			return false;
		}

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

		UObject First = NewObject(GetTransientPackage(), UTOptionalIsSetObject::StaticClass(), n"TOptionalIsSet_First", true);
		if (First == nullptr)
		{
			return false;
		}

		Opt = First;
		return Opt.IsSet();
	}

	/**
	 * In-only: read the presence of a const&in TOptional<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Source optional received as const TOptional<UObject>&in
	 * @Inputs Value holds a non-null object
	 * @Return true when IsSet() is true
	 */
	UFUNCTION()
	bool ReadIsSet_UObject(const TOptional<UObject>&in Value)
	{
		return Value.IsSet();
	}

	/**
	 * Out-only: mark an empty &out TOptional<UObject> as set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Result Destination received as TOptional<UObject>&out
	 * @Inputs Empty &out TOptional<UObject>
	 * @Return void; Result is set
	 */
	UFUNCTION()
	void FillAndMarkSet_UObject(TOptional<UObject>&out Result)
	{
		Result.Set(NewObject(GetTransientPackage(), UTOptionalIsSetObject::StaticClass(), n"TOptionalIsSet_Fill", true));
	}

	/**
	 * Inout: unset an already-set TOptional<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.IsSet
	 * @Param Value Optional received as TOptional<UObject>&inout, starts set
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ClearSetState_UObject(TOptional<UObject>&inout Value)
	{
		Value.Reset();
	}
}
