// Theme: Language.Syntax.Comments. Positive: multi-line block comment before a function compiles.
// C++: AngelscriptSyntaxMiscTests.cpp::Comments_Positive block 2
// sha256=21a4222d526e33adddc7cb47783d28ae5cb40b84461a1b86d5d9b226a10a350c; lines 56-60.
// Oracle: Test() runs after the block comment.
// Extra: calling Test twice is a no-op boundary. DefaultSafe.

/* This is a
   multi-line comment */
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
