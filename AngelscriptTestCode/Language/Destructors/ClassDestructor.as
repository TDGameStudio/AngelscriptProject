/**
 * @version v1
 * @summary Class-declared destructors that match the enclosing type name.
 * @topic Language
 * @topic Destructors
 *
 * class-destructor               // A class may declare an empty destructor.
 * destructor-reads-field         // ~ANode reads Value into a local; the instance still returns 4 before it dies.
 * destructor-reads-two-fields    // A destructor may read more than one field.
 */
/**
 * @begin class-destructor
 * @summary A class may declare an empty destructor.
 * @topic Destructors
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
 * @begin destructor-reads-field
 * @summary ~ANode reads Value into a local; the instance still returns 4 before it dies.
 * @topic Destructors
 */
class ANode
{
	int Value;

	~ANode()
	{
		int Local = Value;
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
 * @begin destructor-reads-two-fields
 * @summary A destructor may read more than one field.
 * @topic Destructors
 */
class ANode
{
	int Left;
	int Right;

	~ANode()
	{
		int Total = Left + Right;
	}
}

int UseTwo()
{
	ANode Object;
	Object.Left = 1;
	Object.Right = 2;
	return Object.Left + Object.Right;
}
/** @end */
