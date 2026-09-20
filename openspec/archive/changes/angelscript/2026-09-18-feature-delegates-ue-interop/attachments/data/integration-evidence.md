# Integration evidence — 4.1

Editor prefix: `Angelscript.UnitTest.NativeEngine.Compile.DelegateLifecycle`.
Editor run: `5d05f5118c7749dcb812ab5261629705` Total 3 Succeeded 3.

Cook route recorded by 1.1 (`planning-contracts.md`):

```powershell
Invoke-Harness -Command ue.commandlet -Context $context -Parameters @{
    Commandlet = 'Cook'
    ExtraArguments = @('-TargetPlatform=Windows')
    TimeoutMs = 3600000
}
```

`PlanOnly` inspects the request. Run `9264c927fa014ed3935bf11984312fff`
Succeeded: Commandlet `Cook`, `-TargetPlatform=Windows`, TimeoutMs 3600000,
ExecutionPath `U:\`, mappingState Absent. No cook process started.

A full Windows cook is omitted until
`Plugins/Angelscript/Content/Tests/Delegates/` holds a cooked-load asset; the
editor half uses a transient Blueprint created after reflection publication.
