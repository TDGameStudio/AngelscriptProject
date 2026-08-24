// Theme: Language.Syntax.EdgeCases. Positive UENUM.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Positive block 2 AssertCompiles.
// sha256=fb9ff343240dbbd778a95c2767ab64c9f569431e1a2af9ee835c0212d878cad4; lines 343-346.
// Oracle: Value1 is 0; Value2 is 1.
// Extra: default first enumerator is 0; Value2 is the last-index boundary.
// DefaultSafe. Source owns locals.

UENUM()
enum EEnumUENUM
{
	Value1,
	Value2
}

int Observe_EEnumUENUM_Value1Default()
{
	return int(EEnumUENUM::Value1);
}

int Observe_EEnumUENUM_Value2Boundary()
{
	return int(EEnumUENUM::Value2);
}

bool Observe_EEnumUENUM_NotEqualEnumerators()
{
	return EEnumUENUM::Value1 != EEnumUENUM::Value2;
}
