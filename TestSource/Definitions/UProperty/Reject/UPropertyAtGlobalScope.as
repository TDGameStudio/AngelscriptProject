/**
 * A UPROPERTY at global scope is rejected. This file is the illegal program
 * itself; do not wrap the variable in a UCLASS.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UPropertyAtGlobalScope
 * @Harness CompileReject
 * @Tag Definitions.UProperty.UPropertyAtGlobalScope
 * @Kind CompileReject
 * @Covers UProperty.UPropertyAtGlobalScope
 * @Inputs UPROPERTY() int GlobalVar at file scope
 * @Return does not compile; diagnostic "UPROPERTY at global scope should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: UPROPERTY at global scope.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_GlobalScope; lines 243-245;
 * @Provenance sha256=256c73781ffc837923bf85556761fab857fec4ac5609c028d8332b1cfc68d339.
 * @Provenance Expected diagnostic: UPROPERTY at global scope should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

UPROPERTY() int GlobalVar = 0;
