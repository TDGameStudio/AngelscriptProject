/**
 * @version v1
 * @summary A base class name must already be declared.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary Deriving from a declared base is legal.
 * @topic Baseline
 */
class ABase
{
	int Value;
}

class AChild : ABase
{
	int Extra;
}
/** @end */
/**
 * @version invalid-unknown-super-type
 * @parent root
 * @summary An undeclared base type is rejected.
 * @topic Negative
 */
class AChild : AMissing
{
	int Value;
}
/** @end */
