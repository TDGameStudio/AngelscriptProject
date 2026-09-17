/**
 * @version v1
 * @summary Two typedefs cannot share an alias name.
 * @topic Language
 * @topic Typedef
 */
/**
 * @version root
 * @summary A single typedef alias is legal.
 * @topic Baseline
 */
typedef int Count;

int UseOne()
{
	Count Value = 1;
	return Value;
}
/** @end */
/**
 * @version invalid-duplicate-typedef
 * @parent root
 * @summary Reusing the same alias name is rejected.
 * @topic Negative
 */
typedef int Count;
typedef float Count;
/** @end */
