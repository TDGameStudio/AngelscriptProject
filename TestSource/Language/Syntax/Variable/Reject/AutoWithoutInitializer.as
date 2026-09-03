/**
 * An auto local has no type of its own, so declaring one without an initializer
 * is rejected. This file is the illegal program itself; do not supply an
 * initializer, since the missing one is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.AutoWithoutInitializer
 * @Harness CompileReject
 * @Tag Language.Syntax.Variable.AutoWithoutInitializer
 * @Kind CompileReject
 * @Covers Syntax.Variable
 * @Inputs an auto local with no initializer
 * @Return does not compile; diagnostic "Auto without initializer"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 3 AssertFailsToCompile.
 * @Provenance sha256=606bdf5bc04e492e906c0fc693d08d7c73544f0990127addcd88c755081fc537; lines 583-585.
 * @Provenance Expected diagnostic: "Auto without initializer". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to declare an auto local without an initializer.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	auto X;
}
