/**
 * @version v1
 * @summary Server and NetMulticast may not appear on the same UFUNCTION. Those specifiers select exclusive RPC endpoints, so combining them is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Server and NetMulticast may not appear on the same UFUNCTION. Those specifiers select exclusive RPC endpoints, so combining them is illegal. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncSvrMCActor : AActor
{
	/**
	 * Illegal UFUNCTION that mixes Server and NetMulticast.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(Server, NetMulticast)
	 * @Return does not compile
	 */
	UFUNCTION(Server, NetMulticast)
	void Foo()
	{
	}
}
/** @end */
