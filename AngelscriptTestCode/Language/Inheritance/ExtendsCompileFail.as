/**
 * @version v1
 * @summary Extends forms that do not compile.
 * @topic Language
 * @topic Inheritance
 *
 * invalid-implicit-base-to-derived    // A base handle cannot convert to a derived handle without a cast.
 * invalid-class-self-inheritance      // Inheriting from the same class name is rejected.
 * invalid-unknown-ancestor-field      // A name not declared on any ancestor cannot be read.
 * invalid-unknown-base                // Deriving from an undeclared base type is rejected.
 */
/**
 * @begin invalid-implicit-base-to-derived
 * @summary A base handle cannot convert to a derived handle without a cast.
 * @topic Negative
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

void Test(ABase@ Parent)
{
	AChild@ Child = Parent;
}
/** @end */
/**
 * @begin invalid-class-self-inheritance
 * @summary Inheriting from the same class name is rejected.
 * @topic Negative
 */
class ANode : ANode
{
	int Value;
}
/** @end */
/**
 * @begin invalid-unknown-ancestor-field
 * @summary A name not declared on any ancestor cannot be read.
 * @topic Negative
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

int Test()
{
	ALeaf Object;
	return Object.Missing;
}
/** @end */
/**
 * @begin invalid-unknown-base
 * @summary Deriving from an undeclared base type is rejected.
 * @topic Negative
 */
class AChild : AMissing
{
	int Extra;
}
/** @end */
