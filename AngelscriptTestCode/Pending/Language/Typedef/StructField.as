/**
 * @version v1
 * @summary A typedef alias used as a struct field type.
 * @topic Language
 * @topic Typedef
 */
/**
 * @version root
 * @summary Index fields store and return the aliased integer.
 * @topic Baseline
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
 * @version valid-two-aliased-fields
 * @parent root
 * @summary Two struct fields can share the same typedef alias.
 * @topic Typedef
 */
typedef int Index;

struct FPair
{
	Index Left;
	Index Right;
}

int ReadPair()
{
	FPair Value;
	Value.Left = 2;
	Value.Right = 7;
	return Value.Left + Value.Right;
}
/** @end */
/**
 * @version valid-aliased-field-zero
 * @parent root
 * @summary An aliased struct field can be written to 0 and read back.
 * @topic Typedef
 */
typedef int Index;

struct FSlot
{
	Index Slot;
}

int ReadZero()
{
	FSlot Value;
	Value.Slot = 0;
	return Value.Slot;
}
/** @end */
