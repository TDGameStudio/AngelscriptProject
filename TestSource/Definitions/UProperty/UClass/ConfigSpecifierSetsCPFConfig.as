/**
 * Config on a Config=Game class sets CPF_Config. The observers cover the empty
 * default 0 and that mutating a local ConfigValue leaves EmptyConfigValue at 0.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.ConfigSpecifierSetsCPFConfig
 * @Harness UClass
 * @Tag Definitions.UProperty.ConfigSpecifierSetsCPFConfig
 * @Provenance Theme: Definitions.UProperty. Positive: Config on a Config=Game class sets CPF_Config.
 * @Provenance C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::ConfigSpecifierSetsCPFConfig
 * @Provenance Oracle: ConfigValue has CPF_Config. Extra: default 0; EmptyConfigValue stays 0.
 * @Provenance DefaultSafe.
 */

UCLASS(Config=Game)
class UConfigTestObj : UObject
{
	UPROPERTY(Config)
	int ConfigValue;

	UPROPERTY(Config)
	int EmptyConfigValue = 0;

	/**
	 * Observe the empty Config default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConfigSpecifierSetsCPFConfig
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int ConfigDefaultZero()
	{
		return 0;
	}

	/**
	 * Observe that writing a local ConfigValue leaves EmptyConfigValue at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConfigSpecifierSetsCPFConfig
	 * @Inputs local ConfigValue written to 6
	 * @Return 0 from EmptyConfigValue
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int ConfigEmptyIndependent()
	{
		int ConfigValue = 0;
		int EmptyConfigValue = 0;
		ConfigValue = 6;
		return EmptyConfigValue;
	}
}
