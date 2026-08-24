// Theme: Containers.TSet. Positive: TSet Remove after Add.
// C++: AngelscriptSyntaxContainerTests.cpp::TSet_Positive AssertCompiles ASSyntaxCon_SetRemove.
// Oracle: Add(1) then Remove(1) leaves Num()==0. Extra: empty Remove is a no-op; copy independence.
// DefaultSafe. Source owns locals.

void Test()
{
	TSet<int> S;
	S.Add(1);
	S.Remove(1);
}

int Observe_TSetRemove_NominalEmpty()
{
	TSet<int> S;
	S.Add(1);
	S.Remove(1);
	return S.Num();
}

int Observe_TSetRemove_EmptyDefault()
{
	TSet<int> S;
	S.Remove(1);
	return S.Num();
}

bool Observe_TSetRemove_CopyIndependence()
{
	TSet<int> First;
	TSet<int> Second;
	First.Add(1);
	Second.Add(1);
	First.Remove(1);
	return First.Num() == 0 && Second.Num() == 1 && Second.Contains(1);
}
