/**
 * @version v1
 * @summary Compile-fail cases for Enum.
 * @topic Language
 * @topic Syntax
 *
 * invalid-duplicate-enumerator
 * invalid-enum-without-name
 * invalid-method-inside-enum
 * invalid-non-integer-enumerator
 */
/**
 * @begin invalid-duplicate-enumerator
 * @summary Enumerator names must be unique in one enum.
 * @topic Negative
 */
enum EColor
{
	Red,
	Red
}
/** @end */
/**
 * @begin invalid-enum-without-name
 * @summary An enum declaration requires a name.
 * @topic Negative
 */
enum
{
	Red
}
/** @end */
/**
 * @begin invalid-method-inside-enum
 * @summary Compile-rejection form retained from legacy method inside enum.
 * @topic Negative
 */
enum EEnumMethod
{
	Value1;
void Foo()
	{
	}
}
/** @end */
/**
 * @begin invalid-non-integer-enumerator
 * @summary Compile-rejection form retained from legacy non integer enumerator.
 * @topic Negative
 */
enum EEnumBadVal
{
	Value1 = "hello"
}
/** @end */
