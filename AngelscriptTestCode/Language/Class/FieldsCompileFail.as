/**
 * @version v1
 * @summary Field forms that do not compile.
 * @topic Language
 * @topic Class
 *
 * invalid-unknown-field          // Writing a name that is not a member is rejected.
 * invalid-unknown-member-type    // An undeclared member type is rejected.
 * invalid-void-member            // Void is not a legal field type.
 */
/**
 * @begin invalid-unknown-field
 * @summary Writing a name that is not a member is rejected.
 * @topic Negative
 */
class AHolder
{
	int Value;
}

void Test()
{
	AHolder Object;
	Object.Missing = 1;
}
/** @end */
/**
 * @begin invalid-unknown-member-type
 * @summary An undeclared member type is rejected.
 * @topic Negative
 */
class ANode
{
	MissingType Value;
}
/** @end */
/**
 * @begin invalid-void-member
 * @summary Void is not a legal field type.
 * @topic Negative
 */
class ANode
{
	void Value;
}
/** @end */
