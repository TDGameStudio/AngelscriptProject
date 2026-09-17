/**
 * @version v1
 * @summary Enum declarations, explicit values, and local use.
 * @topic Language
 * @topic Syntax
 *
 * enum
 * basic-enum-values
 * empty-enum-declaration
 * enum-explicit-values
 * enum-local-usage
 * enum-trailing-comma
 */
/**
 * @begin enum
 * @summary An implicit enum and an explicitly numbered enum used as a local.
 */
enum EColor
{
	Red,
	Green,
	Blue
}

enum EMask
{
	None = 0,
	Read = 1,
	Write = 2,
	ReadWrite = 3
}

int LocalEnum()
{
	EColor Color = EColor::Green;
	EMask Mask = EMask::Read;
	if (Color == EColor::Green)
	{
		return int(Mask);
	}
	return 0;
}
/** @end */
/**
 * @begin basic-enum-values
 * @summary Positive language form retained from legacy basic enum values.
 * @topic Syntax
 */
enum EEnumBasic
{
	Value1,
	Value2,
	Value3
}
/** @end */
/**
 * @begin empty-enum-declaration
 * @summary Positive language form retained from legacy empty enum declaration.
 * @topic Syntax
 */
enum EEnumEmpty
{
}
/** @end */
/**
 * @begin enum-explicit-values
 * @summary Positive language form retained from legacy enum explicit values.
 * @topic Syntax
 */
enum EEnumExplicit
{
	Value1 = 0,
	Value2 = 5,
	Value3 = 10
}
/** @end */
/**
 * @begin enum-local-usage
 * @summary Positive language form retained from legacy enum local usage.
 * @topic Syntax
 */
enum EEnumUsage
{
	Val1,
	Val2
}

namespace SyntaxTest
{
	void Test()
	{
		EEnumUsage E = EEnumUsage::Val1;
	}

	
	}
/** @end */
/**
 * @begin enum-trailing-comma
 * @summary An enumerator list that ends with a trailing comma.
 * @topic Syntax
 */
enum ELane
{
	Low,
	High,
}

int Use()
{
	return int(ELane::High);
}
/** @end */
