/**
 * @version v1
 * @summary A derived instance can call a method declared only on its base.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary AChild declares no Value; Object.Value() runs ABase.Value and returns 7.
 * @topic Baseline
 */
class ABase
{
	int Value()
	{
		return 7;
	}
}

class AChild : ABase
{
	int Extra;
}

int UseInherited()
{
	AChild Object;
	return Object.Value();
}
/** @end */
/**
 * @version valid-inherited-method-with-argument
 * @parent root
 * @summary An inherited one-argument method can be called on the derived instance.
 * @topic Inheritance
 */
class ABase
{
	int Scale(int Amount)
	{
		return Amount * 2;
	}
}

class AChild : ABase
{
}

int UseScale()
{
	AChild Object;
	return Object.Scale(4);
}
/** @end */
/**
 * @version invalid-unknown-inherited-method
 * @parent root
 * @summary A method name absent from the derived class and its base is rejected.
 * @topic Negative
 */
class ABase
{
	int Value()
	{
		return 7;
	}
}

class AChild : ABase
{
}

int Test()
{
	AChild Object;
	return Object.Missing();
}
/** @end */
