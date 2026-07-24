## ADDED Requirements

### Requirement: Product visual verification covers supported locales and responsive viewports

The actual integrated Wiki product SHALL verify its reviewed shell and document surfaces under both supported locales (`zh-Hans` and `en-GB`) at a desktop viewport and a narrow viewport. The verification SHALL use real product tiddlers and SHALL assert visible navigation, bounded layout geometry, and absence of horizontal document overflow.

#### Scenario: Reader uses either supported locale on desktop
- **WHEN** the product runs in zh-Hans or en-GB at the reviewed desktop viewport
- **THEN** the localized navigation and document shell SHALL remain visible and usable
- **AND** the sidebar and story boundaries SHALL remain within the viewport without horizontal overflow

#### Scenario: Reader uses either supported locale on a narrow viewport
- **WHEN** the product runs in zh-Hans or en-GB at the reviewed narrow viewport
- **THEN** the compact navigation and drawer/document surfaces SHALL remain reachable
- **AND** the document root SHALL not gain horizontal overflow from localized text

### Requirement: Critical visual states retain focus visibility and reviewed contrast

The product SHALL verify keyboard focus visibility and WCAG AA contrast for the reviewed opaque text/control/tag foreground-background pairs that define the document visual system. These checks SHALL operate on computed runtime values rather than an independent static mockup.

#### Scenario: Reader focuses a critical navigation or control surface
- **WHEN** keyboard focus reaches a reviewed sidebar tab, control-rail action, or other critical interactive surface
- **THEN** the element SHALL expose a visible focus treatment
- **AND** its reviewed foreground/background pair SHALL meet the documented contrast threshold

### Requirement: Screenshot goldens require deterministic admission controls

The product SHALL NOT add pixel screenshot golden assertions until the target test environment defines a fixed browser/font renderer, deterministic tiddler fixtures, masks for volatile content, a reviewed image tolerance, and an explicit scene inventory.

#### Scenario: Maintainer proposes a new screenshot regression
- **WHEN** a maintainer proposes a screenshot golden for the Wiki product
- **THEN** the proposal SHALL document the renderer, fixture, masks, tolerance, and scene purpose before the snapshot is committed
