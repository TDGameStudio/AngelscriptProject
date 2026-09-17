/**
 * @version v1
 * @summary A struct-declared destructor with no parameters.
 * @topic Language
 * @topic Destructors
 */
/**
 * @version root
 * @summary A struct may declare an empty destructor.
 * @topic Baseline
 */
struct FPoint
{
	int X;

	~FPoint()
	{
	}
}

int UseStruct()
{
	FPoint Value;
	Value.X = 8;
	return Value.X;
}
/** @end */
/**
 * @version invalid-struct-destructor-return-type
 * @parent root
 * @summary A struct destructor cannot declare a return type.
 * @topic Negative
 */
struct FPoint
{
	int ~FPoint()
	{
		return 0;
	}
}
/** @end */
/**
 * @version invalid-struct-destructor-with-parameter
 * @parent root
 * @summary A struct destructor cannot take a parameter.
 * @topic Negative
 */
struct FPoint
{
	~FPoint(int Invalid)
	{
	}
}
/** @end */
