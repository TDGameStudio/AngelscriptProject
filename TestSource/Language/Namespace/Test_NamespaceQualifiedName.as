// Theme: Language.Namespace. Positive: qualified names disambiguate same identifiers.
// C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceQualifiedName ExpectGlobalReturn.
// sha256=73c7ccc78a18b163329763ccb7313f8a7007f36540e6bba729597b784438bdc1; lines 285-345.
// Oracle: UseQualifiedNames() == 300; UseConstants() == 110; UseSameNameDifferentNamespace() == 50.
// Extra: Alpha::GetValue() == 100 vs Beta 200; NS1::Calculate(0) == 0 zero boundary.
// DefaultSafe.

namespace Alpha
{
	const int Value = 100;

	int GetValue()
	{
		return Value;
	}
}

namespace Beta
{
	const int Value = 200;

	int GetValue()
	{
		return Value;
	}
}

int UseQualifiedNames()
{
	return Alpha::GetValue() + Beta::GetValue();
}

namespace Constants
{
	const int MAX_SIZE = 100;
	const int MIN_SIZE = 10;
}

int UseConstants()
{
	return Constants::MAX_SIZE + Constants::MIN_SIZE;
}

namespace NS1
{
	int Calculate(int X)
	{
		return X * 2;
	}
}

namespace NS2
{
	int Calculate(int X)
	{
		return X * 3;
	}
}

int UseSameNameDifferentNamespace()
{
	return NS1::Calculate(10) + NS2::Calculate(10);
}

bool Observe_QualifiedNames_Nominal()
{
	return UseQualifiedNames() == 300 && UseConstants() == 110 && UseSameNameDifferentNamespace() == 50;
}

bool Observe_QualifiedValues_Isolated()
{
	return Alpha::GetValue() == 100 && Beta::GetValue() == 200;
}

int Observe_Calculate_ZeroBoundary()
{
	return NS1::Calculate(0) + NS2::Calculate(0);
}
