/**
 * @version v1
 * @summary A typedef alias can be a class field type.
 * @topic Language
 * @topic Typedef
 */
/**
 * @version root
 * @summary AHolder.Value is Count; writing 5 reads back 5.
 * @topic Baseline
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
 * @version valid-two-aliased-class-fields
 * @parent root
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
 * @version valid-aliased-field-initializer
 * @parent root
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
