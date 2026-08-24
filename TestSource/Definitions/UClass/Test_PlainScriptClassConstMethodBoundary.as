// Theme: Definitions.UClass. Positive compile of a plain script class with const methods.
// C++: AngelscriptCoverageConstTests.cpp::PlainScriptClassConstMethodBoundary
// compiles then ExecuteAndExpectException ("Null pointer access") on ConstMethodPlainClassBoundary.
// CSV NegativeDiagnostic is wrong: this is a runtime const-member boundary, not a compile fail.
// Extra: default Value=0; assigned 30; copy independence without calling const methods. DefaultSafe.

class ConstCounter
{
	int Value = 0;

	int GetValue() const
	{
		return Value;
	}

	int AddReadonly(const int&in Amount) const
	{
		return Value + Amount;
	}
}

int ConstMethodPlainClassBoundary()
{
	ConstCounter Counter;
	Counter.Value = 30;
	const int Bonus = 4;
	return Counter.GetValue() + Counter.AddReadonly(Bonus);
}

int Observe_ConstCounter_DefaultValue()
{
	ConstCounter Counter;
	return Counter.Value;
}

int Observe_ConstCounter_AssignedBoundary()
{
	ConstCounter Counter;
	Counter.Value = 30;
	return Counter.Value;
}

bool Observe_ConstCounter_CopyIndependence()
{
	ConstCounter First;
	ConstCounter Second;
	First.Value = 30;
	return First.Value == 30 && Second.Value == 0;
}
