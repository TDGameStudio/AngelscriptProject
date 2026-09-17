/**
 * @version v1
 * @summary Class declaration forms that are not handle casts.
 * @topic Language
 * @topic Syntax
 *
 * invalid-class-without-name
 * invalid-class-without-braces
 * invalid-class-self-inheritance
 * invalid-duplicate-class-name
 * invalid-super-outside-class
 */
/**
 * @begin invalid-class-without-name
 * @summary A class declaration requires a name.
 * @topic Negative
 */
class
{
	int Value;
}
/** @end */
/**
 * @begin invalid-class-without-braces
 * @summary A class declaration requires a body.
 * @topic Negative
 */
class ANode;
/** @end */
/**
 * @begin invalid-class-self-inheritance
 * @summary A class cannot inherit from itself.
 * @topic Negative
 */
class ANode : ANode
{
	int Value;
}
/** @end */
/**
 * @begin invalid-duplicate-class-name
 * @summary Two classes cannot share a name.
 * @topic Negative
 */
class ANode
{
	int X;
}

class ANode
{
	int Y;
}
/** @end */
/**
 * @begin invalid-super-outside-class
 * @summary Super is invalid outside a derived type.
 * @topic Negative
 */
void Test()
{
	super.Value = 1;
}
/** @end */
