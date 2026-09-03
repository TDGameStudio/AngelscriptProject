/**
 * Int UFUNCTION specifiers, a defaulted parameter, and &out edges. CallableAdd,
 * PureDouble, DefaultInt, and SplitOut keep their names. DefaultInt() uses 10;
 * SplitOut writes A = Input + 1 and B = Input + 2.
 *
 * @Theme Feature.Default
 * @Subject Default.UFunctionSpecifierDefaultsAndOutParameters
 * @Harness UClass
 * @Tag Feature.Default.UFunctionSpecifierDefaultsAndOutParameters
 * @Provenance Theme: Feature.Default. WorldStory int UFUNCTION specifier, default, and &out edges.
 * @Provenance C++: AngelscriptCoverageIntFunctionTests.cpp::UFunctionSpecifierDefaultsAndOutParameters
 * @Provenance Oracle: CallableAdd(20, 22)==42; PureDouble(21)==42; DefaultInt(10)==42; SplitOut(40) A=41 B=42.
 * @Provenance Extra: zeros; DefaultInt() uses 10; SplitOut(0) A=1 B=2. Keep the four UFUNCTION names.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageIntFunctionEdgesActor : AActor
{
	/**
	 * Adds two ints as a BlueprintCallable.
	 *
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs two ints
	 * @Return A + B
	 * @Param A the first addend
	 * @Param B the second addend
	 */
	UFUNCTION(BlueprintCallable, Category = "Coverage|Int")
	int CallableAdd(int A, int B)
	{
		return A + B;
	}

	/**
	 * Doubles an int as a const BlueprintPure.
	 *
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs an int
	 * @Return Value * 2
	 * @Param Value the value to double
	 */
	UFUNCTION(BlueprintPure, Category = "Coverage|Int")
	int PureDouble(int Value) const
	{
		return Value * 2;
	}

	/**
	 * Scales a defaulted int: Value * 4 + 2, defaulting to 10.
	 *
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs an optional int defaulting to 10
	 * @Return Value * 4 + 2
	 * @Param Value the optional parameter
	 */
	UFUNCTION()
	int DefaultInt(int Value = 10)
	{
		return Value * 4 + 2;
	}

	/**
	 * Writes Input + 1 and Input + 2 through two &out ints.
	 *
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs an int plus two out ints
	 * @Return nothing; A and B are written
	 * @Param Input the source value
	 * @Param A receives Input + 1
	 * @Param B receives Input + 2
	 */
	UFUNCTION()
	void SplitOut(int Input, int&out A, int&out B)
	{
		A = Input + 1;
		B = Input + 2;
	}

	/**
	 * Observe CallableAdd at the C++ oracle inputs.
	 *
	 * @Kind Observe
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs CallableAdd(20, 22)
	 * @Return 42
	 */
	UFUNCTION()
	int CallableAddNominal()
	{
		return CallableAdd(20, 22);
	}

	/**
	 * Observe CallableAdd at zeros.
	 *
	 * @Kind Observe
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs CallableAdd(0, 0)
	 * @Return 0
	 * @Boundary zeros
	 */
	UFUNCTION()
	int CallableAddZeros()
	{
		return CallableAdd(0, 0);
	}

	/**
	 * Observe PureDouble at the C++ oracle input.
	 *
	 * @Kind Observe
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs PureDouble(21)
	 * @Return 42
	 */
	UFUNCTION()
	int PureDoubleNominal()
	{
		return PureDouble(21);
	}

	/**
	 * Observe DefaultInt with an explicit 10 matching the default.
	 *
	 * @Kind Observe
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs DefaultInt(10)
	 * @Return 42
	 */
	UFUNCTION()
	int DefaultIntExplicitTen()
	{
		return DefaultInt(10);
	}

	/**
	 * Observe DefaultInt with the default omitted.
	 *
	 * @Kind Observe
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs DefaultInt()
	 * @Return 42
	 */
	UFUNCTION()
	int DefaultIntOmittedDefault()
	{
		return DefaultInt();
	}

	/**
	 * Observe DefaultInt at the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs DefaultInt(0)
	 * @Return 2
	 * @Boundary zero
	 */
	UFUNCTION()
	int DefaultIntZeroBoundary()
	{
		return DefaultInt(0);
	}

	/**
	 * Observe SplitOut A at the C++ oracle input.
	 *
	 * @Kind Observe
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs SplitOut(40)
	 * @Return 41
	 */
	UFUNCTION()
	int SplitOutNominalA()
	{
		int A = 0;
		int B = 0;
		SplitOut(40, A, B);
		return A;
	}

	/**
	 * Observe SplitOut B at the C++ oracle input.
	 *
	 * @Kind Observe
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs SplitOut(40)
	 * @Return 42
	 */
	UFUNCTION()
	int SplitOutNominalB()
	{
		int A = 0;
		int B = 0;
		SplitOut(40, A, B);
		return B;
	}

	/**
	 * Observe SplitOut A at the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers Default.UFunctionSpecifierDefaultsAndOutParameters
	 * @Inputs SplitOut(0)
	 * @Return 1
	 * @Boundary zero input
	 */
	UFUNCTION()
	int SplitOutZeroBoundaryA()
	{
		int A = 0;
		int B = 0;
		SplitOut(0, A, B);
		return A;
	}
}
