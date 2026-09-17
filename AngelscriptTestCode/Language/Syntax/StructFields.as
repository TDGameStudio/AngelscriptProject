/**
 * @version v1
 * @summary Struct field declaration, in-class initializers, and annotated insertion points.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary Two-field struct with integer and float in-class initializers.
 * @topic Baseline
 */
struct FStructFields
{
	int X = /** @point initial-value */0;
	float Y = 0.0f;
}
/** @end */
/**
 * @version add-field
 * @parent root
 * @summary Insert a third annotated integer field after the first two members.
 * @topic Syntax
 */
struct FStructFields
{
	int X = 0;
	float Y = 0.0f;
	/** @breakpoint before-add */int Z = /** @range-begin delta */1/** @range-end delta */;
}
/** @end */
/**
 * @version invalid-duplicate-field
 * @parent root
 * @summary Duplicate member name is an invalid field declaration.
 * @topic Negative
 */
struct FStructFields
{
	int X = 0;
	float X = 1.0f;
}
/** @end */
/**
 * @version valid-anonymous-struct-compiles
 * @parent root
 * @summary Positive language form retained from legacy anonymous struct compiles.
 * @topic Syntax
 */
struct
{
	int X;
}
/** @end */
/**
 * @version valid-struct-member-defaults
 * @parent root
 * @summary Positive language form retained from legacy struct member defaults.
 * @topic Syntax
 */
struct FStructDefaults
{
	int X = 42;
	string Name = "Default";
}
/** @end */
/**
 * @version invalid-duplicate-struct-name
 * @parent root
 * @summary Compile-rejection form retained from legacy duplicate struct name.
 * @topic Negative
 */
struct FDup
{
	int X;
}

struct FDup
{
	int Y;
}
/** @end */
/**
 * @version invalid-struct-inheritance
 * @parent root
 * @summary Compile-rejection form retained from legacy struct inheritance.
 * @topic Negative
 */
struct FBase
{
	int X;
}

struct FChild : FBase
{
	int Y;
}
/** @end */
/**
 * @version invalid-struct-invalid-member-type
 * @parent root
 * @summary Compile-rejection form retained from legacy struct invalid member type.
 * @topic Negative
 */
struct FStructBadMember
{
	NonExistentType X;
}
/** @end */
/**
 * @version invalid-struct-void-member
 * @parent root
 * @summary Compile-rejection form retained from legacy struct void member.
 * @topic Negative
 */
struct FStructVoidMember
{
	void X;
}
/** @end */
/**
 * @version valid-struct-empty-body
 * @parent root
 * @summary A struct with no members.
 * @topic Syntax
 */
struct FEmpty
{
}

int Use()
{
	FEmpty Value;
	return 0;
}
/** @end */
