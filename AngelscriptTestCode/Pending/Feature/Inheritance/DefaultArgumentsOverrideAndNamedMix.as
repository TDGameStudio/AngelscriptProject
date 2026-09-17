/**
 * @version v1
 * @summary Default, positional-override and named-partial arguments on a three-parameter formatter. C++ ExecuteIntFunction reads RunDefault, RunOverride and RunNamedPartial by those names, so they are kept. The extra observers.
 * @topic Feature
 */
/**
 * @version root
 * @summary Default, positional-override and named-partial arguments on a three-parameter formatter. C++ ExecuteIntFunction reads RunDefault, RunOverride and RunNamedPartial by those names, so they are kept. The extra observers.
 * @topic Baseline
 */
namespace InheritanceTest
{
	/**
	 * Pack three integers as A*100 + B*10 + C, defaulting B to 5 and C to 9.
	 *
	 * @Kind Helper
	 * @Covers Inheritance.DefaultArgumentsOverrideAndNamedMix
	 * @Inputs A, optional B defaulting to 5, optional C defaulting to 9
	 * @Return A * 100 + B * 10 + C
	 * @Param A hundreds place
	 * @Param B tens place, default 5
	 * @Param C units place, default 9
	 */
	UFUNCTION()
	int Format(int A, int B = 5, int C = 9)
	{
		return A * 100 + B * 10 + C;
	}

	/**
	 * Observe the all-default path: Format(1) uses B=5 and C=9.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultArgumentsOverrideAndNamedMix
	 * @Inputs Format(1)
	 * @Return 159
	 */
	UFUNCTION()
	int RunDefault()
	{
		return Format(1);
	}

	/**
	 * Observe a positional override of B, leaving C at its default.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultArgumentsOverrideAndNamedMix
	 * @Inputs Format(1, 2)
	 * @Return 129
	 */
	UFUNCTION()
	int RunOverride()
	{
		return Format(1, 2);
	}

	/**
	 * Observe a named-partial call that sets A and C and keeps default B.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultArgumentsOverrideAndNamedMix
	 * @Inputs Format(A: 1, C: 3)
	 * @Return 153
	 */
	UFUNCTION()
	int RunNamedPartial()
	{
		return Format(A: 1, C: 3);
	}

	/**
	 * Observe the zero-A boundary with default B and C.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultArgumentsOverrideAndNamedMix
	 * @Inputs Format(0)
	 * @Return 9
	 * @Boundary A == 0
	 */
	UFUNCTION()
	int FormatZeroA()
	{
		return Format(0);
	}

	/**
	 * Observe an explicit override of B and C to zero.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultArgumentsOverrideAndNamedMix
	 * @Inputs Format(1, 0, 0)
	 * @Return 100
	 * @Boundary explicit zeros
	 */
	UFUNCTION()
	int FormatExplicitZeros()
	{
		return Format(1, 0, 0);
	}
}
/** @end */
