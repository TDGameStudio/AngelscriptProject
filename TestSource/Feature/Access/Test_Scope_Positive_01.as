// Theme: Feature.Access. Positive nested scope / name shadowing.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Positive block 1 AssertCompiles.
// Oracle: inner shadow does not overwrite outer after the block.
// Extra: empty inner block is a no-op; outer remains 1.
// DefaultSafe.

void Test()
{
	int X = 1;
	{
		int X = 2;
	}
}

int Observe_OuterUnchangedAfterInnerShadow()
{
	int X = 1;
	{
		int X = 2;
		if (X != 2)
		{
			return 0;
		}
	}
	return X;
}

int Observe_EmptyInnerScopeDefault()
{
	int X = 7;
	{
	}
	return X;
}
