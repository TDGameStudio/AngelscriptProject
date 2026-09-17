/**
 * @version v1
 * @summary A derived class reading an inherited private member is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A derived class reading an inherited private member is rejected.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassPrivateBaseObject : UObject
{
	private int BaseSecret = 17;
}

UCLASS()
class UCoverageUClassPrivateDerivedObject : UCoverageUClassPrivateBaseObject
{
	/**
	 * Illegal read of the base class private member.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.Access
	 * @Inputs BaseSecret inherited as private
	 * @Return does not compile
	 */
	int ReadBaseSecret()
	{
		return BaseSecret;
	}
}
/** @end */
