# UserWidget Case Inventory

> SubPlan: [`SubPlan_UserWidget.md`](./SubPlan_UserWidget.md)  
> Baseline: `Angelscript.TestModule.Bindings.UserWidget` = 2/2 PASS  
> Coverage status: all dumped checks are mapped to the refactored sections and marked `covered`.

## UserWidgetTreeCompat

| Status | Old check | Fixture dependency | New section |
|--------|-----------|--------------------|-------------|
| covered | scripted `FindObject` resolves the transient `UUserWidget` fixture | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | initial `GetRootWidget()` returns null | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | `ConstructWidget(UTextBlock::StaticClass())` returns a widget | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | constructed widget casts to `UTextBlock` | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | constructed widget name equals requested runtime name | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | `SetRootWidget` round-trips through `GetRootWidget` | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | `GetAllWidgets` reports one widget after setting root | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | `GetAllWidgets[0]` is the root widget | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | `RemoveWidget(root)` returns true | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | `GetRootWidget()` returns null after removal | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | `GetAllWidgets` reports zero widgets after removal | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | native baseline starts with no root and no widgets | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |
| covered | native postcondition has no root, no tree root, no widgets, and no named widget | generated `UUserWidget` class + widget tree | `RunWidgetTreeBasicSection` |

## UserWidgetTreeErrorPaths

| Status | Old check | Fixture dependency | Expected error | New section |
|--------|-----------|--------------------|----------------|-------------|
| covered | tree-backed fixture path is non-empty | generated `UUserWidget` class + widget tree | none | `RunWidgetTreeErrorSection` |
| covered | missing-tree fixture path is non-empty | generated `UUserWidget` class without widget tree | none | `RunWidgetTreeErrorSection` |
| covered | missing-tree fixture starts with `WidgetTree == nullptr` | generated `UUserWidget` class without widget tree | none | `RunWidgetTreeErrorSection` |
| covered | missing-tree fixture starts with `GetRootWidget() == nullptr` | generated `UUserWidget` class without widget tree | none | `RunWidgetTreeErrorSection` |
| covered | detached text block starts parentless | detached `UTextBlock` | none | `RunWidgetTreeErrorSection` |
| covered | script resolves all three fixtures | generated widgets + detached text block | none | `RunWidgetTreeErrorSection` |
| covered | `ConstructWidget(AActor::StaticClass())` returns null | tree-backed fixture | `Ensure condition failed: WidgetClass && WidgetClass->IsChildOf(UWidget::StaticClass())` | `RunWidgetTreeErrorSection` |
| covered | invalid construct does not create a root widget | tree-backed fixture | same invalid-class ensure | `RunWidgetTreeErrorSection` |
| covered | missing-tree `SetRootWidget` is a no-op | missing-tree fixture + detached text block | none | `RunWidgetTreeErrorSection` |
| covered | missing-tree `RemoveWidget` returns false | missing-tree fixture + detached text block | none | `RunWidgetTreeErrorSection` |
| covered | native tree-backed fixture remains empty after invalid construct | tree-backed fixture | same invalid-class ensure | `RunWidgetTreeErrorSection` |
| covered | missing-tree fixture still has no `WidgetTree` and no root after script | missing-tree fixture | none | `RunWidgetTreeErrorSection` |
| covered | detached text block remains parentless after remove attempt | detached `UTextBlock` | none | `RunWidgetTreeErrorSection` |
