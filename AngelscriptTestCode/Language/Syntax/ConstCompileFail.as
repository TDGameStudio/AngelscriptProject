/**
 * @version v1
 * @summary Compile-fail cases for Const.
 * @topic Language
 * @topic Syntax
 *
 * invalid-assign-const-local                // A const local cannot be reassigned.
 * invalid-const-without-initializer         // A const local requires an initializer.
 * invalid-const-local-mutation              // Compile-rejection form retained from legacy const local mutation.
 * invalid-const-method-member-mutation      // Compile-rejection form retained from legacy const method member mutation.
 * invalid-const-value-parameter-mutation    // Compile-rejection form retained from legacy const value parameter mutation.
 * invalid-this-outside-class                // This is invalid outside a class or struct method.
 */
/**
 * @begin invalid-assign-const-local
 * @summary A const local cannot be reassigned.
 * @topic Negative
 */
void Test()
{
	const int Limit = 3;
	Limit = 4;
}
/** @end */
/**
 * @begin invalid-const-without-initializer
 * @summary A const local requires an initializer.
 * @topic Negative
 */
void Test()
{
	const int Limit;
}
/** @end */
/**
 * @begin invalid-const-local-mutation
 * @summary Compile-rejection form retained from legacy const local mutation.
 * @topic Negative
 */
void Test()
{
	const int Value = 1;
	Value = 2;
}
/** @end */
/**
 * @begin invalid-const-method-member-mutation
 * @summary Compile-rejection form retained from legacy const method member mutation.
 * @topic Negative
 */
class ConstMutationProbe
{
	int Value = 0;

void Mutate() const
	{
		Value = 2;
	}
}
/** @end */
/**
 * @begin invalid-const-value-parameter-mutation
 * @summary Compile-rejection form retained from legacy const value parameter mutation.
 * @topic Negative
 */
void Test(const int Value)
{
	Value = 2;
}
/** @end */
/**
 * @begin invalid-this-outside-class
 * @summary This is invalid outside a class or struct method.
 * @topic Negative
 */
void Test()
{
	int Value = this;
}
/** @end */
