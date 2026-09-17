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
    int Value = /** @point initial-value */0;
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
    /** @breakpoint before-add */int Step = /** @range-begin delta */1/** @range-end delta */;
}
/** @end */
