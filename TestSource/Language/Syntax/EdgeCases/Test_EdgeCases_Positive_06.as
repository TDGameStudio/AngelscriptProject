// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: global plus function.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 6 was AssertCompiles
// but is #if 0 (feature-not-supported: global variable with function combo).
// sha256=d6a632564d08bde402d625de7362af3108302ce12c8d9f789373b73559005df3; lines 261-265.
// Expected diagnostic: compiling GlobalCounter together with Increment fails.
// Isolate this program. Do not add declarations that would compile it away.

int GlobalCounter = 0;

void Increment()
{
	++GlobalCounter;
}
