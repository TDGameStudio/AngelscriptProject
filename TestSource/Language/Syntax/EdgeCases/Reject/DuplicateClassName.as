/**
 * Declaring the same class name twice is rejected. This file is the illegal
 * program itself; do not rename the second class, since the collision is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DuplicateClassName
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.DuplicateClassName
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs two class declarations sharing the name ADupActor
 * @Return does not compile; diagnostic "ADupActor is declared twice"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 3 AssertFailsToCompile.
 * @Provenance sha256=2c5730f54de076f867af1ffa0fa18b61162d2e3bc256ac70d94852012ba17ccb; lines 145-148.
 * @Provenance Expected diagnostic: ADupActor is declared twice.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

class ADupActor : AActor
{
}

class ADupActor : AActor
{
}
