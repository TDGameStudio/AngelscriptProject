// Theme: Language.ControlFlow.Switch. Compiling warning oracle from SwitchEnumMissingCaseWarns.
// C++: AngelscriptCoverageConditionalTests.cpp::SwitchEnumMissingCaseWarns
// sha256=3591321afa3bf1779eca7103fdd0622ceb1e5ca33e925c74f1308f9fee6c80ee; lines 785-804.
// CSV SourceShape is NegativeDiagnostic; C++ asserts bCompileSucceeded and a missing-case warning for Third.
// Oracle: UseEnum(First) 1; UseEnum(Second) 2; UseEnum(Third) 0. Warning: Switch is missing cases ... Third.
// Extra: default-less switch still returns 0 for Third.
// DefaultSafe compile+value. Source owns locals.

enum EMissingSwitchCoverage
{
	First,
	Second,
	Third
}

int UseEnum(EMissingSwitchCoverage Value)
{
	switch (Value)
	{
		case EMissingSwitchCoverage::First:
			return 1;
		case EMissingSwitchCoverage::Second:
			return 2;
	}
	return 0;
}

bool Observe_MissingSwitchCoverage_Nominal()
{
	return UseEnum(EMissingSwitchCoverage::First) == 1
		&& UseEnum(EMissingSwitchCoverage::Second) == 2;
}

bool Observe_MissingSwitchCoverage_ThirdBoundary()
{
	return UseEnum(EMissingSwitchCoverage::Third) == 0;
}
