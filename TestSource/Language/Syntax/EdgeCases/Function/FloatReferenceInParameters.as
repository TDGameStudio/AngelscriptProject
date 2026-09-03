/**
 * Float and double parameters passed by const reference. The helpers scale their
 * inputs, and the observers confirm the results, the zero boundary, and that the
 * caller's locals are untouched.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatReferenceInParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FloatReferenceInParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionParametersIn
 * @Provenance sha256=83a16b441bebf3384acb18cc392912c420691448520e2533996c8dc183cb2f04; lines 95-105.
 * @Provenance Oracle: AcceptFloatIn(5.5) ~= 11.0; AcceptDoubleIn(10.5) ~= 31.5.
 * @Provenance Extra: zero yields zero; input is not mutated. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Doubles a float received by const reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming float reference
	 * @Return the input times 2
	 * @Param X the read-only reference
	 */
	float AcceptFloatIn(const float&in X)
	{
		return X * 2.0f;
	}

	/**
	 * Triples a double received by const reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming double reference
	 * @Return the input times 3
	 * @Param X the read-only reference
	 */
	double AcceptDoubleIn(const double&in X)
	{
		return X * 3.0;
	}

	/**
	 * Observe that both helpers scale their inputs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AcceptFloatIn(5.5) and AcceptDoubleIn(10.5)
	 * @Return true when the results are 11.0 and 31.5
	 */
	UFUNCTION()
	bool FloatInNominal()
	{
		if (!Math::IsNearlyEqual(AcceptFloatIn(5.5f), 11.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AcceptDoubleIn(10.5), 31.5, 0.001);
	}

	/**
	 * Observe that zero inputs scale to zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AcceptFloatIn(0.0) and AcceptDoubleIn(0.0)
	 * @Return true when both results are zero
	 * @Boundary zero input
	 */
	UFUNCTION()
	bool FloatInZeroDefault()
	{
		if (!Math::IsNearlyEqual(AcceptFloatIn(0.0f), 0.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AcceptDoubleIn(0.0), 0.0, 0.001);
	}

	/**
	 * Observe that the caller's locals survive the calls unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs float and double locals passed by const reference
	 * @Return true when the inputs keep their values and the results are correct
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FloatInCopyIndependence()
	{
		float F = 5.5f;
		double D = 10.5;
		float FResult = AcceptFloatIn(F);
		double DResult = AcceptDoubleIn(D);

		if (!Math::IsNearlyEqual(F, 5.5, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(D, 10.5, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FResult, 11.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(DResult, 31.5, 0.001);
	}
}
