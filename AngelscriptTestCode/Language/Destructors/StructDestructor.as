/**
 * @version v1
 * @summary Struct-declared destructors that match the enclosing type name.
 * @topic Language
 * @topic Destructors
 *
 * struct-destructor                // A struct may declare an empty destructor.
 * struct-destructor-reads-field    // A struct destructor may read a field.
 */
/**
 * @begin struct-destructor
 * @summary A struct may declare an empty destructor.
 * @topic Destructors
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
 * @begin struct-destructor-reads-field
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
