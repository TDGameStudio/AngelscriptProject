// Theme: Feature.Access. Positive: the same name may be declared in separate blocks.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Positive block 2 AssertCompiles.
// Oracle: first block X==1 and second block X==2 do not collide; outer stays 0.
// Extra: empty sibling blocks leave the outer default unchanged.
// DefaultSafe.

void Test()
{
	{
		int X = 1;
	}
	{
		int X = 2;
	}
}

int Observe_SeparateBlocksIndependent()
{
	int Outer = 0;
	{
		int X = 1;
		if (X != 1)
		{
			return -1;
		}
	}
	{
		int X = 2;
		if (X != 2)
		{
			return -2;
		}
	}
	return Outer;
}

int Observe_EmptySiblingBlocksDefault()
{
	int X = 9;
	{
	}
	{
	}
	return X;
}
