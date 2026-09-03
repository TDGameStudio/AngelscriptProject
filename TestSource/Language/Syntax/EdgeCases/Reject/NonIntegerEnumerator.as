/**
 * Initializing an enumerator from a non-integer value is rejected. This file is
 * the illegal program itself; do not replace the string with an integer, since
 * the type mismatch is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.NonIntegerEnumerator
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.NonIntegerEnumerator
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an enumerator initialized from a string
 * @Return does not compile; diagnostic "enumerator cannot be initialized from a string"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 3 AssertFailsToCompile.
 * @Provenance sha256=f434fc5c56008c6419b3ae28e0474851c4876463a21c593ab15b7c2ff6741ec7; lines 392-394.
 * @Provenance Expected diagnostic: enumerator Value1 cannot be initialized from "hello".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

enum EEnumBadVal
{
	Value1 = "hello"
}
