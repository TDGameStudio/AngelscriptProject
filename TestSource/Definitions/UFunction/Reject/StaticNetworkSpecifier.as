/**
 * A static UFUNCTION cannot use network specifiers. Server on a global
 * function is illegal. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.StaticNetworkSpecifier
 * @Harness CompileReject
 * @Tag Definitions.UFunction.StaticNetworkSpecifier
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(Server) void StaticServerAction()
 * @Return does not compile; diagnostic "Static UFUNCTION()s cannot use network specifiers"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: static UFUNCTION cannot use network specifiers.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case static network specifier.
 * @Provenance Expected compile failure: "Static UFUNCTION()s cannot use network specifiers"
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
