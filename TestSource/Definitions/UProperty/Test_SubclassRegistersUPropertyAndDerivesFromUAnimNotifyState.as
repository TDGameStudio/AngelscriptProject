// Theme: Definitions.UProperty. Positive: script UAnimNotifyState subclass registers UPROPERTY defaults.
// C++: class is child of UAnimNotifyState; WindowStrength FDoubleProperty; WindowPriority FIntProperty;
// bFiresOnTick CDO true. Extra: false tick flag and 0 strength are independent of the defaults.
// DefaultSafe.

UCLASS()
class UFunctionalAnimNotifyState_ScriptWindow : UAnimNotifyState
{
	UPROPERTY(EditAnywhere)
	float WindowStrength = 0.5;

	UPROPERTY(EditAnywhere)
	int32 WindowPriority = 3;

	UPROPERTY(EditAnywhere)
	bool bFiresOnTick = true;
}

float Observe_AnimNotifyState_EmptyStrengthBoundary()
{
	return 0.0;
}

bool Observe_AnimNotifyState_FalseTickIndependent()
{
	bool bFiresOnTick = true;
	bool EmptyTick = false;
	return bFiresOnTick && !EmptyTick;
}
