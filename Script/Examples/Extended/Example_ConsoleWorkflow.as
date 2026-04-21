/**
 * Console variable and global constant workflow example.
 *
 * AngelScript supports const global variables for cross-module shared state.
 * Mutable global variables are not supported — use class properties or
 * subsystem state instead for runtime-mutable data.
 */

/* Namespace-scoped const global variables.
 * These are accessible from any script module that imports this file. */
namespace ExampleGlobals
{
	const int DefaultStartValue = 100;
	const FString WelcomeMessage = "Hello from AngelScript";
}

/**
 * An actor that demonstrates using global constants
 * and managing mutable state through class properties.
 */
class AExampleConsoleWorkflowActor : AActor
{
	UPROPERTY(Category = "State")
	int Counter = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Counter = ExampleGlobals::DefaultStartValue;
		Log(f"Counter initialized to: {Counter}");
		Log(f"Welcome: {ExampleGlobals::WelcomeMessage}");
	}

	/**
	 * Increment the counter. Can be called from Blueprint.
	 */
	UFUNCTION(Category = "Console Workflow")
	void IncrementCounter()
	{
		Counter += 1;
		Print(f"Counter incremented to {Counter}");
	}

	/**
	 * Reset the counter.
	 */
	UFUNCTION(Category = "Console Workflow")
	void ResetCounter()
	{
		Counter = 0;
		Print("Counter reset to 0");
	}
};
