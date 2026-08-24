// Theme: Language.Preprocessor. Positive fan-in consumer imports A, B, and C.
// C++: AngelscriptPreprocessorImportTests.cpp::WideImportGraph block 5
// sha256=02c4cb725bc1bbc5d790a74a561f41cfa834b49155c91597249cdd2af2507dd4; lines 763-771.
// Oracle: Entry() == ValueA() + ValueB() + ValueC() == 11+21+31 == 63. Consumer is last in order.
// Extra: each arm is independent of the others. DefaultSafe.

import Tests.Preprocessor.WideGraph.A;
import Tests.Preprocessor.WideGraph.B;
import Tests.Preprocessor.WideGraph.C;
int Entry()
{
	return ValueA() + ValueB() + ValueC();
}

bool Observe_Entry_Nominal()
{
	return Entry() == 63;
}

bool Observe_Entry_ArmBoundary()
{
	return ValueA() == 11 && ValueB() == 21 && ValueC() == 31;
}
