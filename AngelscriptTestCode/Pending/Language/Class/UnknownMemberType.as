/**
 * @version v1
 * @summary A class member type must already exist.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary An integer field is a legal member type.
 * @topic Baseline
 */
class ANode
{
	int Value;
}
/** @end */
/**
 * @version invalid-unknown-member-type
 * @parent root
 * @summary An undeclared member type is rejected.
 * @topic Negative
 */
class ANode
{
	MissingType Value;
}
/** @end */
/**
 * @version invalid-void-member
 * @parent root
 * @summary Void is not a legal field type.
 * @topic Negative
 */
class ANode
{
	void Value;
}
/** @end */
