/**
 * The three return patterns: a bool with an out result, a ternary over the out result,
 * and an error-code enum folded into an integer. The CSV NegativeDiagnostic label is a
 * heuristic: C++ compiles this and executes each entrypoint expecting its value, so this
 * is a value oracle.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ReturnPatternsAndOutResults
 * @Harness Function
 * @Tag Gameplay.Debug.ReturnPatternsAndOutResults
 * @Namespace DebugTest
 * @Provenance Theme: Gameplay.Debug. Value oracle: bool return, out result, error-code enum.
 * @Provenance C++: AngelscriptCoverageErrorHandlingTests.cpp::ReturnPatternsAndOutResults
 * @Provenance CSV NegativeDiagnostic; C++ compiles. BoolReturnPattern -1; OutResultSuccessPattern 4;
 * @Provenance ErrorCodePattern 12 (NotFound*10 + InvalidParam). Extra: empty array NotFound;
 * @Provenance copy-independence of two TryDivide outs. DefaultSafe. Math::IntegerDivisionTrunc.
 */

enum ECoverageErrorCode
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
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs a numerator and a denominator
	 * @Return true and the truncated quotient, or false and 0 when the denominator is 0
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

		OutResult = Math::IntegerDivisionTrunc(Numerator, Denominator);
		return true;
	}

	/**
	 * Classify an index against an array, refusing negative and out-of-range indices.
	 *
	 * @Kind Observe
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs an array and an index
	 * @Return Success, NotFound or InvalidParam
	 * @Param Values the array to index into
	 * @Param Index the index to classify
	 * @Boundary negative and out-of-range index
	 */
	UFUNCTION()
	ECoverageErrorCode ValidateIndex(const TArray<int>&in Values, int Index)
	{
		if (Index < 0)
		{
			return ECoverageErrorCode::InvalidParam;
		}
		if (!Values.IsValidIndex(Index))
		{
			return ECoverageErrorCode::NotFound;
		}
		return ECoverageErrorCode::Success;
	}

	/**
	 * The entrypoint C++ executes for the bool-return pattern.
	 *
	 * @Kind Observe
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs none
	 * @Return -1 when the divide was refused
	 * @Boundary zero denominator
	 */
	UFUNCTION()
	int BoolReturnPattern()
	{
		int Value = 0;
		if (!TryDivide(10, 0, Value))
		{
			return -1;
		}
		return Value;
	}

	/**
	 * The entrypoint C++ executes for the out-result pattern.
	 *
	 * @Kind Observe
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs none
	 * @Return the quotient on success, otherwise -1
	 */
	UFUNCTION()
	int OutResultSuccessPattern()
	{
		int Value = 0;
		return TryDivide(12, 3, Value) ? Value : -1;
	}

	/**
	 * The entrypoint C++ executes for the error-code pattern.
	 *
	 * @Kind Observe
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs none
	 * @Return NotFound times ten plus InvalidParam, which is 12
	 */
	UFUNCTION()
	int ErrorCodePattern()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		return int(ValidateIndex(Values, 5)) * 10 + int(ValidateIndex(Values, -1));
	}

	/**
	 * Observe that a refused divide reports the sentinel.
	 *
	 * @Kind Observe
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs none
	 * @Return true when the entrypoint returned -1
	 */
	UFUNCTION()
	bool BoolReturnPatternNominal()
	{
		return BoolReturnPattern() == -1;
	}

	/**
	 * Observe that a successful divide reports the quotient.
	 *
	 * @Kind Observe
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs none
	 * @Return true when the entrypoint returned 4
	 */
	UFUNCTION()
	bool OutResultSuccessPatternNominal()
	{
		return OutResultSuccessPattern() == 4;
	}

	/**
	 * Observe that the two error codes fold into the expected integer.
	 *
	 * @Kind Observe
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs none
	 * @Return true when the entrypoint returned 12
	 */
	UFUNCTION()
	bool ErrorCodePatternNominal()
	{
		return ErrorCodePattern() == 12;
	}

	/**
	 * Observe that two out parameters record their own results independently.
	 *
	 * @Kind Observe
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs none
	 * @Return true when the successful divide wrote 4 and the refused one wrote 0
	 * @Boundary out-parameter independence
	 */
	UFUNCTION()
	bool TryDivideCopyIndependence()
	{
		int A = 0;
		int B = 0;
		TryDivide(12, 3, A);
		TryDivide(10, 0, B);

		if (A != 4)
		{
			return false;
		}
		return B == 0;
	}

	/**
	 * Observe that indexing an empty array reports NotFound.
	 *
	 * @Kind Observe
	 * @Covers Debug.ReturnPatternsAndOutResults
	 * @Inputs an empty array and index 0
	 * @Return true when the index classifies as NotFound
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool ValidateIndexEmptyArray()
	{
		TArray<int> Values;
		return ValidateIndex(Values, 0) == ECoverageErrorCode::NotFound;
	}
}
