/**
 * @version v1
 * @summary Upcast, downcast, and round-trip class handle casts.
 * @topic Language
 * @topic Casting
 */
/**
 * @version root
 * @summary Derived-to-base implicit handle conversion and an explicit downcast.
 * @topic Baseline
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ABase@ ImplicitDerivedToBase(ADerived@ Child)
{
	ABase@ Parent = Child;
	return Parent;
}

ADerived@ CastDowncast(ABase@ Parent)
{
	return cast<ADerived>(Parent);
}

ADerived@ CastRoundTrip(ADerived@ Child)
{
	ABase@ Parent = Child;
	ADerived@ Again = cast<ADerived>(Parent);
	if (Again is null)
	{
		return null;
	}
	return Again;
}
/** @end */
/**
 * @version invalid-unrelated-cast
 * @parent root
 * @summary Unrelated class types cannot be cast to each other.
 * @topic Negative
 */
class ALeft
{
	int X;
}

class ARight
{
	int Y;
}

void Test(ALeft@ Left)
{
	ARight@ Right = cast<ARight>(Left);
}
/** @end */
/**
 * @version valid-cast-downcast
 * @parent root
 * @summary Authored language form for cast downcast.
 * @topic Casting
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ADerived@ CastDowncast(ABase@ Parent)
{
	return cast<ADerived>(Parent);
}
/** @end */
/**
 * @version valid-cast-to-parent-class
 * @parent root
 * @summary Authored language form for cast to parent class.
 * @topic Casting
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ABase@ CastToParent(ADerived@ Child)
{
	return cast<ABase>(Child);
}
/** @end */
/**
 * @version valid-implicit-derived-to-base
 * @parent root
 * @summary Authored language form for implicit derived to base.
 * @topic Casting
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ABase@ ImplicitDerivedToBase(ADerived@ Child)
{
	ABase@ Parent = Child;
	return Parent;
}
/** @end */
/**
 * @version invalid-cast-on-primitive
 * @parent root
 * @summary Handle cast cannot target a primitive value.
 * @topic Negative
 */
void Test()
{
	int Value = 5;
	int Casted = cast<int>(Value);
}
/** @end */
/**
 * @version invalid-implicit-base-to-derived
 * @parent root
 * @summary A base handle cannot convert implicitly to derived.
 * @topic Negative
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

void TakeDerived(ADerived@ Child)
{
	Child = Child;
}

void Test(ABase@ Parent)
{
	TakeDerived(Parent);
}
/** @end */
/**
 * @version invalid-cast-to-undeclared-class
 * @parent root
 * @summary Cast target class must be declared.
 * @topic Negative
 */
class ABase
{
	int Id;
}

void Test(ABase@ Parent)
{
	AMissing@ Child = cast<AMissing>(Parent);
}
/** @end */
/**
 * @version invalid-cast-to-struct
 * @parent root
 * @summary Handle cast cannot target a struct.
 * @topic Negative
 */
struct FBox
{
	int X;
}

class ANode
{
	int Value;
}

void Test(ANode@ Node)
{
	FBox Value = cast<FBox>(Node);
}
/** @end */
/**
 * @version invalid-cast-to-enum
 * @parent root
 * @summary Handle cast cannot target an enum.
 * @topic Negative
 */
enum ELane
{
	Low
}

class ANode
{
	int Value;
}

void Test(ANode@ Node)
{
	ELane Lane = cast<ELane>(Node);
}
/** @end */
/**
 * @version invalid-cast-without-argument
 * @parent root
 * @summary Cast requires a value argument.
 * @topic Negative
 */
class ANode
{
	int Value;
}

void Test()
{
	ANode@ Node = cast<ANode>();
}
/** @end */
/**
 * @version invalid-cast-with-two-arguments
 * @parent root
 * @summary Cast takes one value argument.
 * @topic Negative
 */
class ANode
{
	int Value;
}

void Test(ANode@ Left, ANode@ Right)
{
	ANode@ Node = cast<ANode>(Left, Right);
}
/** @end */
/**
 * @version invalid-class-without-name
 * @parent root
 * @summary A class declaration requires a name.
 * @topic Negative
 */
class
{
	int Value;
}
/** @end */
/**
 * @version invalid-class-without-braces
 * @parent root
 * @summary A class declaration requires a body.
 * @topic Negative
 */
class ANode;
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
 * @version invalid-duplicate-class-name
 * @parent root
 * @summary Two classes cannot share a name.
 * @topic Negative
 */
class ANode
{
	int X;
}

class ANode
{
	int Y;
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
