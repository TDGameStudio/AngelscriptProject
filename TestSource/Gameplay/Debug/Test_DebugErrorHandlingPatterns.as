// Theme: Gameplay.Debug. Value oracle: bool/out/enum/ensure guards.
// C++: AngelscriptCoverageDebugTests.cpp::DebugErrorHandlingPatterns
// CSV NegativeDiagnostic; C++ compiles. ExecuteAndExpectInt DefensiveDebugPatterns == 63.
// Extra: empty array NotFound; denom 0 OutResult 0; null actor length 0. DefaultSafe.

enum ECoverageDebugErrorCode
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

	OutResult = Numerator / Denominator;
	return true;
}

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

int SafeActorNameLength(AActor Actor)
{
	if (!ensure(Actor != nullptr, "CoverageDebugNullGuard"))
	{
		return 0;
	}

	return Actor.GetName().ToString().Len();
}

int SafeArrayRead(const TArray<int>&in Values, int Index, int DefaultValue)
{
	if (!ensure(Values.IsValidIndex(Index), "CoverageDebugIndexGuard"))
	{
		return DefaultValue;
	}

	return Values[Index];
}

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

bool Observe_DefensiveDebugPatterns_Nominal()
{
	return DefensiveDebugPatterns() == 63;
}

bool Observe_TryDivide_ZeroDenom()
{
	int OutResult = 99;
	bool bOk = TryDivide(10, 0, OutResult);
	return bOk == false && OutResult == 0;
}

bool Observe_ValidateIndex_EmptyArray()
{
	TArray<int> Values;
	return ValidateIndex(Values, 0) == ECoverageDebugErrorCode::NotFound;
}

bool Observe_SafeActorNameLength_Null()
{
	return SafeActorNameLength(nullptr) == 0;
}
