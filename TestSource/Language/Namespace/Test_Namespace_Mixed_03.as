// Theme: Language.Namespace. Positive: nested namespace value.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 3 AssertCompiles (currently #if 0).
// sha256=53012c39fdc493a486b19c2665c868075ae6efc8b3d393ef8019f3e2e56e2206; lines 502-510.
// Oracle: Outer::Inner::Value == 1.
// Extra: a copied int does not alias the nested global.
// DefaultSafe. PlannedSymbols empty.

namespace Outer
{
	namespace Inner
	{
		int Value = 1;
	}
}

int Observe_NestedValue_Nominal()
{
	return Outer::Inner::Value;
}

bool Observe_NestedValue_CopyIndependence()
{
	int Copy = Outer::Inner::Value;
	Copy = 0;
	return Outer::Inner::Value == 1;
}
