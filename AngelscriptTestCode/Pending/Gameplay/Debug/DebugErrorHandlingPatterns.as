/**
 * @version v1
 * @summary The defensive error-handling patterns: an out-parameter division guard, an index validation returning an enum, and ensure-guarded helpers that fall back rather than proceeding. The CSV NegativeDiagnostic label is a.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The defensive error-handling patterns: an out-parameter division guard, an index validation returning an enum, and ensure-guarded helpers that fall back rather than proceeding. The CSV NegativeDiagnostic label is a.
 * @topic Baseline
 */
enum ECoverageDebugErrorCode
{
	Success = 0,
	NotFound = 1,
	InvalidParam = 2
}

namespace DebugTest
{
	/**
	 * Divide, reporting success and writing the quotient out rather than throwing.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugErrorHandlingPatterns
	 * @Inputs a numerator and a denominator
	 * @Return true and the quotient, or false and 0 when the denominator is 0
	 * @Param Numerator the value to divide
	 * @Param Denominator the value to divide by
	 * @Param OutResult the quotient, set to 0 when the division is refused
	 * @Boundary zero denominator
	 */
	UFUNCTION()
	bool TryDivide(int Numerator, int Denominator, int&out OutResult)
	{
		if (Denominator == 0)
		{
			OutResult = 0;
			return false;
		}

		OutResult = Numerator / Denominator;
		return true;
	}

	/**
	 * Classify an index against an array, refusing negative and out-of-range indices.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugErrorHandlingPatterns
	 * @Inputs an array and an index
	 * @Return Success, NotFound or InvalidParam
	 * @Param Values the array to index into
	 * @Param Index the index to classify
	 * @Boundary negative and out-of-range index
	 */
	UFUNCTION()
	ECoverageDebugErrorCode ValidateIndex(const TArray<int>&in Values, int Index)
	{
		if (Index < 0)
		{
			return ECoverageDebugErrorCode::InvalidParam;
		}
		if (!Values.IsValidIndex(Index))
		{
			return ECoverageDebugErrorCode::NotFound;
		}
		return ECoverageDebugErrorCode::Success;
	}

	/**
	 * Read an actor's name length, falling back to 0 when the handle is null.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugErrorHandlingPatterns
	 * @Inputs an actor handle, which may be null
	 * @Return the name length, or 0 when the handle is null
	 * @Param Actor the actor to inspect
	 * @Boundary null actor
	 */
	UFUNCTION()
	int SafeActorNameLength(AActor Actor)
	{
		if (!ensure(Actor != nullptr, "CoverageDebugNullGuard"))
		{
			return 0;
		}

		return Actor.GetName().ToString().Len();
	}

	/**
	 * Read an array element, falling back to a caller-supplied default when the index is
	 * out of range.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugErrorHandlingPatterns
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
		if (!ensure(Values.IsValidIndex(Index), "CoverageDebugIndexGuard"))
		{
			return DefaultValue;
		}

		return Values[Index];
	}

	/**
	 * The entrypoint C++ executes, collecting one bit per pattern that behaved as
	 * intended.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugErrorHandlingPatterns
	 * @Inputs none
	 * @Return 63 when all six patterns scored
	 */
	UFUNCTION()
	int DefensiveDebugPatterns()
	{
		int Score = 0;

		int DivideResult = 0;
		if (!TryDivide(10, 0, DivideResult) && DivideResult == 0)
		{
			Score += 1;
		}
		if (TryDivide(12, 3, DivideResult) && DivideResult == 4)
		{
			Score += 2;
		}

		TArray<int> Values;
		Values.Add(11);
		Values.Add(22);
		if (ValidateIndex(Values, -1) == ECoverageDebugErrorCode::InvalidParam)
		{
			Score += 4;
		}
		if (ValidateIndex(Values, 5) == ECoverageDebugErrorCode::NotFound)
		{
			Score += 8;
		}
		if (SafeActorNameLength(nullptr) == 0)
		{
			Score += 16;
		}
		if (SafeArrayRead(Values, 5, -7) == -7)
		{
			Score += 32;
		}

		return Score;
	}

	/**
	 * Observe that every defensive pattern scored.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugErrorHandlingPatterns
	 * @Inputs none
	 * @Return true when the score is 63
	 */
	UFUNCTION()
	bool DefensiveDebugPatternsNominal()
	{
		return DefensiveDebugPatterns() == 63;
	}

	/**
	 * Observe that a zero denominator is refused and the out parameter is cleared.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugErrorHandlingPatterns
	 * @Inputs a numerator and a zero denominator
	 * @Return true when the call failed and the out parameter is 0
	 * @Boundary zero denominator
	 */
	UFUNCTION()
	bool TryDivideZeroDenom()
	{
		int OutResult = 99;
		bool bOk = TryDivide(10, 0, OutResult);

		if (bOk)
		{
			return false;
		}
		return OutResult == 0;
	}

	/**
	 * Observe that indexing an empty array reports NotFound.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugErrorHandlingPatterns
	 * @Inputs an empty array and index 0
	 * @Return true when the index classifies as NotFound
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool ValidateIndexEmptyArray()
	{
		TArray<int> Values;
		return ValidateIndex(Values, 0) == ECoverageDebugErrorCode::NotFound;
	}

	/**
	 * Observe that a null actor falls back to a zero name length.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebugErrorHandlingPatterns
	 * @Inputs a null actor handle
	 * @Return true when the length is 0
	 * @Boundary null actor
	 */
	UFUNCTION()
	bool SafeActorNameLengthNull()
	{
		return SafeActorNameLength(nullptr) == 0;
	}
}
/** @end */
