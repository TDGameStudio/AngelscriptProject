/**
 * @version v1
 * @summary Counter source variants.
 * @topic Language
 * @topic Reload
 */
/**
 * @version root
 * @summary Define the initial counter.
 * @topic Baseline
 */
class Counter
{
    int Value = 0;
}
/** @end */
/**
 * @version add-step
 * @parent root
 * @summary Add a configurable counter step.
 * @topic Fields
 * @topic Reload
 */
class Counter
{
    int Value = 0;
    int Step = 1;
}
/** @end */
