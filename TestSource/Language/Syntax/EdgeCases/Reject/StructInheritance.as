/**
 * Deriving one struct from another is rejected: structs may not inherit. This
 * file is the illegal program itself; do not flatten FChild into FBase, since the
 * inheritance is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.StructInheritance
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.StructInheritance
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a struct declaring a base struct
 * @Return does not compile; diagnostic "Structs may not inherit from anything"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Negative block 5 AssertFailsToCompile.
 * @Provenance sha256=4f7210fd6b073ca047393be072d7e63f95b16dcc7c1c53d8eb7204d0d61871f9; lines 314-317.
 * @Provenance Expected diagnostic: Error parsing script struct FChild. Structs may not inherit from anything.
 * @Provenance DiagnosticOnly. Do not flatten FChild into FBase.
 */

/**
 * The base struct of the illegal derivation.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FBase
{
	int X;
}

/**
 * The struct whose derivation from FBase is illegal.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FChild : FBase
{
	int Y;
}
