/**
 * @version v1
 * @summary Logical conjunction, disjunction, negation, xor, and short-circuit forms.
 * @topic Language
 * @topic Operators
 *
 * logical-and-true     // Logical and of two true operands.
 * logical-and-false    // Logical and with a false operand.
 * logical-or-true      // Logical or that holds because one operand is true.
 * logical-or-false     // Logical or of two false operands.
 * logical-not-true     // Logical not applied to true.
 * logical-not-false    // Logical not applied to false.
 * logical-xor-true     // Logical xor using the live ^^ token, true against false.
 * short-circuit-and    // Logical and skips the right operand when the left is false.
 * short-circuit-or     // Logical or skips the right operand when the left is true.
 */
/**
 * @begin logical-and-true
 * @summary Logical and of two true operands.
 */
bool LogicalAndTrue()
{
	return true && true;
}
/** @end */
/**
 * @begin logical-and-false
 * @summary Logical and with a false operand.
 * @topic Operators
 */
bool LogicalAndFalse()
{
	return true && false;
}
/** @end */
/**
 * @begin logical-or-true
 * @summary Logical or that holds because one operand is true.
 * @topic Operators
 */
bool LogicalOrTrue()
{
	return false || true;
}
/** @end */
/**
 * @begin logical-or-false
 * @summary Logical or of two false operands.
 * @topic Operators
 */
bool LogicalOrFalse()
{
	return false || false;
}
/** @end */
/**
 * @begin logical-not-true
 * @summary Logical not applied to true.
 * @topic Operators
 */
bool LogicalNotTrue()
{
	return !true;
}
/** @end */
/**
 * @begin logical-not-false
 * @summary Logical not applied to false.
 * @topic Operators
 */
bool LogicalNotFalse()
{
	return !false;
}
/** @end */
/**
 * @begin logical-xor-true
 * @summary Logical xor using the live ^^ token, true against false.
 * @topic Operators
 */
bool LogicalXorTrue()
{
	return true ^^ false;
}
/** @end */
/**
 * @begin short-circuit-and
 * @summary Logical and skips the right operand when the left is false.
 * @topic Operators
 */
int ProbeAnd()
{
	int Value = 0;
	bool Result = (false && (Value = 1) == 1);
	return Result ? Value : 0;
}
/** @end */
/**
 * @begin short-circuit-or
 * @summary Logical or skips the right operand when the left is true.
 * @topic Operators
 */
int ProbeOr()
{
	int Value = 0;
	bool Result = (true || (Value = 1) == 1);
	return Result ? 1 : Value;
}
/** @end */
