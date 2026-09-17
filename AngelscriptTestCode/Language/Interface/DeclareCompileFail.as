/**
 * @version v1
 * @summary Compile-fail cases for Interface Declare.
 * @topic Language
 * @topic Interface
 *
 * invalid-interface-without-name        // An interface keyword with no type name is rejected.
 * invalid-interface-with-field          // An interface may not declare a data member.
 * invalid-interface-with-constructor    // An interface may not declare a constructor.
 * invalid-interface-extends-class       // An interface may not list a class as its base.
 */
/**
 * @begin invalid-interface-without-name
 * @summary An interface keyword with no type name is rejected.
 * @topic Negative
 */
interface
{
	void Tag();
}
/** @end */
/**
 * @begin invalid-interface-with-field
 * @summary An interface may not declare a data member.
 * @topic Negative
 */
interface IBad
{
	int Value;
}
/** @end */
/**
 * @begin invalid-interface-with-constructor
 * @summary An interface may not declare a constructor.
 * @topic Negative
 */
interface IBad
{
	IBad();
}
/** @end */
/**
 * @begin invalid-interface-extends-class
 * @summary An interface may not list a class as its base.
 * @topic Negative
 */
class ABase
{
}

interface IBad : ABase
{
}
/** @end */
