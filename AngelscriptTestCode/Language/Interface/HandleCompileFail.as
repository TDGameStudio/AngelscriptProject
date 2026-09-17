/**
 * @version v1
 * @summary Compile-fail cases for Interface Handle.
 * @topic Language
 * @topic Interface
 *
 * invalid-unrelated-class-to-interface    // A class that does not implement an interface cannot become that handle.
 */
/**
 * @begin invalid-unrelated-class-to-interface
 * @summary A class that does not implement an interface cannot become that handle.
 * @topic Negative
 */
interface INamed
{
	int GetId();
}

class ARock
{
}

void Use(ARock@ Object)
{
	INamed@ Handle = Object;
}
/** @end */
