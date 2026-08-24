// Theme: Language.Syntax.EdgeCases. Positive builder integration executes produced bytecode.
// C++: AngelscriptCompilerBuilderIntegrationTests.cpp::RuntimeCompileRunsObservableBuilderStages
// sha256=129f8e4130420656298b62bc057a0cd19a67ef30880912c8da2e1c9575428c00; lines 93-103.
// Oracle: Entry() == BuilderIntegrationAdd(2) == 42.
// Extra: Delta 0 returns 40. DefaultSafe.

int BuilderIntegrationAdd(int Delta)
{
	return 40 + Delta;
}

int Entry()
{
	return BuilderIntegrationAdd(2);
}

bool Observe_Entry_Nominal()
{
	return Entry() == 42 && BuilderIntegrationAdd(2) == 42;
}

bool Observe_BuilderIntegrationAdd_ZeroBoundary()
{
	return BuilderIntegrationAdd(0) == 40;
}

bool Observe_BuilderIntegrationAdd_NegativeBoundary()
{
	return BuilderIntegrationAdd(-40) == 0;
}
