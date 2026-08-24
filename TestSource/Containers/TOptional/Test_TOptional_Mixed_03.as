// Theme: Containers.TOptional. Positive TOptional.IsSet.
// C++ AssertCompiles ASSyntaxCon_OptIsSet. Oracle: default IsSet is false; after assign true.
// Extra: copy independence. DefaultSafe.

void Test()
{
	TOptional<int> Opt;
	bool B = Opt.IsSet();
}

bool Observe_TOptionalIsSet_EmptyDefault()
{
	TOptional<int> Opt;
	bool B = Opt.IsSet();
	return !B;
}

bool Observe_TOptionalIsSet_AfterAssignBoundary()
{
	TOptional<int> Opt;
	Opt = 5;
	return Opt.IsSet();
}

bool Observe_TOptionalIsSet_CopyIndependence()
{
	TOptional<int> First;
	TOptional<int> Second;
	First = 1;
	return First.IsSet() && !Second.IsSet();
}
