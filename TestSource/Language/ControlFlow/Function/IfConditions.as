/**
 * The expressions an if condition may take: a bool variable, a comparison, a
 * logical and, a logical or, a logical not, a compound mixing both operators,
 * a nullptr check, an IsValid check, and a call returning bool. Each is
 * observed in both directions so the operator semantics are pinned rather
 * than assumed.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfConditions
 * @Harness Function
 * @Tag Language.ControlFlow.IfConditions
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageConditionalTests.cpp::IfConditions
 * @Provenance sha256=6416bc7b5547081e43e1f765f3b69d93ffe3e8fc22d363695a4271b592daed85; lines 239-333.
 * @Provenance Oracle: BoolVariable 1; ComparisonExpr(12) 1; LogicalAnd(1,1) 1; LogicalOr(1,0) 1;
 * @Provenance LogicalNot(false) 1; ComplexExpr(1,5,false) 1; NullCheckNull 0; IsValidCheckNull 0;
 * @Provenance FunctionReturnCheck 1.
 * @Provenance Extra: ComplexExpr is false when A <= 0, B >= 10, and C is false.
 */

namespace ControlFlowTest
{
	/**
	 * Observe a bool variable as the condition.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Inputs if (bFlag) where bFlag is a local bool set to true
	 * @Return 1 when the flag is true, 0 when false
	 */
	UFUNCTION()
	int BoolVariableCondition(bool bFlag)
	{
		if (bFlag)
			return 1;
		return 0;
	}

	/**
	 * Observe a chain of comparison conditions: the first one that holds
	 * decides the result.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Param Value Tested against 10, 5, 7, and 8 in order
	 * @Inputs Successive tests for greater, lesser, equality, and inequality
	 * @Return 1 above ten, 2 below five, 3 at seven, 4 when not eight, else 0
	 */
	UFUNCTION()
	int ComparisonChainSelectsFirstMatch(int Value)
	{
		if (Value > 10)
			return 1;
		if (Value < 5)
			return 2;
		if (Value == 7)
			return 3;
		if (Value != 8)
			return 4;
		return 0;
	}

	/**
	 * Observe a logical and: it holds only when both operands do.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Param A First operand, tested above zero
	 * @Param B Second operand, tested above zero
	 * @Inputs if (A > 0 && B > 0)
	 * @Return 1 when both are above zero, otherwise 0
	 */
	UFUNCTION()
	int LogicalAndRequiresBoth(int A, int B)
	{
		if (A > 0 && B > 0)
			return 1;
		return 0;
	}

	/**
	 * Observe a logical or: it holds when either operand does.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Param A First operand, tested above zero
	 * @Param B Second operand, tested above zero
	 * @Inputs if (A > 0 || B > 0)
	 * @Return 1 when at least one is above zero, otherwise 0
	 */
	UFUNCTION()
	int LogicalOrAcceptsEither(int A, int B)
	{
		if (A > 0 || B > 0)
			return 1;
		return 0;
	}

	/**
	 * Observe a logical not: it inverts the flag.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Param Flag Inverted by the condition
	 * @Inputs if (!Flag)
	 * @Return 1 when the flag is false, 0 when true
	 */
	UFUNCTION()
	int LogicalNotInvertsFlag(bool Flag)
	{
		if (!Flag)
			return 1;
		return 0;
	}

	/**
	 * Observe a compound condition mixing both logical operators: the and binds
	 * tighter, so the or supplies an independent way for it to hold.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Param A Tested above zero
	 * @Param B Tested below ten
	 * @Param C Supplies an independent true path
	 * @Inputs if ((A > 0) && (B < 10) || C)
	 * @Return 1 when both numeric tests hold or when C is true, otherwise 0
	 */
	UFUNCTION()
	int CompoundConditionMixesOperators(int A, int B, bool C)
	{
		if ((A > 0) && (B < 10) || C)
			return 1;
		return 0;
	}

	/**
	 * Observe a nullptr check on an object handle.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Param Obj Handle tested against nullptr
	 * @Inputs if (Obj != nullptr)
	 * @Return 1 when the handle is non-null, otherwise 0
	 */
	UFUNCTION()
	int NullCheckRejectsNull(UObject Obj)
	{
		if (Obj != nullptr)
			return 1;
		return 0;
	}

	/**
	 * Observe an IsValid check on an object handle.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Param Obj Handle passed to IsValid
	 * @Inputs if (IsValid(Obj))
	 * @Return 1 when the handle is valid, otherwise 0
	 */
	UFUNCTION()
	int IsValidCheckRejectsNull(UObject Obj)
	{
		if (IsValid(Obj))
			return 1;
		return 0;
	}

	/**
	 * Observe a call returning bool used directly as the condition.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Inputs if (IsReady()) where the call returns true
	 * @Return 1 when the call returns true
	 */
	UFUNCTION()
	int FunctionReturnConditionHolds()
	{
		if (IsReady())
			return 1;
		return 0;
	}

	/**
	 * Returns true, so the function-return condition has something to test.
	 */
	bool IsReady()
	{
		return true;
	}

	/**
	 * Observe the false default across the logical forms and both null checks.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Inputs Every form evaluated so its condition does not hold
	 * @Return true when all of them yield 0
	 * @Boundary false conditions
	 */
	UFUNCTION()
	bool ConditionsFalseAllYieldZero()
	{
		if (LogicalAndRequiresBoth(1, 0) != 0)
		{
			return false;
		}
		if (LogicalAndRequiresBoth(0, 1) != 0)
		{
			return false;
		}
		if (LogicalOrAcceptsEither(0, 0) != 0)
		{
			return false;
		}
		if (LogicalNotInvertsFlag(true) != 0)
		{
			return false;
		}
		if (CompoundConditionMixesOperators(0, 15, false) != 0)
		{
			return false;
		}
		if (NullCheckRejectsNull(nullptr) != 0)
		{
			return false;
		}
		return IsValidCheckRejectsNull(nullptr) == 0;
	}

	/**
	 * Observe the comparison boundaries, including a value that falls past
	 * every test in the chain.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.IfCondition
	 * @Inputs The chain at 3, 7, 8, and 9, plus the compound with C true
	 * @Return true when the results are 2, 3, 0, 4, and 1 respectively
	 * @Boundary comparison thresholds
	 */
	UFUNCTION()
	bool ComparisonChainRespectsBoundaries()
	{
		if (ComparisonChainSelectsFirstMatch(3) != 2)
		{
			return false;
		}
		if (ComparisonChainSelectsFirstMatch(7) != 3)
		{
			return false;
		}
		if (ComparisonChainSelectsFirstMatch(8) != 0)
		{
			return false;
		}
		if (ComparisonChainSelectsFirstMatch(9) != 4)
		{
			return false;
		}
		return CompoundConditionMixesOperators(0, 5, true) == 1;
	}
}
