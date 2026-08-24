// Theme: Language.Syntax.EdgeCases. C++ originally expected empty-enum failure.
// Live C++: Enum_Negative block 5 is #if 0 (structural-validation-absent);
// enum EEnumEmpty { } compiles. CSV NegativeDiagnostic is not a compile-fail.
// sha256=eda456f841820e8f86c9ce143562d17e7435846d267bb4ed4505d2e1281750b5; lines 410-412.
// Oracle: EEnumEmpty is a usable type; default conversion is 0.
// Extra: empty default 0; two default values compare equal.
// DefaultSafe value oracle.

enum EEnumEmpty
{
}

int Observe_EEnumEmpty_DefaultZero()
{
	EEnumEmpty Value;
	return int(Value);
}

int Observe_EEnumEmpty_TwoDefaultsMatch()
{
	EEnumEmpty First;
	EEnumEmpty Second;
	if (First == Second)
	{
		return 1;
	}
	return 0;
}
