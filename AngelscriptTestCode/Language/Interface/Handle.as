/**
 * @version v1
 * @summary Interface handles, class-to-interface assignment, nullptr, and Cast.
 * @topic Language
 * @topic Interface
 *
 * interface-handle-local       // A local variable typed as an interface handle.
 * class-to-interface-handle    // A class handle assigns to an interface handle of an implemented type.
 * interface-handle-null        // An interface handle may be initialized with nullptr.
 * cast-to-interface-handle     // Cast converts a class handle to an interface handle.
 */
/**
 * @begin interface-handle-local
 * @summary A local variable typed as an interface handle.
 * @topic Interface
 */
interface INamed
{
	int GetId();
}

void Use()
{
	INamed@ Handle;
}
/** @end */
/**
 * @begin class-to-interface-handle
 * @summary A class handle assigns to an interface handle of an implemented type.
 * @topic Interface
 */
interface INamed
{
	int GetId();
}

class APerson : INamed
{
	int GetId()
	{
		return 1;
	}
}

void Use(APerson@ Object)
{
	INamed@ Handle = Object;
}
/** @end */
/**
 * @begin interface-handle-null
 * @summary An interface handle may be initialized with nullptr.
 * @topic Interface
 */
interface INamed
{
	int GetId();
}

void Use()
{
	INamed@ Handle = nullptr;
}
/** @end */
/**
 * @begin cast-to-interface-handle
 * @summary Cast converts a class handle to an interface handle.
 * @topic Interface
 */
interface INamed
{
	int GetId();
}

class APerson : INamed
{
	int GetId()
	{
		return 1;
	}
}

void Use(APerson@ Object)
{
	INamed@ Handle = Cast<INamed>(Object);
}
/** @end */
