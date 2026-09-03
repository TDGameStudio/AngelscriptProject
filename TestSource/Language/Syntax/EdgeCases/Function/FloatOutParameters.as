/**
 * Float and double out parameters, including pair writes driven by a seed. The
 * observers confirm the constants land, that a zero seed preserves order, and
 * that prior storage is overwritten.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatOutParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FloatOutParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionParametersOut
 * @Provenance sha256=2509cb9ac431fa1b1829d8112b7dce7f294663a429bf612849598bff65f5c33a; lines 149-171.
 * @Provenance Oracle: WriteFloat copies 3.14159; WriteDouble copies 2.71828;
 * @Provenance WriteFloatPair(10) A=11 B=12; WriteDoublePair(20) A=21 B=22.
 * @Provenance Extra: pair seed 0 writes 1 then 2 (order preserved). DefaultSafe. &out overwrites caller storage.
 */

namespace SyntaxTest
{
	/**
	 * Writes a constant through a float out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 3.14159
	 * @Param X the out parameter
	 */
	void WriteFloat(float&out X)
	{
		X = 3.14159f;
	}

	/**
	 * Writes a constant through a double out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 2.71828
	 * @Param X the out parameter
	 */
	void WriteDouble(double&out X)
	{
		X = 2.71828;
	}

	/**
	 * Writes two floats seeded by one input.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the seed and two out parameters
	 * @Return nothing; A receives Seed+1 and B receives Seed+2
	 * @Param Seed the driving input
	 * @Param A the first out parameter
	 * @Param B the second out parameter
	 */
	void WriteFloatPair(float Seed, float&out A, float&out B)
	{
		A = Seed + 1.0f;
		B = Seed + 2.0f;
	}

	/**
	 * Writes two doubles seeded by one input.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the seed and two out parameters
	 * @Return nothing; A receives Seed+1 and B receives Seed+2
	 * @Param Seed the driving input
	 * @Param A the first out parameter
	 * @Param B the second out parameter
	 */
	void WriteDoublePair(double Seed, double&out A, double&out B)
	{
		A = Seed + 1.0;
		B = Seed + 2.0;
	}

	/**
	 * Observe that all four writes land their expected values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all four helpers with their nominal seeds
	 * @Return true when every written local matches
	 */
	UFUNCTION()
	bool FloatOutNominal()
	{
		float F = 0.0f;
		double D = 0.0;
		WriteFloat(F);
		WriteDouble(D);
		float FA = 0.0f;
		float FB = 0.0f;
		double DA = 0.0;
		double DB = 0.0;
		WriteFloatPair(10.0f, FA, FB);
		WriteDoublePair(20.0, DA, DB);

		if (!Math::IsNearlyEqual(F, 3.14159, 0.00001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(D, 2.71828, 0.00001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FA, 11.0, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FB, 12.0, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(DA, 21.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(DB, 22.0, 0.001);
	}

	/**
	 * Observe that a zero seed writes 1 then 2 in order.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteFloatPair with seed 0
	 * @Return true when A is 1 and B is 2
	 * @Boundary zero seed
	 */
	UFUNCTION()
	bool FloatOutPairZeroSeed()
	{
		float A = 99.0f;
		float B = 99.0f;
		WriteFloatPair(0.0f, A, B);

		if (!Math::IsNearlyEqual(A, 1.0, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(B, 2.0, 0.001);
	}

	/**
	 * Observe that a write overwrites prior storage.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteFloat into a local holding -1
	 * @Return true when the local reads 3.14159
	 * @Boundary overwrite prior
	 */
	UFUNCTION()
	bool FloatOutOverwritesPrior()
	{
		float X = -1.0f;
		WriteFloat(X);
		return Math::IsNearlyEqual(X, 3.14159, 0.00001);
	}
}
