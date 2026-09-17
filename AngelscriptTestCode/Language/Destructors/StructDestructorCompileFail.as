/**
 * @version v1
 * @summary Struct destructor forms that the live parser rejects.
 * @topic Language
 * @topic Destructors
 *
 * invalid-struct-destructor-return-type       // A struct destructor cannot declare a return type.
 * invalid-struct-destructor-with-parameter    // A struct destructor cannot take a parameter.
 */
/**
 * @begin invalid-struct-destructor-return-type
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
 * @begin invalid-struct-destructor-with-parameter
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
