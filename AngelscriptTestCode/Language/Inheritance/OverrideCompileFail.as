/**
 * @version v1
 * @summary Override forms that do not compile.
 * @topic Language
 * @topic Inheritance
 *
 * invalid-override-without-parent-method    // Override requires a matching parent method.
 * invalid-override-wrong-return-type        // An override must use the same return type as the base method.
 * invalid-override-wrong-arity              // An override with fewer parameters than the base method is rejected.
 * invalid-override-extra-parameter          // An override with more parameters than the base method is rejected.
 * invalid-unknown-inherited-method          // A method name absent from the derived class and its base is rejected.
 */
/**
 * @begin invalid-override-without-parent-method
 * @summary Override requires a matching parent method.
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
	int Missing() override
	{
		return 2;
	}
}
/** @end */
/**
 * @begin invalid-override-wrong-return-type
 * @summary An override must use the same return type as the base method.
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
	float Value() override
	{
		return 1.0f;
	}
}
/** @end */
/**
 * @begin invalid-override-wrong-arity
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
 * @begin invalid-override-extra-parameter
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
/**
 * @begin invalid-unknown-inherited-method
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
