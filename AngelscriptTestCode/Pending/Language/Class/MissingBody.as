/**
 * @version v1
 * @summary A class declaration requires a brace body.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary A class with an empty brace body is legal.
 * @topic Baseline
 */
class ANode
{
}
/** @end */
/**
 * @version invalid-class-without-braces
 * @parent root
 * @summary A trailing semicolon is not a class body.
 * @topic Negative
 */
class ANode;
/** @end */
