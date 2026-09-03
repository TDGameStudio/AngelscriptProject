/**
 * A const method on a script struct. The observers confirm the method reads the
 * default, an assigned value, and a const instance, and that struct copies do not
 * share state.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.StructConstMethod
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.StructConstMethod
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 6 AssertCompiles.
 * @Provenance sha256=30063884b6d69987139db1c00015b1750b03f37b1d07aa7cf46809e210667a7c; lines 664-670.
 * @Provenance Oracle: Get() returns X. Extra: default X is 0; assigned 7; const instance still 0.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * A struct whose reader is marked const.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the struct's X
	 * @Return the value of X
	 */
	struct FStructFuncConst
	{
		int X = 0;

		/**
		 * Reads the member without writing it.
		 *
		 * @Covers Syntax.EdgeCases
		 * @Inputs the struct's X
		 * @Return the value of X
		 */
		int Get() const
		{
			return X;
		}
	}

	/**
	 * Observe the default state read through the const method.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed struct
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int StructConstMethodDefaultZero()
	{
		FStructFuncConst S;
		return S.Get();
	}

	/**
	 * Observe that the const method reads an assigned member.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a struct whose X was set to 7
	 * @Return 7
	 */
	UFUNCTION()
	int StructConstMethodAssigned()
	{
		FStructFuncConst S;
		S.X = 7;
		return S.Get();
	}

	/**
	 * Observe that the const method is callable on a const instance.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a const struct
	 * @Return 0
	 * @Boundary const instance
	 */
	UFUNCTION()
	int StructConstMethodConstInstance()
	{
		const FStructFuncConst S;
		return S.Get();
	}

	/**
	 * Observe that struct copies do not share state.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two structs, one written to
	 * @Return true when the first reads 9 and the second reads 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool StructConstMethodCopyIndependence()
	{
		FStructFuncConst First;
		FStructFuncConst Second;
		First.X = 9;

		if (First.Get() != 9)
		{
			return false;
		}

		return Second.Get() == 0;
	}
}
