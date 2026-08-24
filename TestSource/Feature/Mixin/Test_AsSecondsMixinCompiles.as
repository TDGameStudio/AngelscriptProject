// Theme: Feature.Mixin. Positive FQualifiedFrameTime.AsSeconds mixin binding.
// C++: AngelscriptFrameTimeFunctionLibraryTests.cpp::AsSecondsMixinCompiles
// ExpectGlobalInt AsSeconds_Compiles() == 1.
// Extra: default AsSeconds is 0.0; two default times match.
// DefaultSafe. Source owns locals.

int AsSeconds_Compiles()
{
	FQualifiedFrameTime DefaultTime;
	// Just call AsSeconds to verify the mixin binding compiles and links.
	DefaultTime.AsSeconds();
	return 1;
}

int Observe_AsSeconds_Compiles_Nominal()
{
	return AsSeconds_Compiles();
}

double Observe_AsSeconds_DefaultZero()
{
	FQualifiedFrameTime DefaultTime;
	return DefaultTime.AsSeconds();
}

bool Observe_AsSeconds_CopyIndependence()
{
	FQualifiedFrameTime First;
	FQualifiedFrameTime Second;
	return First.AsSeconds() == 0.0 && Second.AsSeconds() == 0.0;
}
