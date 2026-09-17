/**
 * @version v1
 * @summary A class-declared destructor with no parameters.
 * @topic Language
 * @topic Destructors
 */
/**
 * @version root
 * @summary A class may declare an empty destructor.
 * @topic Baseline
 */
class ANode
{
	int Value;

	~ANode()
	{
	}
}

int UseDeclared()
{
	ANode Object;
	Object.Value = 4;
	return Object.Value;
}
/** @end */
/**
 * @version invalid-destructor-return-type
 * @parent root
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
 * @version invalid-duplicate-destructor
 * @parent root
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
