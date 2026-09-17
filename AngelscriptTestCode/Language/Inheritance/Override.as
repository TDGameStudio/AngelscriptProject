/**
 * @version v1
 * @summary Derived methods marked override replace matching base methods.
 * @topic Language
 * @topic Inheritance
 *
 * method-override           // Calling the derived object runs the override.
 * override-with-argument    // A one-argument override matches the base arity and returns 4.
 * three-level-override      // Calling Value on the leaf runs the leaf override and returns 3.
 * middle-override           // Calling Value on a middle instance runs the middle override and returns 2.
 */
/**
 * @begin method-override
 * @summary Calling the derived object runs the override.
 * @topic Inheritance
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
		return 3;
	}
}

int UseOverride()
{
	AChild Object;
	return Object.Value();
}
/** @end */
/**
 * @begin override-with-argument
 * @summary A one-argument override matches the base arity and returns 4.
 * @topic Inheritance
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
 * @begin three-level-override
 * @summary Calling Value on the leaf runs the leaf override and returns 3.
 * @topic Inheritance
 */
class ARoot
{
	int Value()
	{
		return 1;
	}
}

class AMiddle : ARoot
{
	int Value() override
	{
		return 2;
	}
}

class ALeaf : AMiddle
{
	int Value() override
	{
		return 3;
	}
}

int UseLeaf()
{
	ALeaf Object;
	return Object.Value();
}
/** @end */
/**
 * @begin middle-override
 * @summary Calling Value on a middle instance runs the middle override and returns 2.
 * @topic Inheritance
 */
class ARoot
{
	int Value()
	{
		return 1;
	}
}

class AMiddle : ARoot
{
	int Value() override
	{
		return 2;
	}
}

int UseMiddle()
{
	AMiddle Object;
	return Object.Value();
}
/** @end */
