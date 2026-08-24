// Theme: Language.Preprocessor. Positive provider for USESHARED=true case.
// C++: AngelscriptPreprocessorImportTests.cpp::ImportInsideConditionalBranch block 3
// sha256=9a0e00b7b76c3c4f72b624f9dd5a7d1615a85ffd2097847b9adb2eb8b412bcc4; lines 640-645.
// Oracle: SharedValue() == 42; C++ injects USESHARED true on the paired consumer.
// Extra: repeat stays 42. DefaultSafe.

int SharedValue()
{
	return 42;
}

bool Observe_SharedValue_Nominal()
{
	return SharedValue() == 42;
}

bool Observe_SharedValue_RepeatBoundary()
{
	return SharedValue() == 42 && SharedValue() == 42;
}
