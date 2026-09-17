/**
 * @version v1
 * @summary Base and derived classes may each declare a matching destructor.
 * @topic Language
 * @topic Destructors
 *
 * base-and-derived           // A derived object has both destructor declarations in source.
 * derived-destructor-only    // A derived class may declare a destructor when the base does not.
 * base-destructor-only       // A base destructor is legal when the derived class declares none.
 */
/**
 * @begin base-and-derived
 * @summary A derived object has both destructor declarations in source.
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
 * @begin derived-destructor-only
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
 * @begin base-destructor-only
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
