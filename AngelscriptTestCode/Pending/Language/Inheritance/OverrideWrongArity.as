/**
 * @version v1
 * @summary An override must use the same parameter count as the base method.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary A one-argument override matches the base arity and returns 4.
 * @topic Baseline
 */
class ABase
{
	int Value(int Amount)
	{
		return Amount;
	}
}

class AChild : ABase
{
	int Value(int Amount) override
	{
		return Amount + 1;
	}
}

int UseMatchingArity()
{
	AChild Object;
	return Object.Value(3);
}
/** @end */
/**
 * @version invalid-override-wrong-arity
 * @parent root
 * @summary An override with fewer parameters than the base method is rejected.
 * @topic Negative
 */
class ABase
{
	int Value(int Amount)
	{
		return Amount;
	}
}

class AChild : ABase
{
	int Value() override
	{
		return 0;
	}
}
/** @end */
/**
 * @version invalid-override-extra-parameter
 * @parent root
 * @summary An override with more parameters than the base method is rejected.
 * @topic Negative
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
	int Value(int Extra) override
	{
		return Extra;
	}
}
/** @end */
