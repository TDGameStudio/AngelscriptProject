/**
 * A struct overloads opIndex so the subscript operator reads into the TArray it
 * owns. The container starts empty, and copying it yields an array that is
 * independent of the original's.
 *
 * @Theme Language.Operators
 * @Subject Operators.ContainerOpIndex
 * @Harness Function
 * @Tag Language.Operators.ContainerOpIndex
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive AssertCompiles
 * @Provenance ASSyntaxOOIndex; lines 132-142;
 * @Provenance sha256=3704bc124d24c7b7f416aed96eb8a14950e268b914cceeb74aa99fec844bd2ec.
 * @Provenance Oracle: Container[0]==10 and Container[1]==20 after Add(10), Add(20).
 * @Provenance Extra: default Data.Num()==0; copied TArray is independent of the original.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace OperatorsTest
{
	struct FMyContainer
	{
		TArray<int> Data;

		/**
		 * Read an element of the owned array through the subscript operator.
		 */
		int opIndex(int Index) const
		{
			return Data[Index];
		}
	}

	/**
	 * Observe that the subscript operator reads back appended elements in order.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs A container holding 10 then 20
	 * @Return true when index 0 is 10 and index 1 is 20
	 */
	UFUNCTION()
	bool ContainerOpIndexReadsAppendedElements()
	{
		FMyContainer Container;
		Container.Data.Add(10);
		Container.Data.Add(20);

		if (Container[0] != 10)
		{
			return false;
		}
		return Container[1] == 20;
	}

	/**
	 * Observe the empty boundary: a default-constructed container owns an array
	 * with no elements.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs A default FMyContainer
	 * @Return true when the owned array has zero elements
	 * @Boundary empty container
	 */
	UFUNCTION()
	bool ContainerOpIndexDefaultsToEmptyArray()
	{
		FMyContainer Container;

		bool IsEmpty = Container.Data.Num() == 0;
		return IsEmpty;
	}

	/**
	 * Observe that copying a container deep-copies its array: writing through the
	 * copy leaves the original element untouched.
	 *
	 * @Kind Observe
	 * @Covers Operators.Overload
	 * @Inputs A container holding 7, copied, then the copy's element set to 9
	 * @Return true when the original still reads 7 and the copy reads 9
	 */
	UFUNCTION()
	bool ContainerOpIndexCopyIsIndependent()
	{
		FMyContainer Original;
		Original.Data.Add(7);
		FMyContainer Copy = Original;
		Copy.Data[0] = 9;

		if (Original[0] != 7)
		{
			return false;
		}
		return Copy[0] == 9;
	}
}
