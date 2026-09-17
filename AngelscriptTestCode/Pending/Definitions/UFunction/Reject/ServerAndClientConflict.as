/**
 * @version v1
 * @summary Server and Client may not appear on the same UFUNCTION. Those specifiers select exclusive RPC endpoints, so combining them is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Server and Client may not appear on the same UFUNCTION. Those specifiers select exclusive RPC endpoints, so combining them is illegal. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncSvrCliActor : AActor
{
	/**
	 * Illegal UFUNCTION that mixes Server and Client.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(Server, Client)
	 * @Return does not compile
	 */
	UFUNCTION(Server, Client)
	void Foo()
	{
	}
}
/** @end */
