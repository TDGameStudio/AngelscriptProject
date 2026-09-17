/**
 * @version v1
 * @summary Super names the immediate base inside a derived method.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary An override calls the base method through super.
 * @topic Baseline
 */
class ABase
{
	int Value()
	{
		return 1;
	}
}

class AChild : ABase
{
	int Value() override
	{
		return super.Value() + 2;
	}
}

int UseSuper()
{
	AChild Object;
	return Object.Value();
}
/** @end */
/**
 * @version invalid-super-outside-class
 * @parent root
 * @summary Super is invalid at global scope.
 * @topic Negative
 */
void Test()
{
	super.Value = 1;
}
/** @end */
/**
 * @version invalid-super-without-base
 * @parent root
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
