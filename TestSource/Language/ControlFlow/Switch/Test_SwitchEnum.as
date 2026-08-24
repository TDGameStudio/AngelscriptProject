// Theme: Language.ControlFlow.Switch. Positive value oracle from SwitchEnum.
// C++: AngelscriptCoverageConditionalTests.cpp::SwitchEnum
// sha256=20c3a1889e73ef8ee905f1a800decfa12273a87dec1768f4fd51ab2aa9d64d0f; lines 568-616.
// Oracle: SwitchOnWorldStatic 1; EnumSwitchCompleteAllCases 6.
// Extra: remaining collision channels; unmatched enum default 0; ROLE_None is 0.
// DefaultSafe. Source owns locals.

int SwitchOnEnum(ECollisionChannel Channel)
{
	switch (Channel)
	{
		case ECollisionChannel::ECC_WorldStatic:
			return 1;
		case ECollisionChannel::ECC_WorldDynamic:
			return 2;
		case ECollisionChannel::ECC_Pawn:
			return 3;
		case ECollisionChannel::ECC_Visibility:
			return 4;
		default:
			return 0;
	}
}

int EnumSwitchComplete(ENetRole Role)
{
	switch (Role)
	{
		case ENetRole::ROLE_None:
			return 0;
		case ENetRole::ROLE_SimulatedProxy:
			return 1;
		case ENetRole::ROLE_AutonomousProxy:
			return 2;
		case ENetRole::ROLE_Authority:
			return 3;
	}
	return -1;
}

int SwitchOnWorldStatic()
{
	return SwitchOnEnum(ECollisionChannel::ECC_WorldStatic);
}

int EnumSwitchCompleteAllCases()
{
	return EnumSwitchComplete(ENetRole::ROLE_None)
		+ EnumSwitchComplete(ENetRole::ROLE_SimulatedProxy)
		+ EnumSwitchComplete(ENetRole::ROLE_AutonomousProxy)
		+ EnumSwitchComplete(ENetRole::ROLE_Authority);
}

bool Observe_SwitchEnum_Nominal()
{
	return SwitchOnWorldStatic() == 1 && EnumSwitchCompleteAllCases() == 6;
}

bool Observe_SwitchEnum_RemainingCases()
{
	return SwitchOnEnum(ECollisionChannel::ECC_WorldDynamic) == 2
		&& SwitchOnEnum(ECollisionChannel::ECC_Pawn) == 3
		&& SwitchOnEnum(ECollisionChannel::ECC_Visibility) == 4;
}

bool Observe_SwitchEnum_DefaultBoundary()
{
	return SwitchOnEnum(ECollisionChannel::ECC_Camera) == 0
		&& EnumSwitchComplete(ENetRole::ROLE_None) == 0
		&& EnumSwitchComplete(ENetRole::ROLE_Authority) == 3;
}
