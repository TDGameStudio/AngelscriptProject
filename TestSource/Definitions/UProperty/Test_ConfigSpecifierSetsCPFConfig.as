// Theme: Definitions.UProperty. Positive: Config on a Config=Game class sets CPF_Config.
// C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::ConfigSpecifierSetsCPFConfig
// Oracle: ConfigValue has CPF_Config. Extra: default 0; EmptyConfigValue stays 0.
// DefaultSafe.

UCLASS(Config=Game)
class UConfigTestObj : UObject
{
	UPROPERTY(Config)
	int ConfigValue;

	UPROPERTY(Config)
	int EmptyConfigValue = 0;
}

int Observe_Config_DefaultZero()
{
	return 0;
}

int Observe_Config_EmptyIndependent()
{
	int ConfigValue = 0;
	int EmptyConfigValue = 0;
	ConfigValue = 6;
	return EmptyConfigValue;
}
