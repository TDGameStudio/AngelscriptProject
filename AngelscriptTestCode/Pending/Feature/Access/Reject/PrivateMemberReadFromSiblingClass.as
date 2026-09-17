/**
 * @version v1
 * @summary Reading a private member from a sibling class is rejected. Sharing a base does not grant access to a sibling's private field. This file is the illegal program itself; do not make X public, since the sibling read is the.
 * @topic Feature
 */
/**
 * @version root
 * @summary Reading a private member from a sibling class is rejected. Sharing a base does not grant access to a sibling's private field. This file is the illegal program itself; do not make X public, since the sibling read is the.
 * @topic Negative
 */
/**
 * A shared base that grants no private access between siblings.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once a sibling reads the other sibling's private field
 */
class ABase : AActor
{
}

/**
 * One sibling that holds a private field.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once X is read from the other sibling
 */
class ASiblingA : ABase
{
	private int X = 1;
}

/**
 * The other sibling, which tries to read the private field.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class ASiblingB : ABase
{
	/**
	 * Attempt to read the sibling's private member.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return does not compile
	 */
	void Foo()
	{
		ASiblingA A;
		int Y = A.X;
	}
}
/** @end */
