/**
 * @version v1
 * @summary Class constructors, two-argument calls, and overload sets.
 * @topic Language
 * @topic Class
 *
 * constructor                 // A one-argument constructor stores the given size.
 * constructor-two-args        // A two-argument constructor stores both coordinates.
 * constructor-overload-set    // Default and two-argument constructors coexist on one class.
 * default-construct           // A default constructor runs when a local is declared without arguments.
 */
/**
 * @begin constructor
 * @summary A one-argument constructor stores the given size.
 * @topic Class
 */
class ABox
{
	int Size;

	ABox(int InSize)
	{
		Size = InSize;
	}
}

int Constructed()
{
	ABox Object(4);
	return Object.Size;
}
/** @end */
/**
 * @begin constructor-two-args
 * @summary A two-argument constructor stores both coordinates.
 * @topic Class
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

int ConstructedTwoArgs()
{
	APoint Offset(2, 3);
	return Offset.X + Offset.Y;
}
/** @end */
/**
 * @begin constructor-overload-set
 * @summary Default and two-argument constructors coexist on one class.
 * @topic Class
 */
class APoint
{
	int X;
	int Y;

	APoint()
	{
		X = 0;
		Y = 0;
	}

	APoint(int InX, int InY)
	{
		X = InX;
		Y = InY;
	}
}

int ConstructedOverloadSet()
{
	APoint Origin;
	APoint Offset(2, 3);
	return Origin.X + Offset.Y;
}
/** @end */
/**
 * @begin default-construct
 * @summary A default constructor runs when a local is declared without arguments.
 * @topic Class
 */
class AOrigin
{
	int X;
	int Y;

	AOrigin()
	{
		X = 1;
		Y = 2;
	}
}

int UseDefault()
{
	AOrigin Value;
	return Value.X + Value.Y;
}
/** @end */
