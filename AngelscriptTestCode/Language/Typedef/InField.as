/**
 * @version v1
 * @summary Typedef aliases used as struct and class fields.
 * @topic Language
 * @topic Typedef
 *
 * struct-field                 // Index fields store and return the aliased integer.
 * two-aliased-fields           // Two struct fields can share the same typedef alias.
 * aliased-field-zero           // An aliased struct field can be written to 0 and read back.
 * typedef-class-field          // AHolder.Value is Count; writing 5 reads back 5.
 * two-aliased-class-fields     // Two class fields can share one typedef alias.
 * aliased-field-initializer    // An aliased class field may use an in-class initializer.
 */
/**
 * @begin struct-field
 * @summary Index fields store and return the aliased integer.
 * @topic Typedef
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
 * @begin two-aliased-fields
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
 * @begin aliased-field-zero
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
/**
 * @begin typedef-class-field
 * @summary AHolder.Value is Count; writing 5 reads back 5.
 * @topic Typedef
 */
typedef int Count;

class AHolder
{
	Count Value;
}

int ReadField()
{
	AHolder Object;
	Object.Value = 5;
	return Object.Value;
}
/** @end */
/**
 * @begin two-aliased-class-fields
 * @summary Two class fields can share one typedef alias.
 * @topic Typedef
 */
typedef int Count;

class APair
{
	Count Left;
	Count Right;
}

int ReadPair()
{
	APair Object;
	Object.Left = 2;
	Object.Right = 6;
	return Object.Left + Object.Right;
}
/** @end */
/**
 * @begin aliased-field-initializer
 * @summary An aliased class field may use an in-class initializer.
 * @topic Typedef
 */
typedef int Count;

class AHolder
{
	Count Value = 3;
}

int ReadDefault()
{
	AHolder Object;
	return Object.Value;
}
/** @end */
