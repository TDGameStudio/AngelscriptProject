// Theme: Language.Syntax.EdgeCases. Positive nested block compile.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 2 AssertCompiles.
// sha256=86b3086e265b9ee6550ef3f870299872ee236e30c6837e45e40b9866b7144d09; lines 235-237.
// Oracle: four nested blocks compile; innermost X is 1 while the nest is live.
// Extra: empty inner nests leave outer 0; assigning through the nest yields 1.
// DefaultSafe. Source owns locals.

void Test()
{
	{
		{
			{
				{
					int X = 1;
				}
			}
		}
	}
}

int Observe_DeepNest_InnermostValue()
{
	int Result = 0;
	{
		{
			{
				{
					int X = 1;
					Result = X;
				}
			}
		}
	}
	return Result;
}

int Observe_DeepNest_EmptyBlocksDefault()
{
	int Result = 0;
	{
		{
			{
				{
				}
			}
		}
	}
	return Result;
}

int Observe_DeepNest_OuterUnchangedAfterInner()
{
	int Outer = 0;
	{
		{
			{
				{
					int X = 1;
					Outer = X;
				}
			}
		}
	}
	return Outer;
}
