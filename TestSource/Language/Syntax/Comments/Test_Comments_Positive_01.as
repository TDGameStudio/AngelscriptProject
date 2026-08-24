// Theme: Language.Syntax.Comments. Positive: single-line comment before a function compiles.
// C++: AngelscriptSyntaxMiscTests.cpp::Comments_Positive block 1
// sha256=f00695e9ef1ffce160959b7c4c392fd03917e6742fdfadad3b529d8390ccf4a0; lines 49-52.
// Oracle: Test() runs after "// This is a comment".
// Extra: calling Test twice is a no-op boundary. DefaultSafe.

// This is a comment
void Test()
{
	int X = 1;
}

int Observe_Test_Runs()
{
	Test();
	return 1;
}

int Observe_Test_RepeatBoundary()
{
	Test();
	Test();
	return 1;
}
