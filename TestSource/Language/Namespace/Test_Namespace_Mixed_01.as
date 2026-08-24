// Theme: Language.Namespace. Positive: namespace-scoped global int.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 1 AssertCompiles (currently #if 0).
// sha256=810334f2a1d1aa24f0994d0f0a78344ca363c7b0337f03cf54dea263ac93011d; lines 479-481.
// Oracle: MySpaceBasic::GlobalVal == 42.
// Extra: a copied int does not alias the namespace global.
// DefaultSafe. PlannedSymbols empty.

namespace MySpaceBasic
{
	int GlobalVal = 42;
}

int Observe_GlobalVal_Nominal()
{
	return MySpaceBasic::GlobalVal;
}

bool Observe_GlobalVal_CopyIndependence()
{
	int Copy = MySpaceBasic::GlobalVal;
	Copy = 0;
	return MySpaceBasic::GlobalVal == 42;
}
