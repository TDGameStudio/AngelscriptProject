/**
 * @version v1
 * @summary Host-free script classes, methods, and this.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A script class with a field, a method, and this assignment.
 * @topic Baseline
 */
class AHolder
{
	int Value;

	void Set(int InValue)
	{
		this.Value = InValue;
	}

	int Get() const
	{
		return Value;
	}
}

int UseHolder()
{
	AHolder Object;
	Object.Set(4);
	return Object.Get();
}
/** @end */
/**
 * @version valid-empty-class
 * @parent root
 * @summary A class may have an empty body.
 * @topic Syntax
 */
class AEmpty
{
}
/** @end */
/**
 * @version valid-class-constructor
 * @parent root
 * @summary A class constructor initializes a field.
 * @topic Syntax
 */
class APoint
{
	int X;
	int Y;

	APoint(int InX, int InY)
	{
		X = InX;
		Y = InY;
	}
}

int Constructed()
{
	APoint Value(2, 3);
	return Value.X + Value.Y;
}
/** @end */
/**
 * @version valid-this-field-write
 * @parent root
 * @summary This names the current instance inside a method.
 * @topic Syntax
 */
class ACounter
{
	int Count;

	void Add(int Delta)
	{
		this.Count += Delta;
	}
}

int Tick()
{
	ACounter Object;
	Object.Add(5);
	return Object.Count;
}
/** @end */
/**
 * @version invalid-this-outside-class
 * @parent root
 * @summary This has no referent at global scope.
 * @topic Negative
 */
void Test()
{
	auto X = this;
}
/** @end */
/**
 * @version invalid-duplicate-class-name
 * @parent root
 * @summary Two classes cannot share a name.
 * @topic Negative
 */
class ANode
{
	int X;
}

class ANode
{
	int Y;
}
/** @end */
/**
 * @version invalid-class-without-name
 * @parent root
 * @summary A class declaration requires a name.
 * @topic Negative
 */
class
{
	int Value;
}
/** @end */
/**
 * @version invalid-class-without-braces
 * @parent root
 * @summary A class declaration requires a body.
 * @topic Negative
 */
class ANode;
/** @end */
/**
 * @version invalid-class-invalid-member-type
 * @parent root
 * @summary A class member type must exist.
 * @topic Negative
 */
class ANode
{
	MissingType Value;
}
/** @end */
