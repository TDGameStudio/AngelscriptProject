/**
 * @version v1
 * @summary Reading a protected member from an unrelated class is rejected. This file is the illegal program itself; do not derive AOtherActor from AActorProtUnrel, since the unrelated read is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Reading a protected member from an unrelated class is rejected. This file is the illegal program itself; do not derive AOtherActor from AActorProtUnrel, since the unrelated read is the point.
 * @topic Negative
 */
/**
 * An actor whose only member is protected.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once ProtVal is read from an unrelated class
 */
class AActorProtUnrel : AActor
{
	protected int ProtVal = 10;
}

/**
 * An unrelated actor that tries to read the protected member.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class AOtherActor : AActor
{
	/**
	 * Attempt to read ProtVal from a type that does not inherit it.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return does not compile
	 */
	void Foo()
	{
		AActorProtUnrel A;
		int X = A.ProtVal;
	}
}
/** @end */
