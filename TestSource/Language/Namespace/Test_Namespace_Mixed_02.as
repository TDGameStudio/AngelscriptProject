// Theme: Language.Namespace. Positive: qualified call into a namespaced function.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 2 AssertCompiles.
// sha256=27c17694fca0d0543388d121b63934cbb96f07b42d6696c6d656b48df0c958d7; lines 486-496.
// Oracle: MySpaceAccess::GetVal() == 42.
// Extra: calling GetVal twice is independent; Test() still performs the qualified read.
// DefaultSafe.

namespace MySpaceAccess
{
	int GetVal()
	{
		return 42;
	}
}

void Test()
{
	int X = MySpaceAccess::GetVal();
}

int Observe_GetVal_Nominal()
{
	return MySpaceAccess::GetVal();
}

bool Observe_GetVal_RepeatedCallsIndependent()
{
	int First = MySpaceAccess::GetVal();
	int Second = MySpaceAccess::GetVal();
	return First == 42 && Second == 42;
}
