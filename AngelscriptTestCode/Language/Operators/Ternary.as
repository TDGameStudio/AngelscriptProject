/**
 * @version v1
 * @summary Conditional-expression forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * ternary
 * nested-ternary
 * ternary-as-return
 */
/**
 * @begin ternary
 * @summary A ternary selecting between two integer arms.
 */
int Pick(bool Flag)
{
	return Flag ? 1 : 2;
}

int NestedPick(bool First, bool Second)
{
	return First ? (Second ? 1 : 2) : 3;
}
/** @end */
/**
 * @begin nested-ternary
 * @summary A ternary nested in both arms of an outer ternary.
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
	return Value < 0 ? -1 : Value == 0 ? 0 : 1;
}
/** @end */
