/**
 * @version v1
 * @summary A static field on a USTRUCT is not a script-side surface, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A static field on a USTRUCT is not a script-side surface, so this program is rejected.
 * @topic Negative
 */
USTRUCT()
struct FStaticMemberBoundary
{
	static int Value;
}
/** @end */
