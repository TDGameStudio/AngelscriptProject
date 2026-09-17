/**
 * @version v1
 * @summary Host-free class inheritance, override, super, and final.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A derived class overrides a base method and calls super.
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
		return super.Value() + 2;
	}
}

int UseOverride()
{
	AChild Object;
	return Object.Value();
}
/** @end */
/**
 * @version valid-two-level-inheritance
 * @parent root
 * @summary A grandchild inherits through an intermediate class.
 * @topic Syntax
 */
class ARoot
{
	int Id;
}

class AMiddle : ARoot
{
	int Extra;
}

class ALeaf : AMiddle
{
	int Leaf;
}

int UseChain()
{
	ALeaf Object;
	Object.Id = 1;
	Object.Extra = 2;
	Object.Leaf = 3;
	return Object.Id + Object.Extra + Object.Leaf;
}
/** @end */
/**
 * @version valid-base-view-of-derived
 * @parent root
 * @summary A derived object can be viewed through a base handle.
 * @topic Syntax
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
 * @version valid-final-class
 * @parent root
 * @summary A final class may be constructed but not used as a base.
 * @topic Syntax
 */
class ASealed final
{
	int Value;
}

int UseFinal()
{
	ASealed Object;
	Object.Value = 7;
	return Object.Value;
}
/** @end */
/**
 * @version invalid-inherit-from-final
 * @parent root
 * @summary A final class cannot be a base.
 * @topic Negative
 */
class ASealed final
{
	int Value;
}

class AChild : ASealed
{
	int Extra;
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
 * @version invalid-super-outside-class
 * @parent root
 * @summary Super is invalid outside a derived type.
 * @topic Negative
 */
void Test()
{
	super.Value = 1;
}
/** @end */
/**
 * @version invalid-class-self-inheritance
 * @parent root
 * @summary A class cannot inherit from itself.
 * @topic Negative
 */
class ANode : ANode
{
	int Value;
}
/** @end */
/**
 * @version invalid-unknown-super-type
 * @parent root
 * @summary A base class must be declared.
 * @topic Negative
 */
class AChild : AMissing
{
	int Value;
}
/** @end */
