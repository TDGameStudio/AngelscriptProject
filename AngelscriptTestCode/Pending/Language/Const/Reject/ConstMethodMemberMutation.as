/**
 * @version v1
 * @summary Mutating a member from a const method is rejected: a const method promises not to change the object it is called on. This file is the illegal program itself; do not drop the const to make it compile.
 * @topic Language
 * @topic Const
 */
/**
 * @version root
 * @summary Mutating a member from a const method is rejected: a const method promises not to change the object it is called on. This file is the illegal program itself; do not drop the const to make it compile.
 * @topic Negative
 */
class ConstMutationProbe
{
	int Value = 0;

/** */
	void Mutate() const
	{
		Value = 2;
	}
}
/** @end */
/**
 * @version invalid-const-method-compound
 * @parent root
 * @summary A const method cannot compound-assign a member.
 * @topic Negative
 */
class ConstMutationProbe
{
	int Value = 0;

	void Mutate() const
	{
		Value += 1;
	}
}
/** @end */
/**
 * @version invalid-const-method-increment
 * @parent root
 * @summary A const method cannot increment a member.
 * @topic Negative
 */
class ConstMutationProbe
{
	int Value = 0;

	void Mutate() const
	{
		Value++;
	}
}
/** @end */
