/**
 * @version v1
 * @summary Reading a private UCLASS member from a free function is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Reading a private UCLASS member from a free function is rejected.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassPrivateAccessObject : UObject
{
	private int SecretValue = 42;
}

/**
 * Illegal read of a private member from a free function.
 *
 * @Kind CompileReject
 * @Covers UClass.Access
 * @Param Object Host whose SecretValue is private
 * @Inputs Object.SecretValue
 * @Return does not compile
 */
int ReadPrivateAccess(UCoverageUClassPrivateAccessObject Object)
{
	return Object.SecretValue;
}
/** @end */
