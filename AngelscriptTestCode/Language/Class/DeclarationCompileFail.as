/**
 * @version v1
 * @summary Class declaration forms that do not compile.
 * @topic Language
 * @topic Class
 *
 * invalid-class-without-name         // A class with no name is rejected.
 * invalid-class-without-braces       // A trailing semicolon is not a class body.
 * invalid-duplicate-class-name       // Repeating the same class name is rejected.
 * invalid-unknown-member-on-empty    // An empty class has no members to read.
 */
/**
 * @begin invalid-class-without-name
 * @summary A class with no name is rejected.
 * @topic Negative
 */
class
{
	int Value;
}
/** @end */
/**
 * @begin invalid-class-without-braces
 * @summary A trailing semicolon is not a class body.
 * @topic Negative
 */
class ANode;
/** @end */
/**
 * @begin invalid-duplicate-class-name
 * @summary Repeating the same class name is rejected.
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
 * @begin invalid-unknown-member-on-empty
 * @summary An empty class has no members to read.
 * @topic Negative
 */
class AEmpty
{
}

int Test()
{
	AEmpty Object;
	return Object.Missing;
}
/** @end */
