/**
 * An identifier may not begin with a digit, so such a local is rejected. This
 * file is the illegal program itself; do not rename the variable, since the
 * malformed name is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.IdentifierStartingWithDigit
 * @Harness CompileReject
 * @Tag Language.Syntax.Variable.IdentifierStartingWithDigit
 * @Kind CompileReject
 * @Covers Syntax.Variable
 * @Inputs a local named 123abc
 * @Return does not compile; diagnostic "Name starting with number"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 5 AssertFailsToCompile.
 * @Provenance sha256=ca11a4a38b705ecaad31be299a29ba1671ae5fd1e84af2089d1691ef454ba907; lines 598-600.
 * @Provenance Expected diagnostic: "Name starting with number". Isolate this failing program.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to declare a local whose name starts with a digit.
 *
 * @Covers Syntax.Variable
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	int 123abc = 0;
}
