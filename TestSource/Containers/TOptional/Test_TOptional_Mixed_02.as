// Theme: Containers.TOptional. Positive TOptional assign.
// C++ AssertCompiles ASSyntaxCon_OptSet. Oracle: Opt = 42 then GetValue==42.
// Extra: unset default; zero boundary; two optionals stay independent. DefaultSafe.

void Test()
{
	TOptional<int> Opt;
	Opt = 42;
}

int Observe_TOptionalSet_Nominal()
{
	TOptional<int> Opt;
	Opt = 42;
	return Opt.GetValue();
}

bool Observe_TOptionalSet_EmptyDefault()
{
	TOptional<int> Opt;
	return !Opt.IsSet();
}

int Observe_TOptionalSet_ZeroBoundary()
{
	TOptional<int> Opt;
	Opt = 0;
	return Opt.GetValue();
}

bool Observe_TOptionalSet_CopyIndependence()
{
	TOptional<int> First;
	TOptional<int> Second;
	First = 42;
	Second = 42;
	First = 1;
	return First.GetValue() == 1 && Second.GetValue() == 42;
}
