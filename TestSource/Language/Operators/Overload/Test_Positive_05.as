// Theme: Language.Operators.Overload. Positive opCmp compile plus value oracle.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
// sha256=4302b63600aa7e146f1b69e4b99f6ae5bff6b8bedfa16d2948b02a261dea4de1; lines 118-128.
// C++ AssertCompiles; observations execute opCmp.
// Oracle: 3 cmp 1 is 2. Extra: default cmp default is 0; 1 cmp 3 is -2.
// DefaultSafe. Source owns locals.

struct FValCmp
{
	int Value = 0;

	int opCmp(const FValCmp& Other) const
	{
		return Value - Other.Value;
	}
}

bool Observe_FValCmp_Nominal()
{
	FValCmp High;
	High.Value = 3;
	FValCmp Low;
	Low.Value = 1;
	return High.opCmp(Low) == 2 && High > Low && Low < High;
}

bool Observe_FValCmp_EmptyDefault()
{
	FValCmp A;
	FValCmp B;
	return A.opCmp(B) == 0 && !(A < B) && !(A > B) && A <= B && A >= B;
}

bool Observe_FValCmp_NegativeBoundary()
{
	FValCmp Low;
	Low.Value = 1;
	FValCmp High;
	High.Value = 3;
	return Low.opCmp(High) == -2 && Low < High;
}
