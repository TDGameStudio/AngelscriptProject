/**
 * @version v1
 * @summary Conditional-expression forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * ternary                // A ternary selecting between two integer arms.
 * nested-ternary         // A ternary nested in the true arm of an outer ternary.
 * ternary-as-return      // A function whose body is a single ternary return.
 * ternary-false-arm      // A ternary whose condition is false selects the else arm.
 * ternary-nested-else    // A ternary nested in the else arm of an outer ternary.
 * ternary-as-argument    // A ternary passed as a function argument.
 * ternary-int-arms       // A ternary whose both arms are integer literals.
 */
/**
 * @begin ternary
 * @summary A ternary selecting between two integer arms.
 */
int Pick(bool Flag)
{
	return Flag ? 1 : 2;
}
/** @end */
/**
 * @begin nested-ternary
 * @summary A ternary nested in the true arm of an outer ternary.
 * @topic Operators
 */
int Nested(int Value)
{
	return Value > 0 ? (Value > 10 ? 2 : 1) : 0;
}
/** @end */
/**
 * @begin ternary-as-return
 * @summary A function whose body is a single ternary return.
 * @topic Operators
 */
int Sign(int Value)
{
	return Value < 0 ? -1 : 1;
}
/** @end */
/**
 * @begin ternary-false-arm
 * @summary A ternary whose condition is false selects the else arm.
 * @topic Operators
 */
int FalseArm()
{
	return false ? 1 : 2;
}
/** @end */
/**
 * @begin ternary-nested-else
 * @summary A ternary nested in the else arm of an outer ternary.
 * @topic Operators
 */
int NestedElse(int Value)
{
	return Value > 0 ? 1 : (Value < 0 ? -1 : 0);
}
/** @end */
/**
 * @begin ternary-as-argument
 * @summary A ternary passed as a function argument.
 * @topic Operators
 */
int Use(int Value)
{
	return Value;
}

int AsArgument(bool Flag)
{
	return Use(Flag ? 1 : 2);
}
/** @end */
/**
 * @begin ternary-int-arms
 * @summary A ternary whose both arms are integer literals.
 * @topic Operators
 */
int IntArms(bool Flag)
{
	return Flag ? 10 : 20;
}
/** @end */
