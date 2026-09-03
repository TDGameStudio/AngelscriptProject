/**
 * A const method on a struct. The method can be called on a plain instance, on
 * a mutated instance, and on a const instance, and each call reads the current
 * member value.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Keywords.ConstMethodOnStruct
 * @Harness Function
 * @Tag Language.Syntax.Keywords.ConstMethodOnStruct
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Positive block 5 AssertCompiles.
 * @Provenance sha256=d9b1a1350b2d249607393e5ee31476ef0a8a571900a68e8ae8128e565868eea5; lines 158-164.
 * @Provenance Oracle: GetX() returns X. Extra: default 0; assigned 9; const instance 0.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	struct FStructConst
	{
		int X = 0;

		/**
		 * Reads the member without writing it.
		 *
		 * @Covers Syntax.Keywords
		 * @Inputs the struct's X
		 * @Return the value of X
		 */
		int GetX() const
		{
			return X;
		}
	}

	/**
	 * Observe the default state read through the const method.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs a default-constructed FStructConst
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int ConstMethodReadsDefault()
	{
		FStructConst S;
		return S.GetX();
	}

	/**
	 * Observe that the const method reads a mutated member.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs a struct whose X was set to 9
	 * @Return 9
	 */
	UFUNCTION()
	int ConstMethodReadsAssignedValue()
	{
		FStructConst S;
		S.X = 9;
		return S.GetX();
	}

	/**
	 * Observe that the const method is callable on a const instance.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs a const FStructConst
	 * @Return 0
	 * @Boundary const instance
	 */
	UFUNCTION()
	int ConstMethodReadsConstInstance()
	{
		const FStructConst S;
		return S.GetX();
	}

	/**
	 * Observe that two structs do not share state.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs two structs, one written to
	 * @Return true when the first reads 4 and the second reads 0
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool ConstMethodInstancesAreIndependent()
	{
		FStructConst First;
		FStructConst Second;
		First.X = 4;

		if (First.GetX() != 4)
		{
			return false;
		}

		return Second.GetX() == 0;
	}
}
