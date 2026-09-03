/**
 * Using an FText as a TMap key is rejected: text has no hash function in this
 * fork. This file is the illegal program itself; do not key on ToString(),
 * since the missing hash is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FTextMapKeyRejected
 * @Harness CompileReject
 * @Tag Language.Literals.FTextMapKeyRejected
 * @Kind CompileReject
 * @Covers Literals.FText
 * @Inputs TMap<FText, int> Values; Values.Add(FText::FromString("Key"), 1)
 * @Return does not compile; diagnostic "Key type does not have a hash function defined"
 * @Provenance C++: AngelscriptCoverageFStringPropertyTests.cpp::FTextContainerHashBoundariesRemainUnsupported block 1
 * @Provenance sha256=6234e1e68216ab64a3f52a2a04b0ff5738bfa90060b1a3935ead9c289e9b1a75; lines 1435-1442.
 * @Provenance Expected diagnostic: "Key type does not have a hash function defined".
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempt to key a map on FText, which lacks a hash function.
 */
int UseTextMapKey()
{
	TMap<FText, int> Values;
	Values.Add(FText::FromString("Key"), 1);
	return Values.Num();
}
