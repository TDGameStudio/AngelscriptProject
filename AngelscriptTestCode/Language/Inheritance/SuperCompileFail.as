/**
 * @version v1
 * @summary Super forms that do not compile.
 * @topic Language
 * @topic Inheritance
 *
 * invalid-super-outside-class    // Super is invalid at global scope.
 * invalid-super-without-base     // Super is rejected when the class has no base.
 * invalid-super-unknown-field    // Super cannot name a field the base class does not declare.
 * invalid-unknown-super-type     // Super is rejected when the base type is undeclared.
 */
/**
 * @begin invalid-super-outside-class
 * @summary Super is invalid at global scope.
 * @topic Negative
 */
void Test()
{
	super.Value = 1;
}
/** @end */
/**
 * @begin invalid-super-without-base
 * @summary Super is rejected when the class has no base.
 * @topic Negative
 */
class ALone
{
	int Value()
	{
		return super.Value();
	}
}
/** @end */
/**
 * @begin invalid-super-unknown-field
 * @summary Super cannot name a field the base class does not declare.
 * @topic Negative
 */
class ABase
{
	int Value;
}

class AChild : ABase
{
	int Read()
	{
		return super.Missing;
	}
}
/** @end */
/**
 * @begin invalid-unknown-super-type
 * @summary Super is rejected when the base type is undeclared.
 * @topic Negative
 */
class AChild : AMissing
{
	int Value()
	{
		return super.Value();
	}
}
/** @end */
