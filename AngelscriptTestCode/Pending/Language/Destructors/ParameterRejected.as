/**
 * @version v1
 * @summary A destructor cannot take a parameter.
 * @topic Language
 * @topic Destructors
 */
/**
 * @version root
 * @summary A parameterless destructor is the legal form.
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
 * @version invalid-destructor-with-parameter
 * @parent root
 * @summary A destructor parameter list is rejected.
 * @topic Negative
 */
class ANode
{
	~ANode(int Invalid)
	{
	}
}
/** @end */
