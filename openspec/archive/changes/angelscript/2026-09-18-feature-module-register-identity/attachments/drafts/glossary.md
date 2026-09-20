# Vocabulary

Source: local draft `angelscript/module-identity-attach` scope `runtime-identity` `glossary.md`. Approval: R7 / N1 / N2.

| Term | Chosen | Rejected | Reason | Round |
|---|---|---|---|---|
| Change | `angelscript/feature-module-register-identity` | `feature-sdk-module-lookup`, `feature-classgen-module-shell` | Register-time identity plus SDK lookup | N1 |
| Lookup | `asIScriptEngine::GetModule(const char* name) const` | `GetModule(name, asEGMFlags)` | Lookup only; flag enum already deleted | N2 |
| Count | `GetModuleCount` / `GetModuleByIndex` | none | Same pair as the old SDK | N2 |
