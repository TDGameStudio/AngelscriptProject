/**
 * @version v1
 * @summary Class handle casts that must not compile.
 * @topic Language
 * @topic Casting
 *
 * invalid-unrelated-cast              // Unrelated class types cannot be cast to each other.
 * invalid-implicit-base-to-derived    // A base handle cannot convert implicitly to derived.
 * invalid-cast-on-primitive           // Handle cast cannot target a primitive value.
 * invalid-cast-to-undeclared-class    // Cast target class must be declared.
 * invalid-cast-to-struct              // Handle cast cannot target a struct.
 * invalid-cast-to-enum                // Handle cast cannot target an enum.
 * invalid-cast-without-argument       // Cast requires a value argument.
 * invalid-cast-with-two-arguments     // Cast takes one value argument.
 */
/**
 * @begin invalid-unrelated-cast
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
 * @begin invalid-implicit-base-to-derived
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
 * @begin invalid-cast-on-primitive
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
 * @begin invalid-cast-to-undeclared-class
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
 * @begin invalid-cast-to-struct
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
 * @begin invalid-cast-to-enum
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
 * @begin invalid-cast-without-argument
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
 * @begin invalid-cast-with-two-arguments
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
