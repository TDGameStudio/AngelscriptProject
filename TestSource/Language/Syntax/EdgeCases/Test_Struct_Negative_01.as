// Theme: Language.Syntax.EdgeCases. C++ originally expected unnamed struct failure.
// Live C++: Struct_Negative block 1 is #if 0 (structural-validation-absent);
// anonymous struct { int X; } compiles. CSV NegativeDiagnostic is not a compile-fail.
// sha256=11dcab82c6f96ea7431886e2e9c87565273bb066ec3829a1318999575c8eef6b; lines 277-279.
// Oracle: the unnamed struct compiles. It has no type name to construct.
// Extra: member type int empty default is 0; boundary write is 1.
// DefaultSafe value oracle.

struct
{
	int X;
}

int Observe_AnonymousMemberType_EmptyDefault()
{
	int X = 0;
	return X;
}

int Observe_AnonymousMemberType_WriteBoundary()
{
	int X = 1;
	return X;
}
