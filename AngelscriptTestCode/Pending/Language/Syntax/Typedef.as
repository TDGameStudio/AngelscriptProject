/**
 * @version v1
 * @summary Script typedef aliases for existing types.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A typedef alias used as a local and a parameter.
 * @topic Baseline
 */
typedef int Count;

int Add(Count Left, Count Right)
{
	return Left + Right;
}

int UseAlias()
{
	Count Value = 3;
	return Add(Value, 4);
}
/** @end */
/**
 * @version valid-typedef-of-float
 * @parent root
 * @summary A typedef may alias float.
 * @topic Syntax
 */
typedef float Scale;

float Apply(Scale Amount)
{
	return Amount * 2.0f;
}
/** @end */
/**
 * @version valid-typedef-in-struct-field
 * @parent root
 * @summary A typedef alias may be a struct field type.
 * @topic Syntax
 */
typedef int Index;

struct FSlot
{
	Index Slot;
}

int ReadSlot()
{
	FSlot Value;
	Value.Slot = 9;
	return Value.Slot;
}
/** @end */
/**
 * @version invalid-typedef-unknown-type
 * @parent root
 * @summary A typedef source type must exist.
 * @topic Negative
 */
typedef MissingType Alias;
/** @end */
/**
 * @version invalid-duplicate-typedef
 * @parent root
 * @summary Two typedefs cannot share a name.
 * @topic Negative
 */
typedef int Count;
typedef float Count;
/** @end */
/**
 * @version invalid-typedef-without-name
 * @parent root
 * @summary A typedef requires an alias name.
 * @topic Negative
 */
typedef int;
/** @end */
