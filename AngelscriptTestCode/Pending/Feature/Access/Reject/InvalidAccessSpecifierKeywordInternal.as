/**
 * @version v1
 * @summary An unrecognised access specifier keyword is rejected. This file is the illegal program itself; do not replace internal with private or protected, since the invalid keyword is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary An unrecognised access specifier keyword is rejected. This file is the illegal program itself; do not replace internal with private or protected, since the invalid keyword is the point.
 * @topic Negative
 */
/**
 * An actor that uses the invalid specifier internal on a member.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class AActorBadKeyword : AActor
{
	internal int X = 0;
}
/** @end */
