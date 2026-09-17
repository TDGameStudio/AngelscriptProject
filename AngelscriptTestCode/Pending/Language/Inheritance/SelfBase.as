/**
 * @version v1
 * @summary A class cannot list itself as its base.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary A class with no base is legal.
 * @topic Baseline
 */
class ANode
{
	int Value;
}
/** @end */
/**
 * @version invalid-class-self-inheritance
 * @parent root
 * @summary Inheriting from the same class name is rejected.
 * @topic Negative
 */
class ANode : ANode
{
	int Value;
}
/** @end */
