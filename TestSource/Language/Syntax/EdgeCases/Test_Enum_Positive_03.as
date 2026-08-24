// Theme: Language.Syntax.EdgeCases. Positive enum with explicit values.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Positive block 3 AssertCompiles.
// sha256=a454f499bb2f7a1b29845c9be2bdbf54d8377285f85c2598bc3a62e0ef123d08; lines 350-352.
// Oracle: Value1 is 0, Value2 is 5, Value3 is 10.
// Extra: 0 is the empty/default first value; 10 is the high boundary.
// DefaultSafe. Source owns locals.

enum EEnumExplicit
{
	Value1 = 0,
	Value2 = 5,
	Value3 = 10
}

int Observe_EEnumExplicit_Value1Default()
{
	return int(EEnumExplicit::Value1);
}

int Observe_EEnumExplicit_Value2()
{
	return int(EEnumExplicit::Value2);
}

int Observe_EEnumExplicit_Value3Boundary()
{
	return int(EEnumExplicit::Value3);
}
