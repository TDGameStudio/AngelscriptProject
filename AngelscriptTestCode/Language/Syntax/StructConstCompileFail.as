/**
 * @version v1
 * @summary Compile-fail cases for StructConst.
 * @topic Language
 * @topic Syntax
 *
 * invalid-mutate-in-const-method
 * invalid-mutate-member-in-const-method
 */
/**
 * @begin invalid-mutate-in-const-method
 * @summary A const method cannot assign a member.
 * @topic Negative
 */
struct FSize
{
	int Width;

	void Grow() const
	{
		Width += 1;
	}
}
/** @end */
/**
 * @begin invalid-mutate-member-in-const-method
 * @summary Compile-rejection form retained from legacy mutate member in const method.
 * @topic Negative
 */
struct FStructConstModify
{
	int X = 0;

	void Bad() const
	{
		X = 5;
	}
}
/** @end */
