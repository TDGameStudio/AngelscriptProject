/**
 * @version v1
 * @summary A static UFUNCTION cannot use network specifiers. Server on a global function is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A static UFUNCTION cannot use network specifiers. Server on a global function is illegal. This file is the illegal program itself.
 * @topic Negative
 */
/**
 * Illegal static UFUNCTION using a Server specifier.
 *
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(Server) void StaticServerAction()
 * @Return does not compile
 */
UFUNCTION(Server)
void StaticServerAction()
{
}
/** @end */
