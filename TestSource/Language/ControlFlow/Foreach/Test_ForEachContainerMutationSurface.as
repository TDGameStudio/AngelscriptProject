// Theme: Language.ControlFlow.Foreach. Compile-reachable mutation surface from ForEachContainerMutationSurface.
// C++: AngelscriptCoverageLoopTests.cpp::ForEachContainerMutationSurface
// sha256=b12085e689ff062159a554cb9d903603cac2fe0017a4fe6d1d7c9516e0335fee; lines 376-411.
// Oracle: module compiles; C++ does not pin runtime invalidation counts.
// Extra: empty TArray foreach visits nothing; mutation helpers remain callable.
// DefaultSafe. Source owns locals.

int ForEachAddMutationSurface()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	bool bAdded = false;
	for (int Value : Values)
	{
		if (!bAdded)
		{
			Values.Add(3);
			bAdded = true;
		}
	}
	return Values.Num();
}

int ForEachRemoveMutationSurface()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(3);
	bool bRemoved = false;
	for (int Value : Values)
	{
		if (!bRemoved && Value == 1)
		{
			Values.RemoveAt(1);
			bRemoved = true;
		}
	}
	return Values.Num();
}

bool Observe_ForEachMutation_EmptyDefault()
{
	TArray<int> Empty;
	int Visits = 0;
	for (int Value : Empty)
	{
		Visits += 1;
	}
	return Visits == 0;
}

bool Observe_ForEachMutation_CallableBoundary()
{
	int AfterAdd = ForEachAddMutationSurface();
	int AfterRemove = ForEachRemoveMutationSurface();
	return AfterAdd >= 2 && AfterRemove >= 1 && AfterRemove <= 3;
}
