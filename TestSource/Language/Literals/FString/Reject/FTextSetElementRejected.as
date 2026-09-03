/**
 * Using an FText as a TSet element is rejected: text has no hash function in
 * this fork. This file is the illegal program itself; do not store ToString(),
 * since the missing hash is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FTextSetElementRejected
 * @Harness CompileReject
 * @Tag Language.Literals.FTextSetElementRejected
 * @Kind CompileReject
 * @Covers Literals.FText
 * @Inputs TSet<FText> Values; Values.Add(FText::FromString("Value"))
 * @Return does not compile; diagnostic "Key type does not have a hash function defined"
 * @Provenance C++: AngelscriptCoverageFStringPropertyTests.cpp::FTextContainerHashBoundariesRemainUnsupported block 2
 * @Provenance sha256=85487d026747093f642f8b6e6d30487fe8c4019b7147079b98fa9dbb8330874e; lines 1450-1457.
 * @Provenance Expected diagnostic: "Key type does not have a hash function defined".
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to store FText in a set, which lacks a hash function.
 */
int UseTextSetElement()
{
	TSet<FText> Values;
	Values.Add(FText::FromString("Value"));
	return Values.Num();
}
