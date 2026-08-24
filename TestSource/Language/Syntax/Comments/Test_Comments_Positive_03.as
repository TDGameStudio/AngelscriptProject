// Theme: Language.Syntax.Comments. Positive: inline line and block comments inside a function compile.
// C++: AngelscriptSyntaxMiscTests.cpp::Comments_Positive block 3
// sha256=ca5807eb64816fd1ac154214cb39e5a724e3833d170b7e10d72206e02def1c63; lines 64-70.
// Oracle: Test() runs with X=1, Y=2, Z=3 beside comments.
// Extra: calling Test twice is a no-op boundary. DefaultSafe.

void Test()
{
	int X = 1; // inline comment
	int Y = 2; /* block */ int Z = 3;
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
