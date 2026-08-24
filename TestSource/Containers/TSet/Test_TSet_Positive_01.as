// Theme: Containers.TSet. Positive: TSet<int> declaration.
// C++: AngelscriptSyntaxContainerTests.cpp::TSet_Positive AssertCompiles ASSyntaxCon_SetDecl.
// Oracle: empty Num()==0. Extra: copy independence after Add on one instance.
// DefaultSafe. Source owns locals.

void Test()
{
	TSet<int> S;
}

int Observe_TSetDecl_EmptyNum()
{
	TSet<int> S;
	return S.Num();
}

int Observe_TSetDecl_CopyIndependence()
{
	TSet<int> First;
	TSet<int> Second;
	First.Add(1);
	return First.Num() == 1 && Second.Num() == 0 ? 1 : 0;
}
