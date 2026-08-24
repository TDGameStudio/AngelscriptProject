// Theme: Language.Syntax.EdgeCases. C++ originally expected E-prefix failure.
// Live C++: Enum_Negative block 4 is #if 0 (naming-convention-unenforced);
// UENUM MyEnum compiles. CSV NegativeDiagnostic is not a compile-fail.
// sha256=63c0f233b26d169c7c1bd0a67ba2981d087daacd9347d002ff044ab8495a0ca2; lines 400-403.
// Oracle: MyEnum::Value1 is 0.
// Extra: default first enumerator is 0; a stored Value1 still converts to 0.
// DefaultSafe value oracle.

UENUM()
enum MyEnum
{
	Value1
}

int Observe_MyEnum_Value1Default()
{
	return int(MyEnum::Value1);
}

int Observe_MyEnum_StoredValue1()
{
	MyEnum E = MyEnum::Value1;
	return int(E);
}

int Observe_MyEnum_NotANonZeroBoundary()
{
	MyEnum E = MyEnum::Value1;
	if (int(E) != 0)
	{
		return int(E);
	}
	return 0;
}
