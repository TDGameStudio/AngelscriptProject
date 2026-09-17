/**
 * @version v1
 * @summary A destructor name must match its enclosing type.
 * @topic Language
 * @topic Destructors
 */
/**
 * @version root
 * @summary ~ANode is legal inside class ANode.
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
 * @version invalid-destructor-wrong-name
 * @parent root
 * @summary A destructor named for another type is rejected.
 * @topic Negative
 */
class ANode
{
	~AOther()
	{
	}
}
/** @end */
