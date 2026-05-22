/**
 * This is an example for an ACharacter that takes input, which can be used as
 * a baseclass for your main game player / pawn.
 */
class AExampleInputCharacter : ACharacter
{
    // An input component that we will set up to handle input from the player
    // that is possessing this pawn.
    UPROPERTY()
    UInputComponent ScriptInputComponent;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Don't forget to call to parent if you override BeginPlay from blueprint!
    }

    UFUNCTION()
    void OnJumpPressed(FKey Key)
    {
        Print("Jump was pressed!", Duration=5.0);
    }

    UFUNCTION()
    void OnJumpReleased(FKey Key)
    {
        Print("Jump was released!", Duration=5.0);
    }

    UFUNCTION()
    void OnMoveForwardAxisChanged(float32 AxisValue)
    {
        Print("Move Forward Axis Value: "+AxisValue, Duration=0.0);
    }

    UFUNCTION()
    void OnMoveRightAxisChanged(float32 AxisValue)
    {
        Print("Move Right Axis Value: "+AxisValue, Duration=0.0);
    }

    UFUNCTION()
    void OnShiftPressed(FKey Key)
    {
        Print("Shift key pressed!", Duration=5.0);
    }

    UFUNCTION()
    void OnKeyPressed(FKey Key)
    {
        Print("Key Pressed: " + Key.GetKeyName(), Duration=5.0);
    }
};
