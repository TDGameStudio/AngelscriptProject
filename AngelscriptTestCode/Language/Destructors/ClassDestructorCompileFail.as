/**
 * @version v1
 * @summary Class destructor forms that the live parser rejects.
 * @topic Language
 * @topic Destructors
 *
 * invalid-destructor-return-type       // A destructor cannot declare a return type.
 * invalid-duplicate-destructor         // A class cannot declare two destructors.
 * invalid-global-destructor            // A free-function destructor is rejected.
 * invalid-destructor-wrong-name        // A destructor named for another type is rejected.
 * invalid-destructor-with-parameter    // A destructor parameter list is rejected.
 */
/**
 * @begin invalid-destructor-return-type
 * @summary A destructor cannot declare a return type.
 * @topic Negative
 */
class ANode
{
	int ~ANode()
	{
		return 0;
	}
}
/** @end */
/**
 * @begin invalid-duplicate-destructor
 * @summary A class cannot declare two destructors.
 * @topic Negative
 */
class ANode
{
	~ANode()
	{
	}

	~ANode()
	{
	}
}
/** @end */
/**
 * @begin invalid-global-destructor
 * @summary A free-function destructor is rejected.
 * @topic Negative
 */
~ANode()
{
}
/** @end */
/**
 * @begin invalid-destructor-wrong-name
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
/**
 * @begin invalid-destructor-with-parameter
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
