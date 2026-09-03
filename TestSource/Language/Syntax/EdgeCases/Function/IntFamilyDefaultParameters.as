/**
 * Default arguments through script wrappers, including a three-default chain.
 * The observers confirm the defaults apply when omitted and that explicit
 * arguments override all of them at once.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntFamilyDefaultParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.IntFamilyDefaultParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionDefaultParameters
 * @Provenance sha256=4b20fb582a9b3baf296ce5405c5add9e94305a003c0bb1114f46ed7bec785fef; lines 568-598.
 * @Provenance Oracle: AddWithDefault(32, 10)==42; AddUsingDefault(32)==42; MultiplyUsingDefault(5000000000)==10000000000;
 * @Provenance ChainUsingDefaults()==30.
 * @Provenance Extra: AddWithDefault(0)==10 empty a; ChainDefaults(1, 2, 3)==6 explicit override.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Adds an int with a defaulted addend.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required a and an optional b defaulting to 10
	 * @Return the sum of both
	 * @Param a the required addend
	 * @Param b the optional addend
	 */
	int AddWithDefault(int a, int b = 10)
	{
		return a + b;
	}

	/**
	 * Calls the add helper relying on its default.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required int
	 * @Return the input plus 10
	 * @Param a the required addend
	 */
	int AddUsingDefault(int a)
	{
		return AddWithDefault(a);
	}

	/**
	 * Multiplies an int64 with a defaulted factor.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required x and an optional y defaulting to 2
	 * @Return the product of both
	 * @Param x the required factor
	 * @Param y the optional factor
	 */
	int64 MultiplyWithDefault(int64 x, int64 y = 2)
	{
		return x * y;
	}

	/**
	 * Calls the multiply helper relying on its default.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required int64
	 * @Return the input times 2
	 * @Param x the required factor
	 */
	int64 MultiplyUsingDefault(int64 x)
	{
		return MultiplyWithDefault(x);
	}

	/**
	 * Sums three uints each carrying their own default.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs three optional uints defaulting to 5, 10 and 15
	 * @Return the sum of all three
	 * @Param a the first optional addend
	 * @Param b the second optional addend
	 * @Param c the third optional addend
	 */
	uint ChainDefaults(uint a = 5, uint b = 10, uint c = 15)
	{
		return a + b + c;
	}

	/**
	 * Calls the chain helper relying on all three defaults.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 30, the sum of the three defaults
	 */
	uint ChainUsingDefaults()
	{
		return ChainDefaults();
	}

	/**
	 * Observe that every default applies when omitted.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all four default-omitting paths
	 * @Return true when all four results match
	 */
	UFUNCTION()
	bool IntFamilyDefaultsNominal()
	{
		if (AddWithDefault(32, 10) != 42)
		{
			return false;
		}

		if (AddUsingDefault(32) != 42)
		{
			return false;
		}

		if (MultiplyUsingDefault(5000000000) != 10000000000)
		{
			return false;
		}

		return ChainUsingDefaults() == 30;
	}

	/**
	 * Observe the zero boundary through the default-omitting path.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AddUsingDefault(0)
	 * @Return 10
	 * @Boundary zero input
	 */
	UFUNCTION()
	int IntFamilyDefaultsEmptyA()
	{
		return AddUsingDefault(0);
	}

	/**
	 * Observe that explicit arguments override the whole chain.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ChainDefaults(1, 2, 3)
	 * @Return 6
	 * @Boundary explicit override
	 */
	UFUNCTION()
	uint IntFamilyDefaultsExplicitOverride()
	{
		return ChainDefaults(1, 2, 3);
	}
}
