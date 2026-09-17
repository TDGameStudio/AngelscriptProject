/**
 * @version v1
 * @summary Each level of a three-class chain may override the same method.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary Calling Value on the leaf runs the leaf override and returns 3.
 * @topic Baseline
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
 * @version valid-middle-override
 * @parent root
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
/**
 * @version valid-leaf-calls-super
 * @parent root
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
