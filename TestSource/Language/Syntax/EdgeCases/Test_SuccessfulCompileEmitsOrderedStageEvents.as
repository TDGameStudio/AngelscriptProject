// Theme: Language.Syntax.EdgeCases. Positive compile-stage payload.
// C++: AngelscriptCompilerEventsTests.cpp::SuccessfulCompileEmitsOrderedStageEvents
// sha256=91af3870fea0438c187814f79df7de716865fcfb3cc28f7fcff14051e106f8a9; lines 399-409.
// Oracle: Entry() returns 17. Extra: FCompilationEventsStagesType.Value default
// is 0; a copy does not alias the original. DefaultSafe.

class FCompilationEventsStagesType
{
	int Value;
}

int Entry()
{
	return 17;
}

bool Observe_StageEvents_Nominal()
{
	return Entry() == 17;
}

bool Observe_StageEvents_TypeDefaultEmpty()
{
	FCompilationEventsStagesType Stages;
	return Stages.Value == 0;
}

bool Observe_StageEvents_CopyIndependence()
{
	FCompilationEventsStagesType Original;
	Original.Value = 17;
	FCompilationEventsStagesType Copied = Original;
	Copied.Value = 0;
	return Original.Value == 17 && Copied.Value == 0;
}
