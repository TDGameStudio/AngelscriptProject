/**
 * @version v1
 * @summary Reading a protected UCLASS member from a free function is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Reading a protected UCLASS member from a free function is rejected.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassProtectedAccessObject : UObject
{
	protected int ProtectedValue = 23;
}

/**
 * Illegal read of a protected member from a free function.
 *
 * @Kind CompileReject
 * @Covers UClass.Access
 * @Param Object Host whose ProtectedValue is protected
 * @Inputs Object.ProtectedValue
 * @Return does not compile
 */
int ReadProtectedAccess(UCoverageUClassProtectedAccessObject Object)
{
	return Object.ProtectedValue;
}
/** @end */
