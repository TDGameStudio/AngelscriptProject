/**
 * @version v1
 * @summary Base and derived classes each declare a destructor.
 * @topic Language
 * @topic Destructors
 */
/**
 * @version root
 * @summary A derived object has both destructor declarations in source.
 * @topic Baseline
 */
class ABase
{
	int BaseValue;

	~ABase()
	{
	}
}

class AChild : ABase
{
	int ChildValue;

	~AChild()
	{
	}
}

int UseBoth()
{
	AChild Object;
	Object.BaseValue = 1;
	Object.ChildValue = 2;
	return Object.BaseValue + Object.ChildValue;
}
/** @end */
/**
 * @version valid-derived-destructor-only
 * @parent root
 * @summary A derived class may declare a destructor when the base does not.
 * @topic Destructors
 */
class ABase
{
	int BaseValue;
}

class AChild : ABase
{
	int ChildValue;

	~AChild()
	{
	}
}

int UseDerivedOnly()
{
	AChild Object;
	Object.BaseValue = 1;
	Object.ChildValue = 2;
	return Object.BaseValue + Object.ChildValue;
}
/** @end */
/**
 * @version valid-base-destructor-only
 * @parent root
 * @summary A base destructor is legal when the derived class declares none.
 * @topic Destructors
 */
class ABase
{
	int BaseValue;

	~ABase()
	{
	}
}

class AChild : ABase
{
	int ChildValue;
}

int UseBaseOnly()
{
	AChild Object;
	Object.BaseValue = 1;
	Object.ChildValue = 2;
	return Object.BaseValue + Object.ChildValue;
}
/** @end */
