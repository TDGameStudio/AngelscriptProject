/**
 * A UFUNCTION annotation must close its parenthesis list. UFUNCTION( without
 * a matching ) is illegal and the method that follows cannot be parsed. This
 * file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.MissingClosingParenthesis
 * @Harness CompileReject
 * @Tag Definitions.UFunction.MissingClosingParenthesis
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION( void Foo()
 * @Return does not compile; diagnostic "Missing closing parenthesis should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: missing UFUNCTION closing parenthesis.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 5 AssertFailsToCompile.
 * @Provenance sha256=9160ebec365ad678f10d3f7b96df40bee807ecddb9d5e4b945153e77bf5d4a7e; lines 243-248.
 * @Provenance Expected compile failure: "Missing closing parenthesis should fail".
 * @Provenance Keep the unclosed UFUNCTION( so the program stays failing. DiagnosticOnly.
 */

class AUFuncMisParenActor : AActor
{
	UFUNCTION( void Foo() { }
}
