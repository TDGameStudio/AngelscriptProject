/**
 * @version v1
 * @summary Reading a private member from an unrelated class is rejected. This file is the illegal program itself; do not make Secret public, since the unrelated read is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Reading a private member from an unrelated class is rejected. This file is the illegal program itself; do not make Secret public, since the unrelated read is the point.
 * @topic Negative
 */
/**
 * An actor whose only member is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once Secret is read from an unrelated class
 */
class AActorPrivViaUnrel : AActor
{
	private int Secret = 42;
}

/**
 * An unrelated actor that tries to read the private member.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class AOther : AActor
{
	/**
	 * Attempt to read Secret from a type that does not declare it.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return does not compile
	 */
	void Foo()
	{
		AActorPrivViaUnrel A;
		int X = A.Secret;
	}
}
/** @end */
