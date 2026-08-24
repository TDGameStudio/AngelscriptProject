// Theme: Language.ControlFlow.Switch. Positive value oracle from BreakInSwitch.
// C++: AngelscriptCoverageJumpTests.cpp::BreakInSwitch
// sha256=74d059adcfe1fb5ec3354c2127e1e3c7a06ef536e4264ae9083235eddf56fa7c; lines 180-244.
// CSV SourceShape is NegativeDiagnostic; TrailingOracle is ExpectGlobalReturn (one expected fallthrough diagnostic).
// Oracle: BreakInSwitch(1) 10; BreakPreventsFallthrough(2) 5; MultipleBreaksInSwitch(1) 10.
// Extra: default 99/0; inner break skips Result=20; case 3 without prior fallthrough is 3.
// DefaultSafe value oracle. Source owns locals.

int BreakInSwitch(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result = 10;
			break;
		case 2:
			Result = 20;
			break;
		case 3:
			Result = 30;
			break;
		default:
			Result = 99;
			break;
	}
	return Result;
}

int BreakPreventsFallthrough(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result += 1;
			break;
		case 2:
			Result += 2;
			// No break - fallthrough
		case 3:
			Result += 3;
			break;
		default:
			Result = 0;
	}
	return Result;
}

int MultipleBreaksInSwitch(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result = 10;
			if (Result > 5)
				break;
			Result = 20;
			break;
		case 2:
			Result = 30;
			break;
		default:
			break;
	}
	return Result;
}

bool Observe_BreakInSwitch_Nominal()
{
	return BreakInSwitch(1) == 10
		&& BreakPreventsFallthrough(2) == 5
		&& MultipleBreaksInSwitch(1) == 10;
}

bool Observe_BreakInSwitch_DefaultEmpty()
{
	return BreakInSwitch(0) == 99
		&& BreakPreventsFallthrough(0) == 0
		&& MultipleBreaksInSwitch(0) == 0;
}

bool Observe_BreakInSwitch_RemainingCases()
{
	return BreakInSwitch(2) == 20
		&& BreakInSwitch(3) == 30
		&& BreakPreventsFallthrough(1) == 1
		&& BreakPreventsFallthrough(3) == 3
		&& MultipleBreaksInSwitch(2) == 30;
}
