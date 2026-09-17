/**
 * @version v1
 * @summary A derived method marked override replaces the base method.
 * @topic Language
 * @topic Inheritance
 */
/**
 * @version root
 * @summary Calling the derived object runs the override.
 * @topic Baseline
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
 * @version invalid-override-without-parent-method
 * @parent root
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
 * @version invalid-override-wrong-return-type
 * @parent root
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
