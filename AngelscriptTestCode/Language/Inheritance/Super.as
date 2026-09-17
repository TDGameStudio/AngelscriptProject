/**
 * @version v1
 * @summary Super names the immediate base from a derived method.
 * @topic Language
 * @topic Inheritance
 *
 * super-call                    // An override calls the base method through super.
 * super-field-read              // A derived method reads super.Value after writing 4 and returns 4.
 * super-field-plus-own-field    // Super field read can be added to a field declared on the child.
 * leaf-calls-super              // The leaf override calls super and receives the middle result 2, then returns 5.
 */
/**
 * @begin super-call
 * @summary An override calls the base method through super.
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
 * @begin super-field-read
 * @summary A derived method reads super.Value after writing 4 and returns 4.
 * @topic Inheritance
 */
class ABase
{
	int Value;
}

class AChild : ABase
{
	int Read()
	{
		super.Value = 4;
		return super.Value;
	}
}

int UseSuperField()
{
	AChild Object;
	return Object.Read();
}
/** @end */
/**
 * @begin super-field-plus-own-field
 * @summary Super field read can be added to a field declared on the child.
 * @topic Inheritance
 */
class ABase
{
	int Value;
}

class AChild : ABase
{
	int Extra;

	int Sum()
	{
		super.Value = 2;
		Extra = 5;
		return super.Value + Extra;
	}
}

int UseSum()
{
	AChild Object;
	return Object.Sum();
}
/** @end */
/**
 * @begin leaf-calls-super
 * @summary The leaf override calls super and receives the middle result 2, then returns 5.
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
		return super.Value() + 3;
	}
}

int UseLeafSuper()
{
	ALeaf Object;
	return Object.Value();
}
/** @end */
