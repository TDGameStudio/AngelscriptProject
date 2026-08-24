// Theme: Containers.TOptional. Positive TOptional.GetValue.
// C++ AssertCompiles ASSyntaxCon_OptGetValue. Oracle: Opt=5 then GetValue==5.
// Extra: unset default; zero boundary; copy independence. DefaultSafe.

void Test()
{
	TOptional<int> Opt;
	Opt = 5;
	int X = Opt.GetValue();
}

int Observe_TOptionalGetValue_Nominal()
{
	TOptional<int> Opt;
	Opt = 5;
	int X = Opt.GetValue();
	return X;
}

bool Observe_TOptionalGetValue_EmptyDefault()
{
	TOptional<int> Opt;
	return !Opt.IsSet();
}

int Observe_TOptionalGetValue_ZeroBoundary()
{
	TOptional<int> Opt;
	Opt = 0;
	return Opt.GetValue();
}

bool Observe_TOptionalGetValue_CopyIndependence()
{
	TOptional<int> First;
	TOptional<int> Second;
	First = 5;
	Second = 5;
	First = 9;
	return First.GetValue() == 9 && Second.GetValue() == 5;
}
