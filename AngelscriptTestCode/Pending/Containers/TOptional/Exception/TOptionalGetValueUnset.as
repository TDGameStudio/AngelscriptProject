/**
 * @version v1
 * @summary GetValue throws when the optional is unset. IsSet() is the guard; Get() with a fallback is the non-throwing alternative and lives in ../Function/. This module compiles; each entry is a RuntimeException trigger, not a.
 * @topic Containers
 */
/**
 * @version root
 * @summary GetValue throws when the optional is unset. IsSet() is the guard; Get() with a fallback is the non-throwing alternative and lives in ../Function/. This module compiles; each entry is a RuntimeException trigger, not a.
 * @topic Baseline
 */
namespace TOptionalTest
{
	/**
	 * Read GetValue on a default-constructed optional throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<int>; GetValue()
	 * @Return does not return; throws "GetValue() called on Optional when not set! Check the optional with IsSet() first."
	 * @Boundary unset optional
	 */
	UFUNCTION()
	int ReadUnset()
	{
		TOptional<int> Opt;
		return Opt.GetValue();
	}

	/**
	 * Read GetValue after Reset throws; the value is gone, not zeroed.
	 *
	 * @Kind RuntimeException
	 * @Covers TOptional.GetValue
	 * @Inputs TOptional<int> set to 42; Reset(); GetValue()
	 * @Return does not return; throws "GetValue() called on Optional when not set! Check the optional with IsSet() first."
	 * @Boundary reset optional
	 */
	UFUNCTION()
	int ReadAfterReset()
	{
		TOptional<int> Opt;
		Opt.Set(42);
		Opt.Reset();
		return Opt.GetValue();
	}

	/**
	 * Read GetValue on an optional that was assigned an unset optional throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TOptional.GetValue
	 * @Inputs Target set to 42; assign an unset optional onto it; GetValue()
	 * @Return does not return; throws "GetValue() called on Optional when not set! Check the optional with IsSet() first."
	 * @Boundary unset state propagated by opAssign
	 */
	UFUNCTION()
	int ReadAfterAssigningUnset()
	{
		TOptional<int> Target;
		Target.Set(42);

		TOptional<int> Unset;
		Target = Unset;
		return Target.GetValue();
	}

	/**
	 * Read GetValue on an unset TOptional<FString> throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<FString>; GetValue()
	 * @Return does not return; throws "GetValue() called on Optional when not set! Check the optional with IsSet() first."
	 * @Boundary unset optional, non-trivial element type
	 */
	UFUNCTION()
	FString ReadUnsetFString()
	{
		TOptional<FString> Opt;
		return Opt.GetValue();
	}

	/**
	 * Read GetValue on an unset TOptional<FVector> throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TOptional.GetValue
	 * @Inputs Default-constructed TOptional<FVector>; GetValue()
	 * @Return does not return; throws "GetValue() called on Optional when not set! Check the optional with IsSet() first."
	 * @Boundary unset optional, struct element type
	 */
	UFUNCTION()
	FVector ReadUnsetFVector()
	{
		TOptional<FVector> Opt;
		return Opt.GetValue();
	}
}
/** @end */
