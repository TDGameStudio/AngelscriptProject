/**
 * @version v1
 * @summary A destructor body may read an instance field.
 * @topic Language
 * @topic Destructors
 */
/**
 * @version root
 * @summary ~ANode reads Value into a local; the instance still returns 4 before it dies.
 * @topic Baseline
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
 * @version valid-destructor-reads-two-fields
 * @parent root
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
/**
 * @version valid-struct-destructor-reads-field
 * @parent root
 * @summary A struct destructor may read a field.
 * @topic Destructors
 */
struct FPoint
{
	int X;

	~FPoint()
	{
		int Local = X;
	}
}

int UseStruct()
{
	FPoint Value;
	Value.X = 8;
	return Value.X;
}
/** @end */
