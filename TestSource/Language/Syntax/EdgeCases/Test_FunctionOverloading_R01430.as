// Theme: Language.Syntax.EdgeCases. Positive overload resolution by int width.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionOverloading
// sha256=12c7992c1117bcefb64b944cc0ba4bbc8dde431f9d1c1f2644e305ae5fe27440; lines 652-682.
// Oracle: CallProcessInt()==142; CallProcessInt64()==9001000000; CallProcessUInt()==3000000200.
// Extra: Process(0)==100 empty int overload; Process(int64(0))==1000000 empty int64 overload.
// DefaultSafe. Source owns locals.

int Process(int x)
{
	return x + 100;
}

int64 Process(int64 x)
{
	return x + 1000000;
}

uint Process(uint x)
{
	return x + 200;
}

int CallProcessInt()
{
	return Process(42);
}

int64 CallProcessInt64()
{
	return Process(int64(9000000000));
}

uint CallProcessUInt()
{
	return Process(uint(3000000000));
}

bool Observe_FunctionOverloading_Nominal()
{
	return CallProcessInt() == 142
		&& CallProcessInt64() == 9001000000
		&& CallProcessUInt() == 3000000200;
}

int Observe_FunctionOverloading_EmptyInt()
{
	return Process(0);
}

int64 Observe_FunctionOverloading_EmptyInt64()
{
	return Process(int64(0));
}
