// Theme: Containers.TOptional. Positive TOptional declaration.
// C++ AssertCompiles ASSyntaxCon_OptDecl. Oracle: default IsSet is false.
// Extra: assigning one copy does not set the other. DefaultSafe.

void Test()
{
	TOptional<int> Opt;
}

bool Observe_TOptionalDecl_EmptyDefault()
{
	TOptional<int> Opt;
	return !Opt.IsSet();
}

int Observe_TOptionalDecl_AfterAssignBoundary()
{
	TOptional<int> Opt;
	Opt = 42;
	return Opt.GetValue();
}

bool Observe_TOptionalDecl_CopyIndependence()
{
	TOptional<int> First;
	TOptional<int> Second;
	First = 1;
	return First.IsSet() && !Second.IsSet();
}
