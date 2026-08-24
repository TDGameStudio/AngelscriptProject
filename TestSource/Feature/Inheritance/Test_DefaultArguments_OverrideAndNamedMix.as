// Theme: Feature.Inheritance. Positive default / positional override / named-partial arguments.
// C++: AngelscriptFunctionTests.cpp::DefaultArguments_OverrideAndNamedMix
// ExecuteIntFunction: RunDefault==159, RunOverride==129, RunNamedPartial==153.
// Extra: Format(0)==9; Format(1,0,0)==100. DefaultSafe.

int Format(int A, int B = 5, int C = 9)
{
	return A * 100 + B * 10 + C;
}

int RunDefault()
{
	return Format(1);
}

int RunOverride()
{
	return Format(1, 2);
}

int RunNamedPartial()
{
	return Format(A: 1, C: 3);
}

int Observe_DefaultArgs_RunDefault()
{
	return RunDefault();
}

int Observe_DefaultArgs_RunOverride()
{
	return RunOverride();
}

int Observe_DefaultArgs_RunNamedPartial()
{
	return RunNamedPartial();
}

int Observe_DefaultArgs_ZeroA()
{
	return Format(0);
}

int Observe_DefaultArgs_ExplicitZeros()
{
	return Format(1, 0, 0);
}
