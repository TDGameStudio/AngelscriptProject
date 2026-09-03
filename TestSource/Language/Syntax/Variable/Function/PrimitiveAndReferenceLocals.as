/**
 * Local variable declaration forms: primitives of several widths, a const local,
 * an auto local, and a reference local that aliases and mutates its target.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.PrimitiveAndReferenceLocals
 * @Harness Function
 * @Tag Language.Syntax.Variable.PrimitiveAndReferenceLocals
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Positive FScopedAngelscriptModule
 * @Provenance + ExpectGlobalInts Primitives=102, ConstVar=42, AutoVar=42, RefVar=10.
 * @Provenance sha256=b4b09d258041126060e9dd9a10f43175e4c8e2d4f87a75f3915380f7732d2d5e; lines 547-552.
 * @Provenance Extra: A=0 is the empty term inside Primitives; RefVar mutates 5 to 10.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Declares one local of each primitive kind and sums them.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 102, made up of an int, a float, a bool and an int64
	 */
	int Primitives()
	{
		int A = 0;
		float B = 1.0f;
		bool C = true;
		int64 D = 100;
		return A + int(B) + (C ? 1 : 0) + int(D);
	}

	/**
	 * Declares a const local.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 42
	 */
	int ConstLocal()
	{
		const int X = 42;
		return X;
	}

	/**
	 * Declares a local with an inferred type.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 42
	 */
	int AutoLocal()
	{
		auto X = 42;
		return X;
	}

	/**
	 * Declares a reference local and mutates through it.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 10, because the reference wrote through to X
	 */
	int ReferenceLocal()
	{
		int X = 5;
		int& Ref = X;
		Ref = 10;
		return X;
	}

	/**
	 * Observe that all four declaration forms produce their expected values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Variable
	 * @Inputs Primitives, ConstLocal, AutoLocal and ReferenceLocal
	 * @Return true when all four match
	 */
	UFUNCTION()
	bool VariableDeclarationFormsProduceExpectedValues()
	{
		if (Primitives() != 102)
		{
			return false;
		}

		if (ConstLocal() != 42)
		{
			return false;
		}

		if (AutoLocal() != 42)
		{
			return false;
		}

		return ReferenceLocal() == 10;
	}

	/**
	 * Observe the primitive sum on its own.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Variable
	 * @Inputs Primitives()
	 * @Return 102
	 */
	UFUNCTION()
	int PrimitiveLocalsSum()
	{
		return Primitives();
	}

	/**
	 * Observe that the reference local mutated its target.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Variable
	 * @Inputs ReferenceLocal()
	 * @Return 10
	 */
	UFUNCTION()
	int ReferenceLocalMutatesTarget()
	{
		return ReferenceLocal();
	}
}
