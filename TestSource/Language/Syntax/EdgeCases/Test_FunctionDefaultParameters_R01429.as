// Theme: Language.Syntax.EdgeCases. Positive default arguments through script wrappers.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionDefaultParameters
// sha256=4b20fb582a9b3baf296ce5405c5add9e94305a003c0bb1114f46ed7bec785fef; lines 568-598.
// Oracle: AddWithDefault(32, 10)==42; AddUsingDefault(32)==42; MultiplyUsingDefault(5000000000)==10000000000;
// ChainUsingDefaults()==30.
// Extra: AddWithDefault(0)==10 empty a; ChainDefaults(1, 2, 3)==6 explicit override.
// DefaultSafe. Source owns locals.

int AddWithDefault(int a, int b = 10)
{
	return a + b;
}

int AddUsingDefault(int a)
{
	return AddWithDefault(a);
}

int64 MultiplyWithDefault(int64 x, int64 y = 2)
{
	return x * y;
}

int64 MultiplyUsingDefault(int64 x)
{
	return MultiplyWithDefault(x);
}

uint ChainDefaults(uint a = 5, uint b = 10, uint c = 15)
{
	return a + b + c;
}

uint ChainUsingDefaults()
{
	return ChainDefaults();
}

bool Observe_FunctionDefaultParameters_Nominal()
{
	return AddWithDefault(32, 10) == 42
		&& AddUsingDefault(32) == 42
		&& MultiplyUsingDefault(5000000000) == 10000000000
		&& ChainUsingDefaults() == 30;
}

int Observe_FunctionDefaultParameters_EmptyA()
{
	return AddUsingDefault(0);
}

uint Observe_FunctionDefaultParameters_ExplicitOverride()
{
	return ChainDefaults(1, 2, 3);
}
