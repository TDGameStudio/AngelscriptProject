/**
 * @version v1
 * @summary Derived classes inherit methods and fields from a declared base.
 * @topic Language
 * @topic Inheritance
 *
 * derived-as-base-handle            // Assigning a derived handle to a base handle keeps the object.
 * derived-local-as-base-handle      // A derived local can be viewed through a base handle.
 * inherited-method                  // AChild declares no Value; Object.Value() runs ABase.Value and returns 7.
 * inherited-method-with-argument    // An inherited one-argument method can be called on the derived instance.
 * inherited-field-read              // A derived instance can read a field declared only on its base.
 */
/**
 * @begin derived-as-base-handle
 * @summary Assigning a derived handle to a base handle keeps the object.
 * @topic Inheritance
 */
class ABase
{
	int Value()
	{
		return 10;
	}
}

class AChild : ABase
{
	int Value() override
	{
		return 20;
	}
}

int UseBaseView(AChild@ Child)
{
	ABase@ Parent = Child;
	return Parent.Value();
}
/** @end */
/**
 * @begin derived-local-as-base-handle
 * @summary A derived local can be viewed through a base handle.
 * @topic Inheritance
 */
class ABase
{
	int Value()
	{
		return 10;
	}
}

class AChild : ABase
{
	int Value() override
	{
		return 20;
	}
}

int UseLocal()
{
	AChild Object;
	ABase@ Parent = Object;
	return Parent.Value();
}
/** @end */
/**
 * @begin inherited-method
 * @summary AChild declares no Value; Object.Value() runs ABase.Value and returns 7.
 * @topic Inheritance
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
 * @begin inherited-method-with-argument
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
 * @begin inherited-field-read
 * @summary A derived instance can read a field declared only on its base.
 * @topic Inheritance
 */
class ABase
{
	int Value;
}

class AChild : ABase
{
}

int UseField()
{
	AChild Object;
	Object.Value = 4;
	return Object.Value;
}
/** @end */
