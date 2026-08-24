// Theme: Gameplay.FRotator. Positive Pitch/Yaw/Roll getter and setter oracles.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorMemberAccess
// Oracle: GetPitch 10; GetYaw 20; GetRoll 30;
// SetPitch (45,20,30); SetYaw (10,90,30); SetRoll (10,20,180).
// Extra: default 0/0/0; copy independence of SetPitch. DefaultSafe.

float GetPitch()
{
	FRotator r = FRotator(10, 20, 30);
	return r.Pitch;
}

float GetYaw()
{
	FRotator r = FRotator(10, 20, 30);
	return r.Yaw;
}

float GetRoll()
{
	FRotator r = FRotator(10, 20, 30);
	return r.Roll;
}

FRotator SetPitch()
{
	FRotator r = FRotator(10, 20, 30);
	r.Pitch = 45;
	return r;
}

FRotator SetYaw()
{
	FRotator r = FRotator(10, 20, 30);
	r.Yaw = 90;
	return r;
}

FRotator SetRoll()
{
	FRotator r = FRotator(10, 20, 30);
	r.Roll = 180;
	return r;
}

bool Observe_Getters_Nominal()
{
	return GetPitch() == 10.0 && GetYaw() == 20.0 && GetRoll() == 30.0;
}

bool Observe_SetPitch()
{
	return SetPitch() == FRotator(45, 20, 30);
}

bool Observe_SetYaw()
{
	return SetYaw() == FRotator(10, 90, 30);
}

bool Observe_SetRoll()
{
	return SetRoll() == FRotator(10, 20, 180);
}

bool Observe_MemberAccess_DefaultEmpty()
{
	FRotator Empty = FRotator();
	return Empty.Pitch == 0.0 && Empty.Yaw == 0.0 && Empty.Roll == 0.0;
}

bool Observe_SetPitch_CopyIndependence()
{
	FRotator Source = FRotator(10, 20, 30);
	FRotator Mutated = Source;
	Mutated.Pitch = 45;
	return Source == FRotator(10, 20, 30) && Mutated.Pitch == 45.0;
}
