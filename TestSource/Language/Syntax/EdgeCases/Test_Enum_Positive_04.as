// Theme: Language.Syntax.EdgeCases. Positive enum local usage.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Positive block 4 AssertCompiles.
// sha256=c1cb1c70671e0d8302e4aa5c2bc9308aa91e457a16bcd7a14e0316e53236d22e; lines 356-363.
// Oracle: Test assigns EEnumUsage::Val1; Val1 is 0 and Val2 is 1.
// Extra: default Val1 is 0; Val2 is the other enumerator boundary.
// DefaultSafe. Source owns locals.

enum EEnumUsage
{
	Val1,
	Val2
}

void Test()
{
	EEnumUsage E = EEnumUsage::Val1;
}

int Observe_EEnumUsage_Val1Default()
{
	EEnumUsage E = EEnumUsage::Val1;
	return int(E);
}

int Observe_EEnumUsage_Val2Boundary()
{
	EEnumUsage E = EEnumUsage::Val2;
	return int(E);
}
