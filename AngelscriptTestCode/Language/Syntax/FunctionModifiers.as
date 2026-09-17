/**
 * @version v1
 * @summary Local functions and access policy prefixes.
 * @topic Language
 * @topic Syntax
 *
 * local-function                   // A file-scope function marked with the local prefix.
 * local-function-returns-int       // A local function that returns an integer.
 * local-function-with-parameter    // A local function that takes one integer parameter.
 * access-policy-declaration        // A class declares a named access policy from private plus subjects.
 * access-member-prefix             // A member uses an access:Policy prefix bound to a declared policy.
 */
/**
 * @begin local-function
 * @summary A file-scope function marked with the local prefix.
 * @topic Syntax
 */
local void Hidden()
{
}
/** @end */
/**
 * @begin local-function-returns-int
 * @summary A local function that returns an integer.
 * @topic Syntax
 */
local int Answer()
{
	return 1;
}
/** @end */
/**
 * @begin local-function-with-parameter
 * @summary A local function that takes one integer parameter.
 * @topic Syntax
 */
local int Double(int Value)
{
	return Value + Value;
}
/** @end */
/**
 * @begin access-policy-declaration
 * @summary A class declares a named access policy from private plus subjects.
 * @topic Syntax
 */
class AItem
{
	access Friends = private, Reader(readonly), *(editdefaults);
}
/** @end */
/**
 * @begin access-member-prefix
 * @summary A member uses an access:Policy prefix bound to a declared policy.
 * @topic Syntax
 */
class AItem
{
	access Friends = private, Reader(readonly);
	access:Friends int Value;
}
/** @end */
