/**
 * Core math functions live inside the `Math::` namespace.
 *
 * This lists just a few examples of commonly used math functions.
 */
void ExecuteExampleMath()
{
	float AbsoluteValue = Math::Abs(-1.0);
	check(AbsoluteValue == 1.0);

	float MinimumValue = Math::Min(0.1, 1.0);
	check(MinimumValue == 0.1);

	float MaximumValue = Math::Max(0.1, 1.0);
	check(MaximumValue == 1.0);

	float ClampedValue = Math::Clamp(X = 2.0, Min = 0.0, Max = 0.5);
	check(ClampedValue == 0.5);

	// Create a sine wave based on the current game time
	float WaveValue = Math::Sin(1.0f * 2.0);

	// Generates a random float between two values
	float RandomValue = Math::RandRange(0.0, 10.0);
}
