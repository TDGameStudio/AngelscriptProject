/**
 * @version v1
 * @summary Private member and method declarations compile. SecretVal and SecretFunc stay private and are not called from outside. Construction succeeds, and two instances stay independent objects.
 * @topic Feature
 */
/**
 * @version root
 * @summary Private member and method declarations compile. SecretVal and SecretFunc stay private and are not called from outside. Construction succeeds, and two instances stay independent objects.
 * @topic Baseline
 */
class AActorPrivDecl : AActor
{
	private int SecretVal = 42;

	/**
	 * A private method that writes the private field. It is never called from
	 * outside; declaring it is the point.
	 *
	 * @Covers Access.PrivateDeclarationsCompile
	 * @Inputs none
	 * @Return nothing
	 */
	private void SecretFunc()
	{
		SecretVal = 10;
	}

	/**
	 * Observe that a constructed instance is a live object.
	 *
	 * @Kind Observe
	 * @Covers Access.PrivateDeclarationsCompile
	 * @Inputs this instance
	 * @Return true when the handle is not null
	 * @Boundary empty construct
	 */
	UFUNCTION()
	bool EmptyConstruct()
	{
		return this != nullptr;
	}

	/**
	 * Observe that this instance and another instance are distinct objects.
	 *
	 * @Kind Observe
	 * @Covers Access.PrivateDeclarationsCompile
	 * @Inputs a second actor
	 * @Return true when the two handles are different objects
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AActorPrivDecl Second)
	{
		if (Second is null)
		{
			throw("PrivateDeclarationsCompile setup: required Second is null");
		}
		return this != Second;
	}
}
/** @end */
