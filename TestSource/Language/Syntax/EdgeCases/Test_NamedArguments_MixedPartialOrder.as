// Theme: Language.Syntax.EdgeCases. Positive mixed positional/named argument binding.
// C++: AngelscriptFunctionTests.cpp::NamedArguments_MixedPartialOrder ExpectGlobalInt
// sha256=9be8ef1b562003804d8ac8351bc8e33a87c241e37919587605e18197c7173ea6; lines 77-97.
// Oracle: RunMixed()==456; RunPartial()==789; Run()==456789.
// Extra: Mix(0,0,0)==0 empty; Mix(1,2,3)==123 positional order is independent of named suffix.
// DefaultSafe. Source owns locals.

int Mix(int A, int B, int C)
{
	return A * 100 + B * 10 + C;
}

int RunMixed()
{
	return Mix(4, C: 6, B: 5);
}

int RunPartial()
{
	return Mix(A: 7, C: 9, B: 8);
}

int Run()
{
	return RunMixed() * 1000 + RunPartial();
}

bool Observe_NamedArgumentsMixed_Nominal()
{
	return Run() == 456789 && RunMixed() == 456 && RunPartial() == 789;
}

int Observe_NamedArgumentsMixed_EmptyZero()
{
	return Mix(0, 0, 0);
}

int Observe_NamedArgumentsMixed_Positional()
{
	return Mix(1, 2, 3);
}
