/**
 * @version v1
 * @summary Composite positive: a TOptional<T> crossing a UFUNCTION boundary as a value, an out parameter, and a return value in one sequence, plus the unset-in / set-out direction that a "maybe missing" API actually uses. These are.
 * @topic Containers
 */
/**
 * @version root
 * @summary Composite positive: a TOptional<T> crossing a UFUNCTION boundary as a value, an out parameter, and a return value in one sequence, plus the unset-in / set-out direction that a "maybe missing" API actually uses. These are.
 * @topic Baseline
 */
namespace TOptionalTest
{
	/**
	 * Value-in / value-out: a set optional survives a call and comes back set.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.GetValue
	 * @Param Value Source optional received as const TOptional<int>&in
	 * @Inputs Value holds 42
	 * @Return true when the source is set and holds 42
	 */
	UFUNCTION()
	bool EchoSetOptional(const TOptional<int>&in Value)
	{
		return Value.IsSet() && Value.GetValue() == 42;
	}

	/**
	 * Unset-in: an unset optional crosses the boundary without throwing,
	 * as long as the body only asks IsSet / Get.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Get
	 * @Param Value Source optional received as const TOptional<int>&in, left unset
	 * @Inputs Value is unset
	 * @Return true when IsSet() is false and Get(7) yields 7
	 */
	UFUNCTION()
	bool EchoUnsetOptional(const TOptional<int>&in Value)
	{
		return !Value.IsSet() && Value.Get(7) == 7;
	}

	/**
	 * Build and return an optional: the "maybe result" direction, where the
	 * callee decides whether a value exists.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param bProduce Whether the callee should produce a value
	 * @Inputs bProduce true or false
	 * @Return a set TOptional<int> holding 42 when bProduce, otherwise unset
	 */
	UFUNCTION()
	TOptional<int> ProduceOptional(bool bProduce)
	{
		TOptional<int> Result;
		if (bProduce)
		{
			Result.Set(42);
		}
		return Result;
	}

	/**
	 * Consume a produced optional: both branches of the "maybe result" are
	 * observed through IsSet and Get, never through GetValue alone.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs ProduceOptional(true) and ProduceOptional(false)
	 * @Return true when the present branch reads 42 and the absent branch falls back to 7
	 */
	UFUNCTION()
	bool ConsumeProducedOptionalBothBranches()
	{
		TOptional<int> Present = ProduceOptional(true);
		if (!Present.IsSet() || Present.Get(7) != 42)
		{
			return false;
		}

		TOptional<int> Absent = ProduceOptional(false);
		return !Absent.IsSet() && Absent.Get(7) == 7;
	}

	/**
	 * Set-in / unset-out: a callee clears an optional passed by reference,
	 * and the caller observes the unset state afterwards.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Reset
	 * @Param Value Optional received as TOptional<int>&inout, starts holding 42
	 * @Inputs Value.IsSet() is true
	 * @Return void; Value is unset
	 */
	UFUNCTION()
	void ConsumeAndClear(TOptional<int>&inout Value)
	{
		Value.Reset();
	}
}
/** @end */
