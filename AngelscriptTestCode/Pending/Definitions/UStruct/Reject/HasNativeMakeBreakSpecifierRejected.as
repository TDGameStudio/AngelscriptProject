/**
 * @version v1
 * @summary HasNativeMake and HasNativeBreak are not script-side USTRUCT specifiers, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary HasNativeMake and HasNativeBreak are not script-side USTRUCT specifiers, so this program is rejected.
 * @topic Negative
 */
USTRUCT(HasNativeMake = "MakeBoundary", HasNativeBreak = "BreakBoundary")
struct FNativeMakeBreakBoundary
{
	int Value = 0;
}
/** @end */
