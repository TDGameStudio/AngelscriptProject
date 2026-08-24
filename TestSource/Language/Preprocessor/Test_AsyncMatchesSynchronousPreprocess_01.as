// Theme: Language.Preprocessor. Positive: async-load provider module.
// C++: AngelscriptPreprocessorAsyncTests.cpp::AsyncMatchesSynchronousPreprocess
// Provider.as; lines 318-324;
// sha256=676298873b957c62de25b0838f6e865697e5dfa21a1aba12352f25d17080e123.
// Oracle: ProvideValue() == 7; ProviderMultiplier == 3.
// Extra: 7 * 3 == 21 is the consumer product; multiplier default is 3.
// DefaultSafe. C++ padding after this body is load-size only, not source.

const int ProviderMultiplier = 3;

int ProvideValue()
{
	return 7;
}

bool Observe_ProvideValue_Nominal()
{
	return ProvideValue() == 7;
}

bool Observe_ProviderMultiplier_Default()
{
	return ProviderMultiplier == 3;
}

bool Observe_ProviderProduct_Boundary()
{
	return ProvideValue() * ProviderMultiplier == 21;
}
