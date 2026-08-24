// Theme: Language.Preprocessor. Positive fixture: PostProcessCode replaces CACHE_EXTERNAL_VALUE with 7.
// C++: AngelscriptPreprocessorGeneratedSourceProvenanceTests.cpp::PostProcessCodeReplacementKeepsTrailingGeneratedRangesInBounds
// sha256=61f2f8da3b07524de65c0ca8f9551817322edef1e00a21345f98a8f6669ee8a8; lines 156-166.
// Oracle after hook: GetCacheAnswer() == 7 and processed code contains "return 7;".
// Extra: default FCachePayload.Count is 0. DefaultSafe.

class FCachePayload
{
	int Count;
}

int GetCacheAnswer()
{
	return CACHE_EXTERNAL_VALUE;
}

bool Observe_GetCacheAnswer_Nominal()
{
	return GetCacheAnswer() == 7;
}

bool Observe_FCachePayload_DefaultEmpty()
{
	FCachePayload Payload;
	return Payload.Count == 0;
}

bool Observe_FCachePayload_InstanceIndependence()
{
	FCachePayload First;
	FCachePayload Second;
	First.Count = 7;
	return First.Count == 7 && Second.Count == 0 && GetCacheAnswer() == 7;
}
