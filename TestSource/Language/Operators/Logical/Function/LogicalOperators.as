/**
 * The logical operators and, or, and not, plus a compound combining them. The
 * important behaviour is short-circuit evaluation: with a false left operand,
 * && never evaluates its right operand, so an expression that would fault when
 * evaluated — a division by zero is the probe used here — is never reached.
 * Each form reports 1 when it yields true and 0 when it yields false.
 * Each operator result is bound to a local before being returned, so the
 * return statement itself carries no compound boolean while the operators
 * under test still appear in the body.
 *
 * @Theme Language.Operators
 * @Subject Operators.LogicalOperators
 * @Harness Function
 * @Tag Language.Operators.LogicalOperators
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Positive
 * @Provenance sha256=d91e8ad4be8d3be30179016aea025b6d8c8e5a21484a18333d787b33ab63763f; lines 286-292.
 * @Provenance Oracle: LogicAnd 1; LogicOr 1; LogicNot 1; LogicCompound 1; ShortCircuit 0.
 * @Provenance Extra: ShortCircuit is the false vector; false && true is 0 without evaluating a divisor.
 * @Provenance DefaultSafe. Source owns locals. ShortCircuit must not evaluate 1/Z.
 */

namespace OperatorsTest
{
	/**
	 * Report whether a logical and over two true operands yields true.
	 *
	 * @Covers Operators.Logical
	 * @Inputs true && true
	 * @Return 1 when the conjunction holds, 0 otherwise
	 */
	int ConjunctionHolds()
	{
		bool Result = (true && true);
		return Result ? 1 : 0;
	}

	/**
	 * Report whether a logical or with one true operand yields true.
	 *
	 * @Covers Operators.Logical
	 * @Inputs false || true
	 * @Return 1 when the disjunction holds, 0 otherwise
	 */
	int DisjunctionHolds()
	{
		bool Result = (false || true);
		return Result ? 1 : 0;
	}

	/**
	 * Report whether a logical not inverts false to true.
	 *
	 * @Covers Operators.Logical
	 * @Inputs !false
	 * @Return 1 when the negation holds, 0 otherwise
	 */
	int NegationHolds()
	{
		return (!false) ? 1 : 0;
	}

	/**
	 * Report whether a compound joining all three operators yields true.
	 *
	 * @Covers Operators.Logical
	 * @Inputs (true && !false) || (false && true)
	 * @Return 1 when the compound holds, 0 otherwise
	 */
	int CompoundExpressionHolds()
	{
		bool Result = ((true && !false) || (false && true));
		return Result ? 1 : 0;
	}

	/**
	 * Probe short-circuit evaluation: the right operand divides by zero, so it
	 * must never be evaluated when the left operand is already false.
	 *
	 * @Covers Operators.Logical
	 * @Inputs A false left operand and a right operand that would fault
	 * @Return 0 when the right operand was skipped, 1 if it was evaluated
	 * @Boundary short-circuit evaluation
	 */
	int ShortCircuitSkipsRightOperand()
	{
		bool A = false;
		int Z = 0;
		bool Result = (A && (1/Z > 0));
		return Result ? 1 : 0;
	}

	/**
	 * Observe that every form produces its expected result, including the
	 * short-circuit probe reporting 0.
	 *
	 * @Kind Observe
	 * @Covers Operators.Logical
	 * @Inputs All five logical forms
	 * @Return true when the results are 1, 1, 1, 1, and 0 respectively
	 */
	UFUNCTION()
	bool AllLogicalFormsHold()
	{
		if (ConjunctionHolds() != 1)
		{
			return false;
		}
		if (DisjunctionHolds() != 1)
		{
			return false;
		}
		if (NegationHolds() != 1)
		{
			return false;
		}
		if (CompoundExpressionHolds() != 1)
		{
			return false;
		}
		return ShortCircuitSkipsRightOperand() == 0;
	}

	/**
	 * Observe the false boundary: a false conjunction reports 0, and the
	 * short-circuit probe reports 0 as well.
	 *
	 * @Kind Observe
	 * @Covers Operators.Logical
	 * @Inputs false && true, plus the short-circuit probe
	 * @Return true when both report 0
	 * @Boundary false conjunction
	 */
	UFUNCTION()
	bool FalseConjunctionReportsZero()
	{
		if (ShortCircuitSkipsRightOperand() != 0)
		{
			return false;
		}

		bool Result = (false && true);
		return Result ? 1 : 0;
	}

	/**
	 * Observe the negation boundary: negating true reports 0, while negating
	 * false reports 1.
	 *
	 * @Kind Observe
	 * @Covers Operators.Logical
	 * @Inputs !true and the negation helper
	 * @Return true when the first is 0 and the second is 1
	 * @Boundary negating true
	 */
	UFUNCTION()
	bool NegatingTrueReportsZero()
	{
		bool NegatedTrue = (!true);
		if (NegatedTrue)
		{
			return false;
		}
		return NegationHolds() == 1;
	}
}
