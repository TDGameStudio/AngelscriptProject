# Pending Language wave

One concern per file. Auto, Class, Inheritance, Destructors, Typedef, and Mixin are adapted into chapter FileTags such as `Language/Auto/InferFromLiteral`, `Language/Class/Constructor`, `Language/Inheritance/Override`, `Language/Destructors/ClassDestructor`, `Language/Typedef/Alias`, and `Language/Mixin/FunctionMixin` (plus CompileFail siblings). Class casts stay under the admitted `Language/Casting/ClassHandleCast`; Properties and leftover Const remain Pending.

| FileTag | Disposition | Anchors |
| --- | --- | --- |
| `Language/Class/ThisKeyword` | adapted | `Language/Class/This` |
| `Language/Class/Constructor` | adapted | `Language/Class/Constructor` |
| `Language/Class/EmptyBody` | adapted | `Language/Class/Declaration` |
| `Language/Class/DuplicateName` | adapted | `Language/Class/DeclarationCompileFail` |
| `Language/Class/Unnamed` | adapted | `Language/Class/DeclarationCompileFail` |
| `Language/Class/MissingBody` | adapted | `Language/Class/DeclarationCompileFail` |
| `Language/Class/UnknownMemberType` | adapted | `Language/Class/FieldsCompileFail` |
| `Language/Inheritance/MethodOverride` | adapted | `Language/Inheritance/Override` |
| `Language/Inheritance/SuperCall` | adapted | `Language/Inheritance/Super` |
| `Language/Inheritance/FinalClass` | adapted | `Language/Inheritance/Final` |
| `Language/Inheritance/Nested` | adapted | `Language/Inheritance/Nested` |
| `Language/Inheritance/DerivedAsBaseHandle` | adapted | `Language/Inheritance/Extends` |
| `Language/Inheritance/SelfBase` | adapted | `Language/Inheritance/ExtendsCompileFail` |
| `Language/Inheritance/UnknownBase` | adapted | `Language/Inheritance/ExtendsCompileFail` |
| `Language/Destructors/ClassDestructor` | adapted | `Language/Destructors/ClassDestructor` |
| `Language/Destructors/StructDestructor` | adapted | `Language/Destructors/StructDestructor` |
| `Language/Destructors/BaseAndDerived` | adapted | `Language/Destructors/Inheritance` |
| `Language/Destructors/ParameterRejected` | adapted | `Language/Destructors/ClassDestructorCompileFail` |
| `Language/Destructors/NameMismatch` | adapted | `Language/Destructors/ClassDestructorCompileFail` |
| `Language/Destructors/GlobalRejected` | adapted | `Language/Destructors/ClassDestructorCompileFail` |
| `Language/Typedef/Alias` | adapted | `Language/Typedef/Alias` |
| `Language/Typedef/StructField` | adapted | `Language/Typedef/InField` |
| `Language/Typedef/DuplicateName` | adapted | `Language/Typedef/AliasCompileFail` |
| `Language/Typedef/UnknownType` | adapted | `Language/Typedef/AliasCompileFail` |
| `Language/Typedef/MissingName` | adapted | `Language/Typedef/AliasCompileFail` |
| `Language/Properties/VirtualAccessor` | get_/set_ | `LANG-PROP-ACCESSOR` |
| `Language/Properties/ConstGetter` | const getter | `LANG-PROP-ACCESSOR` |
| `Language/Properties/Indexed` | indexed property | `LANG-PROP-INDEXED` |
| `Language/Properties/GetterOnlyWrite` | write without setter | `LANG-PROP-ACCESSOR` |
| `Language/Properties/SetterOnlyRead` | read without getter | `LANG-PROP-ACCESSOR` |
| `Language/Class/FieldInitializer` | adapted | `Language/Class/Fields` |
| `Language/Class/ConstMethod` | adapted | `Language/Class/Methods` |
| `Language/Class/PrivateAccess` | adapted | `Language/Class/Access` |
| `Language/Class/MethodCall` | adapted | `Language/Class/Methods` |
| `Language/Class/FieldAssign` | adapted | `Language/Class/Fields` |
| `Language/Inheritance/OverrideWrongArity` | adapted | `Language/Inheritance/OverrideCompileFail` |
| `Language/Inheritance/SuperFieldRead` | adapted | `Language/Inheritance/Super` |
| `Language/Inheritance/ThreeLevelOverride` | adapted | `Language/Inheritance/Override` |
| `Language/Inheritance/InheritedMethod` | adapted | `Language/Inheritance/Extends` |
| `Language/Destructors/DestructorReadsField` | adapted | `Language/Destructors/ClassDestructor` |
| `Language/Typedef/TypedefHandle` | adapted | `Language/Typedef/Handle` |
| `Language/Typedef/TypedefInReturn` | adapted | `Language/Typedef/InReturn` |
| `Language/Typedef/TypedefChain` | adapted | `Language/Typedef/Chain` |
| `Language/Typedef/TypedefClassField` | adapted | `Language/Typedef/InField` |
| `Language/Properties/GetterOnly` | read-only property | host-free |
| `Language/Properties/SetterWrongType` | setter type reject | host-free |
| `Language/Properties/PropertyHandle` | property on handle | host-free |
| `Language/Mixin/*` | adapted | `Language/Mixin/FunctionMixin` |
| `Language/Auto/*` | adapted | `Language/Auto/InferFromLiteral` |
| `Language/Const/ConstLocal` | const local read | beside leftover Rejects |

AActor / UFUNCTION / FString observers stay excluded. The six adapted theme trees above are already projected; Properties and leftover Const are not part of that wave.
