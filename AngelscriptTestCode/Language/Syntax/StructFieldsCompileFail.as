/**
 * @version v1
 * @summary Compile-fail cases for StructFields.
 * @topic Language
 * @topic Syntax
 *
 * invalid-duplicate-field
 * invalid-duplicate-struct-name
 * invalid-struct-inheritance
 * invalid-struct-invalid-member-type
 * invalid-struct-void-member
 */
/**
 * @begin invalid-duplicate-field
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
 * @begin invalid-duplicate-struct-name
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
 * @begin invalid-struct-inheritance
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
 * @begin invalid-struct-invalid-member-type
 * @summary Compile-rejection form retained from legacy struct invalid member type.
 * @topic Negative
 */
struct FStructBadMember
{
	NonExistentType X;
}
/** @end */
/**
 * @begin invalid-struct-void-member
 * @summary Compile-rejection form retained from legacy struct void member.
 * @topic Negative
 */
struct FStructVoidMember
{
	void X;
}
/** @end */
