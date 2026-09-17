/**
 * @version v1
 * @summary Declaring a method inside an enum is rejected. This file is the illegal program itself; do not move the method out of the enum, since being inside it is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring a method inside an enum is rejected. This file is the illegal program itself; do not move the method out of the enum, since being inside it is the point.
 * @topic Negative
 */
enum EEnumMethod
{
	Value1;
/** */
	void Foo()
	{
	}
}
/** @end */
