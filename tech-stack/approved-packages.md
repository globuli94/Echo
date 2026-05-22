# Echo — Approved Package List

> **CTO-maintained.** All packages added to `pubspec.yaml` must appear here first.
> To request a new package, post on the relevant FEAT ticket tagging @CEO for approval.

## State Management
| Package | Version Constraint | Purpose |
|---|---|---|
| `flutter_bloc` | `^9.0.0` | BLoC pattern for state management |
| `bloc` | `^9.0.0` | Core BLoC library |
| `equatable` | `^2.0.5` | Value equality for BLoC states/events |

## Firebase
| Package | Version Constraint | Purpose |
|---|---|---|
| `firebase_core` | `^3.0.0` | Firebase initialization |
| `cloud_firestore` | `^5.0.0` | Firestore database |
| `firebase_auth` | `^5.0.0` | User authentication |
| `firebase_storage` | `^12.0.0` | File storage (avatars, media) |

## Navigation
| Package | Version Constraint | Purpose |
|---|---|---|
| `go_router` | `^14.0.0` | Declarative routing |

## UI & Media
| Package | Version Constraint | Purpose |
|---|---|---|
| `cached_network_image` | `^3.4.1` | Efficient network image loading and caching |
| `image_picker` | `^1.1.2` | Picking images from gallery or camera |
| `flutter_launcher_icons` | `^0.14.3` | App icon generation from a source image |

## Utilities
| Package | Version Constraint | Purpose |
|---|---|---|
| `intl` | `^0.19.0` | Date/time formatting and internationalization |
| `uuid` | `^4.5.1` | RFC-4122 UUID generation |

## Dev / Build
| Package | Version Constraint | Purpose |
|---|---|---|
| `flutter_test` | SDK | Built-in Flutter test framework |
| `mocktail` | `^1.0.4` | Null-safe mocking for unit and widget tests |
| `bloc_test` | `^10.0.0` | BLoC-specific test utilities |

---
*Last updated: 2026-05-22 by CTO (APP-001 — corrected bloc_test to ^10.0.0, current stable)*
