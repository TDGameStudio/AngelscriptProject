/**
 * @version v1
 * @summary Struct field declaration, in-class initializers, and annotated insertion points.
 * @topic Language
 * @topic Syntax
 *
 * fields-two                   // Two-field struct with integer and float in-class initializers.
 *   add-field                  // Insert a third annotated integer field after the first two members.
 * anonymous-struct-compiles    // Positive language form retained from legacy anonymous struct compiles.
 * struct-member-defaults       // Positive language form retained from legacy struct member defaults.
 * struct-empty-body            // A struct with no members.
 * three-fields                 // A struct with three integer members.
 * struct-bool-field            // A struct whose only member is a bool.
 */
/**
 * @begin fields-two
 * @summary Two-field struct with integer and float in-class initializers.
 * @topic Syntax
 */
struct FStructFields
{
	int X = /** @point initial-value */0;
	float Y = 0.0f;
}
/** @end */
/**
 * @begin add-field
 * @parent fields-two
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
 * @begin anonymous-struct-compiles
 * @summary Positive language form retained from legacy anonymous struct compiles.
 * @topic Syntax
 */
struct
{
	int X;
}
/** @end */
/**
 * @begin struct-member-defaults
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
 * @begin struct-empty-body
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
/**
 * @begin three-fields
 * @summary A struct with three integer members.
 * @topic Syntax
 */
struct FTriple
{
	int A;
	int B;
	int C;
}
/** @end */
/**
 * @begin struct-bool-field
 * @summary A struct whose only member is a bool.
 * @topic Syntax
 */
struct FFlag
{
	bool Ready;
}
/** @end */
