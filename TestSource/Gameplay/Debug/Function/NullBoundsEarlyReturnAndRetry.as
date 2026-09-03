/**
 * The null, bounds, early-return and retry fallback patterns, each observed through the
 * value it produces. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this
 * and executes each entrypoint expecting its fallback, so this is a value oracle.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.NullBoundsEarlyReturnAndRetry
 * @Harness Function
 * @Tag Gameplay.Debug.NullBoundsEarlyReturnAndRetry
 * @Namespace DebugTest
 * @Provenance Theme: Gameplay.Debug. Value oracle: null/range/early-return/retry fallbacks.
 * @Provenance C++: AngelscriptCoverageErrorHandlingTests.cpp::NullBoundsEarlyReturnAndRetry
 * @Provenance CSV NegativeDiagnostic; C++ compiles. SafeNullActorNameLength 0;
 * @Provenance EarlyReturnRejectsInvalidState -10; RetryPattern 3; DefensivePatternSummary 9.
 * @Provenance Extra: empty array default 7; EarlyReturnPattern(10) identity; (11) caps at 10.
 * @Provenance DefaultSafe.
 */

namespace DebugTest
{
	/**
	 * Read an actor's name length, falling back to 0 when the handle is null.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs an actor handle, which may be null
	 * @Return the name length, or 0 when the handle is null
	 * @Param Actor the actor to inspect
	 * @Boundary null actor
	 */
	UFUNCTION()
	int SafeActorNameLength(AActor Actor)
	{
		if (Actor == nullptr)
		{
			return 0;
		}

		return Actor.GetName().ToString().Len();
	}

	/**
	 * The entrypoint C++ executes for the null fallback.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs none
	 * @Return 0, the fallback for a null actor
	 * @Boundary null actor
	 */
	UFUNCTION()
	int SafeNullActorNameLength()
	{
		return SafeActorNameLength(nullptr);
	}

	/**
	 * Read an array element, falling back to a caller-supplied default when the index is
	 * out of range.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs an array, an index and the fallback value
	 * @Return the element, or the fallback when the index is out of range
	 * @Param Values the array to read
	 * @Param Index the index to read
	 * @Param DefaultValue the value returned when the index is out of range
	 * @Boundary out-of-range index
	 */
	UFUNCTION()
	int SafeArrayRead(const TArray<int>&in Values, int Index, int DefaultValue)
	{
		if (!Values.IsValidIndex(Index))
		{
			return DefaultValue;
		}

		return Values[Index];
	}

	/**
	 * Report whether a state value counts as ready.
	 *
	 * @Kind Helper
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs a state value
	 * @Return true when the state is above zero
	 * @Param State the state value to classify
	 * @Boundary zero state
	 */
	UFUNCTION()
	bool IsReady(int State)
	{
		return State > 0;
	}

	/**
	 * Return early on an unready state and cap anything above ten.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs a state value
	 * @Return -10 when unready, 10 when above ten, otherwise the state itself
	 * @Param State the state value to pass through
	 * @Boundary unready state and the cap at ten
	 */
	UFUNCTION()
	int EarlyReturnPattern(int State)
	{
		if (!IsReady(State))
		{
			return -10;
		}

		if (State > 10)
		{
			return 10;
		}

		return State;
	}

	/**
	 * The entrypoint C++ executes for the early-return fallback.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs none
	 * @Return -10, the early-return value for state 0
	 * @Boundary unready state
	 */
	UFUNCTION()
	int EarlyReturnRejectsInvalidState()
	{
		return EarlyReturnPattern(0);
	}

	/**
	 * Report whether an attempt number has reached the retry threshold.
	 *
	 * @Kind Helper
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs an attempt number
	 * @Return true from the third attempt onwards
	 * @Param Attempt the attempt number, starting at 1
	 * @Boundary the third attempt
	 */
	UFUNCTION()
	bool TryOperation(int Attempt)
	{
		return Attempt >= 3;
	}

	/**
	 * Retry until the operation succeeds, giving up after five attempts.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs none
	 * @Return the attempt that succeeded, or -1 when all five failed
	 */
	UFUNCTION()
	int RetryPattern()
	{
		for (int Attempt = 1; Attempt <= 5; ++Attempt)
		{
			if (TryOperation(Attempt))
			{
				return Attempt;
			}
		}

		return -1;
	}

	/**
	 * The entrypoint C++ executes to sum every fallback in one pass.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs none
	 * @Return 9, the sum of the individual fallback values
	 */
	UFUNCTION()
	int DefensivePatternSummary()
	{
		TArray<int> Values;
		Values.Add(3);
		Values.Add(9);
		return SafeActorNameLength(nullptr)
			+ SafeArrayRead(Values, 1, -1)
			+ SafeArrayRead(Values, 4, 7)
			+ EarlyReturnPattern(0)
			+ RetryPattern();
	}

	/**
	 * Observe that a null actor falls back to a zero name length.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs none
	 * @Return true when the entrypoint returned 0
	 */
	UFUNCTION()
	bool SafeNullActorNameLengthNominal()
	{
		return SafeNullActorNameLength() == 0;
	}

	/**
	 * Observe that an unready state is rejected by the early return.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs none
	 * @Return true when the entrypoint returned -10
	 */
	UFUNCTION()
	bool EarlyReturnRejectsInvalidStateNominal()
	{
		return EarlyReturnRejectsInvalidState() == -10;
	}

	/**
	 * Observe that the retry loop stops at the third attempt.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs none
	 * @Return true when the retry returned 3
	 */
	UFUNCTION()
	bool RetryPatternNominal()
	{
		return RetryPattern() == 3;
	}

	/**
	 * Observe that every fallback contributes to the summary.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs none
	 * @Return true when the summary is 9
	 */
	UFUNCTION()
	bool DefensivePatternSummaryNominal()
	{
		return DefensivePatternSummary() == 9;
	}

	/**
	 * Observe that an empty array falls back to the caller's default.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs an empty array
	 * @Return true when the read returned 7
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool SafeArrayReadEmptyDefault()
	{
		TArray<int> Values;
		return SafeArrayRead(Values, 0, 7) == 7;
	}

	/**
	 * Observe that the cap is inclusive at ten and applies above it.
	 *
	 * @Kind Observe
	 * @Covers Debug.NullBoundsEarlyReturnAndRetry
	 * @Inputs none
	 * @Return true when both ten and eleven come back as ten
	 * @Boundary cap at ten
	 */
	UFUNCTION()
	bool EarlyReturnCapBoundary()
	{
		if (EarlyReturnPattern(10) != 10)
		{
			return false;
		}
		return EarlyReturnPattern(11) == 10;
	}
}
