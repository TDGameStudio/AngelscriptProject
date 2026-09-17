/**
 * @version v1
 * @summary Method final is a live function modifier; class-level final is not.
 * @topic Language
 * @topic Inheritance
 *
 * final-method             // A method marked final can be called on its declaring class.
 * override-final-method    // An override may itself be marked final.
 */
/**
 * @begin final-method
 * @summary A method marked final can be called on its declaring class.
 * @topic Inheritance
 */
class ABase
{
	int Value() final
	{
		return 7;
	}
}

int UseFinal()
{
	ABase Object;
	return Object.Value();
}
/** @end */
/**
 * @begin override-final-method
 * @summary An override may itself be marked final.
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
	int Value() override final
	{
		return 3;
	}
}

int UseOverrideFinal()
{
	AChild Object;
	return Object.Value();
}
/** @end */
