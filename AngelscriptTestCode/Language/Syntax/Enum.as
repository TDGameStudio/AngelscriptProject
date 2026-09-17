/**
 * @version v1
 * @summary Enum declarations, explicit values, and local use.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary An implicit enum and an explicitly numbered enum used as a local.
 * @topic Baseline
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
 * @version invalid-duplicate-enumerator
 * @parent root
 * @summary Enumerator names must be unique in one enum.
 * @topic Negative
 */
enum EColor
{
	Red,
	Red
}
/** @end */
/**
 * @version invalid-enum-without-name
 * @parent root
 * @summary An enum declaration requires a name.
 * @topic Negative
 */
enum
{
	Red
}
/** @end */
/**
 * @version valid-basic-enum-values
 * @parent root
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
 * @version valid-empty-enum-declaration
 * @parent root
 * @summary Positive language form retained from legacy empty enum declaration.
 * @topic Syntax
 */
enum EEnumEmpty
{
}
/** @end */
/**
 * @version valid-enum-explicit-values
 * @parent root
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
 * @version valid-enum-local-usage
 * @parent root
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
 * @version invalid-method-inside-enum
 * @parent root
 * @summary Compile-rejection form retained from legacy method inside enum.
 * @topic Negative
 */
enum EEnumMethod
{
	Value1;
void Foo()
	{
	}
}
/** @end */
/**
 * @version invalid-non-integer-enumerator
 * @parent root
 * @summary Compile-rejection form retained from legacy non integer enumerator.
 * @topic Negative
 */
enum EEnumBadVal
{
	Value1 = "hello"
}
/** @end */
/**
 * @version valid-enum-trailing-comma
 * @parent root
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
