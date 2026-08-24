// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: empty return expression.
// C++: AngelscriptCompilerEventsTests.cpp::FailedCompileEmitsPairedEndEvent
// sha256=584d8a3986162cc68ca19d062e81bda2db3929b7042de671e030cc3f6d29175c; lines 580-585.
// Expected diagnostic: invalid script / missing return expression so the module
// does not compile (bCompiled false, ECompileResult::Error). Isolate this
// failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

int Entry()
{
	return ;
}
