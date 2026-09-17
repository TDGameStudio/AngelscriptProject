/**
 * @version v1
 * @summary Interface type declarations, methods, const methods, and interface bases.
 * @topic Language
 * @topic Interface
 *
 * declare-empty-interface        // An interface with a name and an empty body.
 * declare-method                 // An interface that declares one method without a body.
 * declare-two-methods            // An interface that declares two methods without bodies.
 * declare-const-method           // An interface method marked const after its parameter list.
 * interface-extends-interface    // An interface that lists another interface as its base.
 */
/**
 * @begin declare-empty-interface
 * @summary An interface with a name and an empty body.
 * @topic Interface
 */
interface IEmpty
{
}
/** @end */
/**
 * @begin declare-method
 * @summary An interface that declares one method without a body.
 * @topic Interface
 */
interface INamed
{
	int GetId();
}
/** @end */
/**
 * @begin declare-two-methods
 * @summary An interface that declares two methods without bodies.
 * @topic Interface
 */
interface IPair
{
	int First();
	int Second();
}
/** @end */
/**
 * @begin declare-const-method
 * @summary An interface method marked const after its parameter list.
 * @topic Interface
 */
interface IReadable
{
	int Read() const;
}
/** @end */
/**
 * @begin interface-extends-interface
 * @summary An interface that lists another interface as its base.
 * @topic Interface
 */
interface INamed
{
	int GetId();
}

interface IPerson : INamed
{
	int GetAge();
}
/** @end */
