// Theme: Gameplay.Debug. Value oracle: null/range/early-return/retry fallbacks.
// C++: AngelscriptCoverageErrorHandlingTests.cpp::NullBoundsEarlyReturnAndRetry
// CSV NegativeDiagnostic; C++ compiles. SafeNullActorNameLength 0;
// EarlyReturnRejectsInvalidState -10; RetryPattern 3; DefensivePatternSummary 9.
// Extra: empty array default 7; EarlyReturnPattern(10) identity; (11) caps at 10.
// DefaultSafe.

int SafeActorNameLength(AActor Actor)
{
	if (Actor == nullptr)
	{
		return 0;
	}

	return Actor.GetName().ToString().Len();
}

int SafeNullActorNameLength()
{
	return SafeActorNameLength(nullptr);
}

int SafeArrayRead(const TArray<int>&in Values, int Index, int DefaultValue)
{
	if (!Values.IsValidIndex(Index))
	{
		return DefaultValue;
	}

	return Values[Index];
}

bool IsReady(int State)
{
	return State > 0;
}

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

int EarlyReturnRejectsInvalidState()
{
	return EarlyReturnPattern(0);
}

bool TryOperation(int Attempt)
{
	return Attempt >= 3;
}

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

bool Observe_SafeNullActorNameLength_Nominal()
{
	return SafeNullActorNameLength() == 0;
}

bool Observe_EarlyReturnRejectsInvalidState_Nominal()
{
	return EarlyReturnRejectsInvalidState() == -10;
}

bool Observe_RetryPattern_Nominal()
{
	return RetryPattern() == 3;
}

bool Observe_DefensivePatternSummary_Nominal()
{
	return DefensivePatternSummary() == 9;
}

bool Observe_SafeArrayRead_EmptyDefault()
{
	TArray<int> Values;
	return SafeArrayRead(Values, 0, 7) == 7;
}

bool Observe_EarlyReturn_CapBoundary()
{
	return EarlyReturnPattern(10) == 10 && EarlyReturnPattern(11) == 10;
}
