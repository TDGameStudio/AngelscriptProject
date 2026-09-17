/**
 * @version v1
 * @summary String-family operators: assignment, concatenation, compound concatenation, the six comparison operators, indexing, and the FName/FText specific operators. Because the operators are the subject under test, each helper.
 * @topic Language
 */
/**
 * @version root
 * @summary String-family operators: assignment, concatenation, compound concatenation, the six comparison operators, indexing, and the FName/FText specific operators. Because the operators are the subject under test, each helper.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Copies one string into another through assignment.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "First"
	 */
	FString OpAssignment()
	{
		FString a = "First";
		FString b = a;
		return b;
	}

	/**
	 * Concatenates three literals.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "Hello World"
	 */
	FString OpConcatenation()
	{
		return "Hello" + " " + "World";
	}

	/**
	 * Appends through the compound concatenation operator.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "Hello World"
	 */
	FString OpConcatAssignment()
	{
		FString s = "Hello";
		s += " World";
		return s;
	}

	/**
	 * Compares two equal literals for equality.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return true
	 */
	bool OpEquals()
	{
		bool Result = ("Test" == "Test");
		return Result;
	}

	/**
	 * Compares two differing literals for inequality.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return true
	 */
	bool OpNotEquals()
	{
		bool Result = ("ABC" != "XYZ");
		return Result;
	}

	/**
	 * Orders two literals with the less-than operator.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return true
	 */
	bool OpLessThan()
	{
		bool Result = ("AAA" < "BBB");
		return Result;
	}

	/**
	 * Orders two literals with the greater-than operator.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return true
	 */
	bool OpGreaterThan()
	{
		bool Result = ("ZZZ" > "AAA");
		return Result;
	}

	/**
	 * Orders two equal literals with the less-or-equal operator.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return true
	 */
	bool OpLessEqual()
	{
		bool Result = ("AAA" <= "AAA");
		return Result;
	}

	/**
	 * Orders two literals with the greater-or-equal operator.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return true
	 */
	bool OpGreaterEqual()
	{
		bool Result = ("BBB" >= "AAA");
		return Result;
	}

	/**
	 * Indexes the second character of a string.
	 *
	 * @Covers Literals.FString
	 * @Inputs the string "AZ"
	 * @Return the character code of 'Z'
	 */
	int OpIndex()
	{
		FString s = "AZ";
		return s[1];
	}

	/**
	 * Compares two equal names for equality.
	 *
	 * @Covers Literals.FString
	 * @Inputs two n"Test" names
	 * @Return true
	 */
	bool OpNameEquals()
	{
		FName a = n"Test";
		FName b = n"Test";
		bool Result = (a == b);
		return Result;
	}

	/**
	 * Compares two differing names for inequality.
	 *
	 * @Covers Literals.FString
	 * @Inputs n"Alpha" and n"Beta"
	 * @Return true
	 */
	bool OpNameNotEquals()
	{
		FName a = n"Alpha";
		FName b = n"Beta";
		bool Result = (a != b);
		return Result;
	}

	/**
	 * Compares a name's string form against a literal.
	 *
	 * @Covers Literals.FString
	 * @Inputs n"StringMatch"
	 * @Return true
	 */
	bool OpNameEqualsString()
	{
		FName a = n"StringMatch";
		bool Result = (a.ToString() == "StringMatch");
		return Result;
	}

	/**
	 * Reassigns a name and checks that earlier copies keep their value.
	 *
	 * @Covers Literals.FString
	 * @Inputs n"Original" copied then reassigned to n"Updated"
	 * @Return true when the copy is stable and the original moved
	 */
	bool OpNameReassignmentKeepsPreviousCopiesStable()
	{
		FName original = n"Original";
		FName copy = original;
		original = n"Updated";

		bool CopyStable = (copy == n"Original");
		bool OriginalMoved = (original == n"Updated");
		bool Result = (CopyStable && OriginalMoved);
		return Result;
	}

	/**
	 * Checks that two identically built FTexts are not IdenticalTo.
	 *
	 * @Covers Literals.FString
	 * @Inputs two FTexts wrapping "Display"
	 * @Return true, since IdenticalTo is false for distinct instances
	 */
	bool OpTextIdentical()
	{
		FText a = FText::FromString("Display");
		FText b = FText::FromString("Display");
		bool Identical = a.IdenticalTo(b);
		return !Identical;
	}

	/**
	 * Observe that every operator helper produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all operator helpers
	 * @Return true when all fifteen outcomes match
	 */
	UFUNCTION()
	bool StringOperatorsProduceExpectedValues()
	{
		if (OpAssignment() != "First")
		{
			return false;
		}

		if (OpConcatenation() != "Hello World")
		{
			return false;
		}

		if (OpConcatAssignment() != "Hello World")
		{
			return false;
		}

		if (!OpEquals())
		{
			return false;
		}

		if (!OpNotEquals())
		{
			return false;
		}

		if (!OpLessThan())
		{
			return false;
		}

		if (!OpGreaterThan())
		{
			return false;
		}

		if (!OpLessEqual())
		{
			return false;
		}

		if (!OpGreaterEqual())
		{
			return false;
		}

		if (OpIndex() != 90)
		{
			return false;
		}

		if (!OpNameEquals())
		{
			return false;
		}

		if (!OpNameNotEquals())
		{
			return false;
		}

		if (!OpNameEqualsString())
		{
			return false;
		}

		if (!OpNameReassignmentKeepsPreviousCopiesStable())
		{
			return false;
		}

		return OpTextIdentical();
	}

	/**
	 * Observe that concatenating two empty strings yields an empty string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "" + ""
	 * @Return true when the result is empty
	 * @Boundary empty operands
	 */
	UFUNCTION()
	bool OpConcatEmptyBoundary()
	{
		FString Result = ("" + "");
		return Result == "";
	}

	/**
	 * Observe that assignment copies are independent of later reassignment.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs a copied then reassigned string
	 * @Return true when the copy keeps its value
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool OpAssignmentCopyIndependence()
	{
		FString a = "First";
		FString b = a;
		a = "Second";

		bool CopyStable = (b == "First");
		bool OriginalMoved = (a == "Second");
		bool Result = (CopyStable && OriginalMoved);
		return Result;
	}
}
/** @end */
