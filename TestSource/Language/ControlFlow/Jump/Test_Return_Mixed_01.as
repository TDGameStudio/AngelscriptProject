// Theme: Language.ControlFlow.Jump. Positive compile oracle from Return_Mixed.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
// sha256=44b53a8662227b736f6ea9a7bf927d98d0f95db7076304279badec23ce29acb5; lines 531-533.
// Oracle: void return compiles; Test() completes without a value.
// Extra: calling Test twice remains a completed void return.
// DefaultSafe. Source owns locals.

void Test()
{
	return;
}

int Observe_ReturnVoid_AfterCall()
{
	Test();
	Test();
	return 0;
}
