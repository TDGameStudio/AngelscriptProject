// Theme: Language.Syntax.Reference. Positive int &out / &inout / const &in combinations.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionReferenceParameterCombinations.
// sha256=e45fe14a43a9b0e64e2543f1ac5a384c6647646f4b0e6607173b8a3ba6384700; lines 796-824.
// Oracle: DefaultAndOutUsingDefault writes 20; DefaultAndOut(Result,7) writes 14;
// MultipleOutOrder(40) writes 41,42,43; PreserveInOut(20) writes 41; ConstInValue(41)==42.
// Extra: DefaultAndOut(...,0) writes 0; PreserveInOut(0) writes 1; ConstInValue(0)==1.
// DefaultSafe. Source owns locals.

void DefaultAndOut(int&out Result, int Value = 10)
{
	Result = Value * 2;
}

void DefaultAndOutUsingDefault(int&out Result)
{
	DefaultAndOut(Result);
}

void MultipleOutOrder(int Seed, int&out A, int&out B, int&out C)
{
	A = Seed + 1;
	B = Seed + 2;
	C = Seed + 3;
}

void PreserveInOut(int&inout Value)
{
	int Original = Value;
	Value = Original * 2 + 1;
}

int ConstInValue(const int&in Value)
{
	return Value + 1;
}

int Observe_DefaultAndOutUsingDefault()
{
	int Result = 0;
	DefaultAndOutUsingDefault(Result);
	return Result;
}

int Observe_DefaultAndOut_Explicit()
{
	int Result = 0;
	DefaultAndOut(Result, 7);
	return Result;
}

int Observe_DefaultAndOut_ZeroBoundary()
{
	int Result = 99;
	DefaultAndOut(Result, 0);
	return Result;
}

bool Observe_MultipleOutOrder_Nominal()
{
	int A = 0;
	int B = 0;
	int C = 0;
	MultipleOutOrder(40, A, B, C);
	return A == 41 && B == 42 && C == 43;
}

int Observe_PreserveInOut_Nominal()
{
	int Value = 20;
	PreserveInOut(Value);
	return Value;
}

int Observe_PreserveInOut_ZeroBoundary()
{
	int Value = 0;
	PreserveInOut(Value);
	return Value;
}

int Observe_ConstInValue_Nominal()
{
	return ConstInValue(41);
}

int Observe_ConstInValue_ZeroBoundary()
{
	return ConstInValue(0);
}
