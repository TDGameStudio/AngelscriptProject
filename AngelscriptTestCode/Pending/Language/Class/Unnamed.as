/**
 * @version v1
 * @summary A class declaration requires an identifier.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary A named class is the legal form.
 * @topic Baseline
 */
class ANode
{
	int Value;
}
/** @end */
/**
 * @version invalid-class-without-name
 * @parent root
 * @summary A class with no name is rejected.
 * @topic Negative
 */
class
{
	int Value;
}
/** @end */
