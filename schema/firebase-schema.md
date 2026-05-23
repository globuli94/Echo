# Echo — Firestore Schema

**Single source of truth.** All agents must read this document before reading or writing Firestore documents.

---

## Collections

### `users`

**Path:** `users/{uid}`
**Purpose:** Stores user profile data. Document is created on first successful sign-in. The document ID equals the Firebase Auth UID.
**Owner:** Authenticated user whose UID matches the document ID.

| Field | Firestore Type | Required | Description |
|---|---|---|---|
| `uid` | string | required | Firebase Auth UID; mirrors the document ID |
| `displayName` | string | required | Human-readable name shown in the UI |
| `username` | string | required | Unique handle used for @-mentions and profile URLs |
| `bio` | string | optional | Short user biography (may be empty string) |
| `avatarUrl` | string | optional | HTTPS URL to the user's avatar stored in Firebase Storage |
| `followerCount` | number | required | Cached count of followers; default 0 |
| `followingCount` | number | required | Cached count of accounts the user follows; default 0 |
| `postCount` | number | required | Cached count of posts created by the user; default 0 |
| `createdAt` | timestamp | required | Server timestamp set when the document is first created |

**Access patterns:**
- Authenticated user reads own profile (`users/{uid}`, owner)
- Authenticated user reads any other user's profile (`users/{uid}`, third party)
- Authenticated user creates own document on first sign-in (uid == auth.uid)
- Authenticated user updates own profile fields

**Query patterns:**
- Filter `username == value` (no sort) — username search; no composite index required

---

### `posts`

**Path:** `posts/{postId}`
**Purpose:** Stores individual text-based posts created by users. The document ID is a Firestore auto-generated ID.
**Owner:** Authenticated user whose UID matches the `authorId` field.

| Field | Firestore Type | Required | Description |
|---|---|---|---|
| `postId` | string | required | Mirrors the Firestore document ID |
| `authorId` | string | required | Firebase Auth UID of the user who created this post |
| `content` | string | required | Text body of the post |
| `likeCount` | number | required | Cached count of likes; default 0 |
| `commentCount` | number | required | Cached count of comments; default 0 |
| `createdAt` | timestamp | required | Server timestamp set when the post is first created |

**Access patterns:**
- Authenticated user reads any post (`posts/{postId}`, third party)
- Authenticated user creates a post (authorId must equal auth.uid)
- Author deletes own post (`posts/{postId}`, owner)
- Authenticated user updates `likeCount` on any post (third-party field-scoped write)

**Query patterns:**
- No filter, sort by `createdAt DESC` — full feed; no composite index required
- Filter `authorId == uid`, sort by `createdAt DESC` — profile page posts; **composite index required** (see `firestore.indexes.json`)

---

## Firebase Storage Paths

| Path | Purpose | Owner | Access |
|---|---|---|---|
| `avatars/{userId}` | Avatar image for the user at `userId` | Authenticated user whose UID matches `userId` | Owner can write (upload/overwrite); any authenticated user can read |

---

## Firebase Services

| Service | Purpose |
|---|---|
| Firebase Authentication | Gate all Firestore read/write rules; provides `request.auth` context |
| Cloud Firestore | Primary database for all user and post data |
| Firebase Storage | Avatar image uploads referenced by `users.avatarUrl` |

## Authentication Providers

Firebase Authentication is enabled on project `echo-9cf94` with the following providers:

| Provider | Status | Notes |
|---|---|---|
| Email/Password | Enabled | Standard email + password sign-up and sign-in |
| Google Sign-In | Enabled | OAuth 2.0; iOS client ID `608728058117-v506ssdksim6qrq7b9nbf1t5ku64rjns.apps.googleusercontent.com` |

iOS OAuth configuration:
- `GIDClientID` in `ios/Runner/Info.plist`: `608728058117-v506ssdksim6qrq7b9nbf1t5ku64rjns.apps.googleusercontent.com`
- `REVERSED_CLIENT_ID` URL scheme in `ios/Runner/Info.plist`: `com.googleusercontent.apps.608728058117-v506ssdksim6qrq7b9nbf1t5ku64rjns`

---

## Change Log

| Date | Classification | Description |
|---|---|---|
| 2026-05-22 | Safe | Initial schema — `users` and `posts` collections created |
| 2026-05-23 | Safe | Firebase Authentication enabled — Email/Password and Google Sign-In providers; iOS OAuth settings configured |
| 2026-05-23 | Safe | SOCAA-402: Storage Paths section added documenting `avatars/{userId}`; `firestore.rules` update rule for `users` scoped to allowed fields (`displayName`, `bio`, `avatarUrl`) |
