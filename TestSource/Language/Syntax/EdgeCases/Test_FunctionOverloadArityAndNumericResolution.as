// Theme: Language.Syntax.EdgeCases. Positive overload by arity and int vs double.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionOverloadArityAndNumericResolution
// sha256=790139a8f51bde01b840862b7f18175c3d8a073e02631278475b1a562f1cca73; lines 1028-1078.
// Oracle: CallChooseOne/Two/Three == 42; CallNumericInt()==42; CallNumericDouble()==42.
// Extra: Choose(0)==1 empty arity-1; Numeric(0.0) uses double overload -> 20.
// DefaultSafe. Source owns locals.

int Choose(int A)
{
	return A + 1;
}

int Choose(int A, int B)
{
	return A + B + 2;
}

int Choose(int A, int B, int C)
{
	return A + B + C + 3;
}

int Numeric(int Value)
{
	return Value + 10;
}

int Numeric(double Value)
{
	return int(Value) + 20;
}

int CallChooseOne()
{
	return Choose(41);
}

int CallChooseTwo()
{
	return Choose(10, 30);
}

int CallChooseThree()
{
	return Choose(10, 20, 9);
}

int CallNumericInt()
{
	return Numeric(32);
}

int CallNumericDouble()
{
	return Numeric(22.5);
}

bool Observe_FunctionOverloadArity_Nominal()
{
	return CallChooseOne() == 42
		&& CallChooseTwo() == 42
		&& CallChooseThree() == 42
		&& CallNumericInt() == 42
		&& CallNumericDouble() == 42;
}

int Observe_FunctionOverloadArity_EmptyOne()
{
	return Choose(0);
}

int Observe_FunctionOverloadArity_DoubleZero()
{
	return Numeric(0.0);
}
