// Theme: Language.Syntax.EdgeCases. C++ originally expected F-prefix failure.
// Live C++: Struct_Negative block 4 is #if 0 (naming-convention-unenforced);
// USTRUCT MyStruct compiles. CSV NegativeDiagnostic is not a compile-fail.
// sha256=bd6fc5d6a0b92e3ee1a4fdbae58f4bd872a116afce7131a1f4ee12122c121b8c; lines 299-306.
// Oracle: UPROPERTY X defaults to 0.
// Extra: empty default 0; write 5 is the boundary; copy then write leaves original X.
// DefaultSafe. Keep UPROPERTY name X.

USTRUCT()
struct MyStruct
{
	UPROPERTY()
	int X;
}

int Observe_MyStruct_DefaultX()
{
	MyStruct S;
	return S.X;
}

int Observe_MyStruct_WriteBoundary()
{
	MyStruct S;
	S.X = 5;
	return S.X;
}

int Observe_MyStruct_CopyIndependentX()
{
	MyStruct A;
	A.X = 3;
	MyStruct B = A;
	B.X = 0;
	return A.X;
}
