// Theme: Feature.Default. Isolated compile-fail: unsafe_during_construction in a constructor.
// C++: AngelscriptDefaultStatementSafetyTests.cpp::UnsafeDuringConstructionRejectsDefaultAndConstructor
// CompileSafetyScript(..., bExpectedCompile=false). Expected diagnostic: "unsafe during construction".
// DiagnosticOnly. Do not call UnsafeValue from Entry instead of the constructor.

class UnsafeConstructorCarrier
{
	int Value = 0;

	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	UnsafeConstructorCarrier()
	{
		Value = UnsafeValue();
	}
}

int Entry()
{
	UnsafeConstructorCarrier@ Carrier = UnsafeConstructorCarrier();
	return Carrier.Value;
}
