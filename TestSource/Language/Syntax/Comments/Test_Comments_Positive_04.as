// Theme: Language.Syntax.Comments. Positive: block comment with * and / as separate characters compiles.
// C++: AngelscriptSyntaxMiscTests.cpp::Comments_Positive block 4
// sha256=7c35629ab2cdfb1a0b0dc8d5a317c4630304647563d8ca50f4a05f2b317ec89f; lines 74-77.
// Oracle: empty Test() runs after "/* Comment with * and / separately */".
// Extra: calling Test twice is a no-op boundary. DefaultSafe.

/* Comment with * and / separately */
void Test()
{
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
