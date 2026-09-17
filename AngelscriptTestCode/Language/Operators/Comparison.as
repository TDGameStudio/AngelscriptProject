/**
 * @version v1
 * @summary Relational and equality comparison forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * equal-int                   // Integer equality comparison.
 * not-equal-int               // Integer inequality comparison.
 * less-int                    // Integer less-than comparison.
 * less-equal-int              // Integer less-or-equal comparison.
 * greater-int                 // Integer greater-than comparison.
 * greater-equal-int           // Integer greater-or-equal comparison.
 * equal-float                 // Float equality comparison.
 * equal-bool                  // Bool equality comparison.
 * string-equality-operator    // String equality.
 */
/**
 * @begin equal-int
 * @summary Integer equality comparison.
 */
bool EqualInt()
{
	return 1 == 1;
}
/** @end */
/**
 * @begin not-equal-int
 * @summary Integer inequality comparison.
 * @topic Operators
 */
bool NotEqualInt()
{
	return 1 != 2;
}
/** @end */
/**
 * @begin less-int
 * @summary Integer less-than comparison.
 * @topic Operators
 */
bool LessInt()
{
	return 1 < 2;
}
/** @end */
/**
 * @begin less-equal-int
 * @summary Integer less-or-equal comparison.
 * @topic Operators
 */
bool LessEqualInt()
{
	return 2 <= 2;
}
/** @end */
/**
 * @begin greater-int
 * @summary Integer greater-than comparison.
 * @topic Operators
 */
bool GreaterInt()
{
	return 3 > 2;
}
/** @end */
/**
 * @begin greater-equal-int
 * @summary Integer greater-or-equal comparison.
 * @topic Operators
 */
bool GreaterEqualInt()
{
	return 3 >= 3;
}
/** @end */
/**
 * @begin equal-float
 * @summary Float equality comparison.
 * @topic Operators
 */
bool EqualFloat()
{
	return 1.0f == 1.0f;
}
/** @end */
/**
 * @begin equal-bool
 * @summary Bool equality comparison.
 * @topic Operators
 */
bool EqualBool()
{
	return true == true;
}
/** @end */
/**
 * @begin string-equality-operator
 * @summary String equality.
 * @topic Operators
 */
bool Equal()
{
	return "a" == "a";
}
/** @end */
