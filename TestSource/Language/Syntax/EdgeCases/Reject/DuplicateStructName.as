/**
 * Declaring the same struct name twice is rejected. This file is the illegal
 * program itself; do not rename the second struct, since the collision is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DuplicateStructName
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.DuplicateStructName
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs two struct declarations named FDup
 * @Return does not compile; diagnostic "FDup is declared twice"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Negative block 2 AssertFailsToCompile.
 * @Provenance sha256=37176c66bcfe4b62f9a287735b1ebea0c4984748fb1770322c124307da041644; lines 284-287.
 * @Provenance Expected diagnostic: FDup is declared twice.
 * @Provenance DiagnosticOnly. Do not rename the second struct.
 */

/**
 * The first declaration of the duplicated struct.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FDup
{
	int X;
}

/**
 * The second declaration of the same struct name.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FDup
{
	int Y;
}
