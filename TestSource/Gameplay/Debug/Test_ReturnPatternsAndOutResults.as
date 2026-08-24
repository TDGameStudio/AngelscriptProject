// Theme: Gameplay.Debug. Value oracle: bool return, out result, error-code enum.
// C++: AngelscriptCoverageErrorHandlingTests.cpp::ReturnPatternsAndOutResults
// CSV NegativeDiagnostic; C++ compiles. BoolReturnPattern -1; OutResultSuccessPattern 4;
// ErrorCodePattern 12 (NotFound*10 + InvalidParam). Extra: empty array NotFound;
// copy-independence of two TryDivide outs. DefaultSafe. Math::IntegerDivisionTrunc.

enum ECoverageErrorCode
{
	Success = 0,
	NotFound = 1,
	InvalidParam = 2
}

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

int BoolReturnPattern()
{
	int Value = 0;
	if (!TryDivide(10, 0, Value))
	{
		return -1;
	}
	return Value;
}

int OutResultSuccessPattern()
{
	int Value = 0;
	return TryDivide(12, 3, Value) ? Value : -1;
}

int ErrorCodePattern()
{
	TArray<int> Values;
	Values.Add(10);
	Values.Add(20);
	return int(ValidateIndex(Values, 5)) * 10 + int(ValidateIndex(Values, -1));
}

bool Observe_BoolReturnPattern_Nominal()
{
	return BoolReturnPattern() == -1;
}

bool Observe_OutResultSuccessPattern_Nominal()
{
	return OutResultSuccessPattern() == 4;
}

bool Observe_ErrorCodePattern_Nominal()
{
	return ErrorCodePattern() == 12;
}

bool Observe_TryDivide_CopyIndependence()
{
	int A = 0;
	int B = 0;
	TryDivide(12, 3, A);
	TryDivide(10, 0, B);
	return A == 4 && B == 0;
}

bool Observe_ValidateIndex_EmptyArray()
{
	TArray<int> Values;
	return ValidateIndex(Values, 0) == ECoverageErrorCode::NotFound;
}
