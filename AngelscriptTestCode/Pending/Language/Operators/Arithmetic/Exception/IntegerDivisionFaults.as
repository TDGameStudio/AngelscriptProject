/**
 * @version v1
 * @summary Integer division has two runtime fault paths that the compiler cannot catch, because both operands are only known at run time. Dividing by zero throws "Division by zero", and dividing the most negative int by negative.
 * @topic Language
 */
/**
 * @version root
 * @summary Integer division has two runtime fault paths that the compiler cannot catch, because both operands are only known at run time. Dividing by zero throws "Division by zero", and dividing the most negative int by negative.
 * @topic Baseline
 */
namespace OperatorsTest
{
	/**
	 * Divide by zero, which the runtime guards rather than the compiler.
	 *
	 * @Kind RuntimeException
	 * @Covers Operators.Arithmetic
	 * @Inputs Value 10 divided by a divisor of 0
	 * @Return does not return; throws "Division by zero"
	 * @Boundary zero divisor
	 */
	UFUNCTION()
	int DivideByZero()
	{
		int Value = 10;
		int Divisor = 0;
		return Value / Divisor;
	}

	/**
	 * Divide the most negative int by negative one, where the true quotient
	 * cannot be represented.
	 *
	 * @Kind RuntimeException
	 * @Covers Operators.Arithmetic
	 * @Inputs INT32_MIN divided by -1
	 * @Return does not return; throws "Overflow in integer division"
	 * @Boundary most negative int
	 */
	UFUNCTION()
	int DivideMostNegativeIntByMinusOne()
	{
		int MinInt = -2147483647 - 1;
		return MinInt / -1;
	}

	/**
	 * Take a remainder against a zero divisor, which shares the divide-by-zero
	 * guard.
	 *
	 * @Kind RuntimeException
	 * @Covers Operators.Arithmetic
	 * @Inputs Value 10 reduced modulo a divisor of 0
	 * @Return does not return; throws "Division by zero"
	 * @Boundary zero divisor
	 */
	UFUNCTION()
	int ModuloByZero()
	{
		int Value = 10;
		int Divisor = 0;
		return Value % Divisor;
	}

	/**
	 * Divide by a negative one where the dividend is ordinary, which is the
	 * successful path next to the overflow case.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs Value 10 divided by -1
	 * @Return -10, showing the guard fires only at the representational edge
	 */
	UFUNCTION()
	int DivideOrdinaryValueByMinusOne()
	{
		int Value = 10;
		return Value / -1;
	}
}
/** @end */
