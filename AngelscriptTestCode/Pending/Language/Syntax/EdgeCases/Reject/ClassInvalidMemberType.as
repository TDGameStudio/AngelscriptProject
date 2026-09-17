/**
 * @version v1
 * @summary Declaring a class member with a type that does not exist is rejected. This file is the illegal program itself; do not replace the member type with int, since the unknown type is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring a class member with a type that does not exist is rejected. This file is the illegal program itself; do not replace the member type with int, since the unknown type is the point.
 * @topic Negative
 */
class AClassBadMemberActor : AActor
{
	NonExistentType X;
}
/** @end */
