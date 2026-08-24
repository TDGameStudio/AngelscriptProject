// Theme: Language.ControlFlow.Switch. C++ adds expected fallthrough diagnostics
// then still executes the functions. CSV SourceShape is NegativeDiagnostic; TrailingOracle is ExpectGlobalReturn.
// C++: AngelscriptCoverageConditionalTests.cpp::SwitchFallthrough
// sha256=df83f8dc41ca3ec0849901978cc70809c612163983807ec588a54e3b05315848; lines 505-547.
// Oracle: Fallthrough(1) == 6; PartialFallthrough(2) == 50.
// Extra: Fallthrough(99) default 0; PartialFallthrough(1) breaks at 10 (no fallthrough).
// DefaultSafe value oracle. Source owns locals.

int Fallthrough(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result += 1;
			// fallthrough
		case 2:
			Result += 2;
			// fallthrough
		case 3:
			Result += 3;
			break;
		default:
			Result = 0;
	}
	return Result;
}

int PartialFallthrough(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result += 10;
			break;
		case 2:
			Result += 20;
			// fallthrough
		case 3:
			Result += 30;
			break;
		default:
			Result = 0;
	}
	return Result;
}

bool Observe_Fallthrough_Nominal()
{
	return Fallthrough(1) == 6 && PartialFallthrough(2) == 50;
}

bool Observe_Fallthrough_DefaultEmpty()
{
	return Fallthrough(99) == 0 && PartialFallthrough(0) == 0;
}

bool Observe_PartialFallthrough_BreakBoundary()
{
	return PartialFallthrough(1) == 10 && Fallthrough(2) == 5 && Fallthrough(3) == 3;
}
