// Theme: Language.Syntax.EdgeCases. Positive float/double &out parameters.
// C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionParametersOut
// sha256=2509cb9ac431fa1b1829d8112b7dce7f294663a429bf612849598bff65f5c33a; lines 149-171.
// Oracle: WriteFloat copies 3.14159; WriteDouble copies 2.71828;
// WriteFloatPair(10) A=11 B=12; WriteDoublePair(20) A=21 B=22.
// Extra: pair seed 0 writes 1 then 2 (order preserved). DefaultSafe. &out overwrites caller storage.

void WriteFloat(float&out X)
{
	X = 3.14159f;
}

void WriteDouble(double&out X)
{
	X = 2.71828;
}

void WriteFloatPair(float Seed, float&out A, float&out B)
{
	A = Seed + 1.0f;
	B = Seed + 2.0f;
}

void WriteDoublePair(double Seed, double&out A, double&out B)
{
	A = Seed + 1.0;
	B = Seed + 2.0;
}

bool Observe_WriteFloat_Nominal()
{
	float F = 0.0f;
	double D = 0.0;
	WriteFloat(F);
	WriteDouble(D);
	float FA = 0.0f;
	float FB = 0.0f;
	double DA = 0.0;
	double DB = 0.0;
	WriteFloatPair(10.0f, FA, FB);
	WriteDoublePair(20.0, DA, DB);
	return Math::IsNearlyEqual(F, 3.14159, 0.00001) && Math::IsNearlyEqual(D, 2.71828, 0.00001) && Math::IsNearlyEqual(FA, 11.0, 0.001) && Math::IsNearlyEqual(FB, 12.0, 0.001) && Math::IsNearlyEqual(DA, 21.0, 0.001) && Math::IsNearlyEqual(DB, 22.0, 0.001);
}

bool Observe_WriteFloatPair_ZeroSeed()
{
	float A = 99.0f;
	float B = 99.0f;
	WriteFloatPair(0.0f, A, B);
	return Math::IsNearlyEqual(A, 1.0, 0.001) && Math::IsNearlyEqual(B, 2.0, 0.001);
}

bool Observe_WriteFloat_OverwritesPrior()
{
	float X = -1.0f;
	WriteFloat(X);
	return Math::IsNearlyEqual(X, 3.14159, 0.00001);
}
