/**
 * @version v1
 * @summary A destructor cannot be declared at global scope.
 * @topic Language
 * @topic Destructors
 */
/**
 * @version root
 * @summary A destructor belongs inside its type.
 * @topic Baseline
 */
class ANode
{
	~ANode()
	{
	}
}
/** @end */
/**
 * @version invalid-global-destructor
 * @parent root
 * @summary A free-function destructor is rejected.
 * @topic Negative
 */
~ANode()
{
}
/** @end */
