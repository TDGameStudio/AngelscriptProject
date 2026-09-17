/**
 * @version v1
 * @summary A derived object viewed through a base handle.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary Assigning a derived handle to a base handle keeps the object.
 * @topic Baseline
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
 * @version valid-derived-local-as-base-handle
 * @parent root
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
 * @version invalid-implicit-base-to-derived
 * @parent root
 * @summary A base handle cannot convert to a derived handle without a cast.
 * @topic Negative
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

void Test(ABase@ Parent)
{
	AChild@ Child = Parent;
}
/** @end */
