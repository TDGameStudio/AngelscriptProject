// Theme: Language.Syntax.EdgeCases. Positive basic enum.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Positive block 1 AssertCompiles.
// sha256=e1dba63617c30eb6b1864ec019a84662297a5bb9ba7f3c2342737a12822ef2f5; lines 337-339.
// Oracle: Value1 is 0, Value2 is 1, Value3 is 2.
// Extra: empty/default first enumerator is 0; Value3 is the last-index boundary.
// DefaultSafe. Source owns locals.

enum EEnumBasic
{
	Value1,
	Value2,
	Value3
}

int Observe_EEnumBasic_Value1Default()
{
	return int(EEnumBasic::Value1);
}

int Observe_EEnumBasic_Value2()
{
	return int(EEnumBasic::Value2);
}

int Observe_EEnumBasic_Value3Boundary()
{
	return int(EEnumBasic::Value3);
}
