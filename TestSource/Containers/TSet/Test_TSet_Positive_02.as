// Theme: Containers.TSet. Positive: TSet Add of two ints.
// C++: AngelscriptSyntaxContainerTests.cpp::TSet_Positive AssertCompiles ASSyntaxCon_SetAdd.
// Oracle: Add(1)+Add(2) Num()==2. Extra: empty Num()==0; duplicate Add(1) stays Num()==1.
// DefaultSafe. Source owns locals.

void Test()
{
	TSet<int> S;
	S.Add(1);
	S.Add(2);
}

int Observe_TSetAdd_NominalNum()
{
	TSet<int> S;
	S.Add(1);
	S.Add(2);
	return S.Num();
}

int Observe_TSetAdd_EmptyNum()
{
	TSet<int> S;
	return S.Num();
}

int Observe_TSetAdd_DuplicateBoundary()
{
	TSet<int> S;
	S.Add(1);
	S.Add(1);
	return S.Num();
}
