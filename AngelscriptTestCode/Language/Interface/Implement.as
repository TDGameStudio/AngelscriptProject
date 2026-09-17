/**
 * @version v1
 * @summary Classes that implement one or more interfaces.
 * @topic Language
 * @topic Interface
 *
 * implement-one-interface          // A class lists one interface in its base list.
 * implement-method-body            // A class supplies a body for the interface method it implements.
 * implement-two-methods            // A class implements both methods declared by one interface.
 * implement-multiple-interfaces    // A class lists two interfaces in its base list.
 */
/**
 * @begin implement-one-interface
 * @summary A class lists one interface in its base list.
 * @topic Interface
 */
interface IMarker
{
}

class AWidget : IMarker
{
}
/** @end */
/**
 * @begin implement-method-body
 * @summary A class supplies a body for the interface method it implements.
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
/** @end */
/**
 * @begin implement-two-methods
 * @summary A class implements both methods declared by one interface.
 * @topic Interface
 */
interface IPair
{
	int First();
	int Second();
}

class APair : IPair
{
	int First()
	{
		return 1;
	}

	int Second()
	{
		return 2;
	}
}
/** @end */
/**
 * @begin implement-multiple-interfaces
 * @summary A class lists two interfaces in its base list.
 * @topic Interface
 */
interface IAlpha
{
}

interface IBeta
{
}

class APair : IAlpha, IBeta
{
}
/** @end */
