/**
 * @version v1
 * @summary Super names a field declared on the immediate base class.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary A derived method reads super.Value after writing 4 and returns 4.
 * @topic Baseline
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
 * @version valid-super-field-plus-own-field
 * @parent root
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
 * @version invalid-super-unknown-field
 * @parent root
 * @summary Super cannot name a field the base class does not declare.
 * @topic Negative
 */
class ABase
{
	int Value;
}

class AChild : ABase
{
	int Read()
	{
		return super.Missing;
	}
}
/** @end */
