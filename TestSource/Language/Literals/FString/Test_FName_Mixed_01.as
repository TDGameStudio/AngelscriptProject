// Theme: Language.Literals.FString. Positive: FName literal with n prefix.
// C++: AngelscriptSyntaxFStringTests.cpp::FName_Mixed block 1 AssertCompiles.
// sha256=58dfed3df4355b0f1e22999ce520d365ed3a3d2768f0fa6106f4bb433fe7b544; lines 253-255.
// Oracle: n"MyName" == FName("MyName").
// Extra: NAME_None is not n"MyName"; n"myname" equals n"MyName" (case-insensitive).
// DefaultSafe.

void Test()
{
	FName N = n"MyName";
}

bool Observe_FNameLiteral_Nominal()
{
	FName N = n"MyName";
	return N == FName("MyName");
}

bool Observe_FNameLiteral_NoneBoundary()
{
	FName N = n"MyName";
	return N != NAME_None;
}

bool Observe_FNameLiteral_CaseInsensitive()
{
	return n"myname" == n"MyName";
}
