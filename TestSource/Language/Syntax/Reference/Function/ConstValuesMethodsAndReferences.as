/**
 * Const values combined with reference parameters: a module-level const read by
 * a local const, a const &in parameter, and a const container iterated by
 * reference. The observers exercise the nominal values plus the zero and empty
 * boundaries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Reference.ConstValuesMethodsAndReferences
 * @Harness Function
 * @Tag Language.Syntax.Reference.ConstValuesMethodsAndReferences
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageConstTests.cpp::ConstValuesMethodsAndReferences ExpectGlobalReturn.
 * @Provenance sha256=43fa01adabb1202a2732aa9003f80bca66d0ac5b7c3f355ece575f665dd30538; lines 60-98.
 * @Provenance Oracle: LocalConstValue==17; ConstInRefRead==64; ConstContainerRead==12.
 * @Provenance Extra: AddReadonly(0)==30; SumConstArray(empty)==0. DefaultSafe. Source owns locals.
 */

const int GlobalLimit = 12;

namespace SyntaxTest
{
	/**
	 * Combines a local const with the module-level const.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs the module-level const GlobalLimit
	 * @Return 17
	 */
	int LocalConstValue()
	{
		const int LocalLimit = 5;
		return LocalLimit + GlobalLimit;
	}

	/**
	 * Reads a const reference parameter without writing it.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs a const int&in Amount
	 * @Return 30 plus the amount
	 * @Param Amount the read-only addend
	 */
	int AddReadonly(const int&in Amount)
	{
		return 30 + Amount;
	}

	/**
	 * Passes a local const into a const reference parameter.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs the const local Bonus
	 * @Return 64
	 */
	int ConstInRefRead()
	{
		const int Bonus = 34;
		return AddReadonly(Bonus);
	}

	/**
	 * Sums a const container by iterating it by reference.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs a const TArray<int>&in Values
	 * @Return the sum of all elements
	 * @Param Values the read-only container
	 */
	int SumConstArray(const TArray<int>&in Values)
	{
		int Sum = 0;
		for (const int& Value : Values)
		{
			Sum += Value;
		}
		return Sum;
	}

	/**
	 * Builds a container and sums it through the const parameter.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs the values 3, 4 and 5
	 * @Return 12
	 */
	int ConstContainerRead()
	{
		TArray<int> Values;
		Values.Add(3);
		Values.Add(4);
		Values.Add(5);
		return SumConstArray(Values);
	}

	/**
	 * Observe that all three const forms produce their expected values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs LocalConstValue, ConstInRefRead and ConstContainerRead
	 * @Return true when all three match
	 */
	UFUNCTION()
	bool ConstValuesProduceExpectedValues()
	{
		if (LocalConstValue() != 17)
		{
			return false;
		}

		if (ConstInRefRead() != 64)
		{
			return false;
		}

		return ConstContainerRead() == 12;
	}

	/**
	 * Observe the zero boundary of the const reference read.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs AddReadonly(0)
	 * @Return 30
	 * @Boundary zero amount
	 */
	UFUNCTION()
	int AddReadonlyZeroBoundary()
	{
		return AddReadonly(0);
	}

	/**
	 * Observe the empty boundary of the const container sum.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs SumConstArray over an empty array
	 * @Return 0
	 * @Boundary empty container
	 */
	UFUNCTION()
	int SumConstArrayEmptyBoundary()
	{
		TArray<int> Empty;
		return SumConstArray(Empty);
	}
}
