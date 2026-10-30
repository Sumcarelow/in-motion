# In Motione Customer App Runtime Audit

Audit date: 2026-10-29  
Device: Android 15 / API 35 emulator (`InMotione_Test_API35`)  
Package: `com.inmotion.customer`

This report covers the customer app only. The audit used a configured Firebase test phone account; the phone number, OTP, email address, and user ID are intentionally omitted.

## Result summary

The moving-focused home and service-entry UI is present, but the application is not release-ready. Core booking progression is blocked by missing backend configuration, payment-related screens cannot initialize, completed move details crash, privacy/terms are blank, and legacy passenger-vehicle data is still visible.

No real move, payment, support ticket, rating, account deletion, or other external transaction was submitted during this audit.

## Flow matrix

| Area | Result | Runtime result |
| --- | --- | --- |
| Cold launch | FAIL | Eventually reaches Home, but cold launch repeatedly takes roughly 20–30 seconds. One earlier run produced an Android ANR. Every launch logs Firebase App Check 403 and an unhandled `firebase_functions/not-found` error. |
| Phone login validation | PASS | Empty/invalid phone input is rejected. |
| Country selection | PARTIAL | South Africa can be selected, but India/+91 is the initial default. |
| OTP screen | PASS | Configured Firebase test number reaches OTP. An incorrect code does not authenticate; the configured code authenticates. |
| Existing-user login | PASS | Correct OTP opens the authenticated app and loads the Firestore user profile. |
| New-user registration/profile completion | BLOCKED | The only configured test phone belongs to an existing account, so the new-user signup form could not be reached without creating or deleting account data. |
| Google login | BLOCKED | Opens Google account setup, but the emulator has no Google account. Authentication was not automated. |
| Location permission | PASS | While-in-use and all-the-time permission paths work. Location reaches Durban after the emulator GPS fix. |
| Home | PARTIAL | Moving-focused cards render correctly. “Your Moves” says the history is empty even though Local Moves contains completed and rejected records. |
| Local Move entry | PARTIAL | Map, current-location display, and moving route form work. Destination text can be entered, but no location suggestions appear, so booking cannot progress. |
| Schedule a Move | PARTIAL | Moving date and time pickers work. Route selection is blocked by the same missing location configuration. |
| Long-Distance Move | PARTIAL | Intro, Get Started, route/date/price form, and moving-vehicle selector work. Selector contains only Vans and Mini Trucks. Route selection remains blocked. Price uses `$` while other screens use `R`. |
| Small-Load Move | PARTIAL | Form, weight/load fields, date/time, vehicle selector, camera launch, gallery launch, and photo picker work. Route selection remains blocked. The default “Vans” record uses an image that appears to be a pickup/SUV. |
| Local Moves history | FAIL | Tabs load, but completed/rejected records expose legacy passenger services: “Hatch Backs & Sedans”, “XL”, and “Hacth Back & Sedan”. |
| Completed move details | FAIL | Opening a completed record renders Flutter’s red error screen: `Null check operator used on a null value`, followed by a bottom overflow of approximately 99,203 pixels. The view dereferences `Constant.paymentModel!` while payment configuration is unavailable. |
| Scheduled Moves drawer entry | FAIL | Opens the Schedule a Move booking form instead of a scheduled-move history/list. |
| Small-Load Moves history | PASS | Active, Ongoing, and Completed tabs render. All were empty and show a moving-focused empty state. |
| Long-Distance Moves history | PASS | Active, Ongoing, and Completed tabs render. All were empty. “Book a Move” opens the correct long-distance intro. |
| Payments & Wallet | FAIL | Balance and empty transaction-history UI render, but a permanent “Please wait” loader blocks the page. Payment configuration is fetched through a callable function that is not deployed, and the loader is not closed on failure. |
| Add Money / wallet top-up | BLOCKED | Cannot be reached because Wallet never finishes loading. No financial transaction was attempted. |
| Move Statements UI | PARTIAL | Moving-only type choices are Local Move, Long-Distance Move, and Small-Load Move. Time choices and custom-range UI render. |
| Move Statement download | FAIL | “All” actually selects only January 1 of the current year through today. Empty results only print a debug message, with no user feedback or file. “Last Year” also produced no statement for the test account’s visible history. |
| Support list | PASS | Opens correctly and shows an empty-ticket state. |
| Create support ticket | PASS (UI only) | Title, subject, description, image area, and Save button render. The title dropdown loads one reason: “Vehicle condition is not good”. Submission was intentionally not performed. |
| Support ticket details | BLOCKED | No support tickets exist, and creating one would write external data. |
| Notifications | FAIL | Opens to a completely blank screen with no notification rows and no empty-state explanation. |
| Edit profile | PARTIAL | Profile fields load. Country displays India while the account phone is South African. Save was not used to alter the account. |
| Theme setting | PASS | Light/dark switch changes the theme. Light mode was restored after testing. |
| Language selection | PARTIAL | English/Arabic/Hindi selection works. Arabic switches to RTL, but several new moving labels remain English, including My Moves, Payments & Wallet, Move Statements, and Delete Account. Some Arabic/Hindi translation values still use taxi/ride/passenger-era wording. English was restored. |
| Privacy & Policy | FAIL | Opens as a completely blank page. |
| Terms & Condition | FAIL | Opens as a completely blank page. |
| Rate Us | BLOCKED | Launches Google Play, but the emulator is unauthenticated and only shows the Play Store sign-in screen. No rating was submitted. |
| Delete Account | PASS (confirmation only) | Confirmation dialog appears with Cancel and Delete. Delete was not confirmed. The required deletion callable is not deployed. |
| Logout | PASS (confirmation only) | Confirmation dialog appears with Cancel and Log out. Logout was cancelled to preserve the authenticated test session. |
| Tracking, chat, cancellation, review, coupon, driver selection, and payment-after-move | BLOCKED | These routes require an active/accepted booking. A booking cannot be created because location selection is blocked, and creating a real booking was outside the safe audit scope. |

## Backend blockers

Firebase project: `go-motion-56f36`

The deployed functions list does not contain the callable functions required by the customer app. Missing callables observed in the code/runtime are:

- `getPublicAppConfiguration`
- `getPaymentConfiguration`
- `createPayFastWalletTopUp`
- `getPayFastWalletTopUpStatus`
- `payRideWithWallet`
- `updateCustomerRide`
- `requestCustomerAccountDeletion`
- `sendUserNotification`

The local `functions/src/index.ts` is still the Firebase sample and does not implement these callables. Firebase App Check is also disabled/not initialized for the project and returns HTTP 403; the SDK falls back to placeholder tokens.

`getPublicAppConfiguration` failing leaves the runtime Google Places key, privacy policy, terms, support URL, currency, and related public settings unset. That one failure explains several visible symptoms: no route suggestions, blank legal pages, and inconsistent currency/fallback values.

## Code-quality checks

- `flutter test test/moving_experience_test.dart`: **3 tests passed**.
- The tests correctly keep mini trucks/vans/pickups/cargo vehicles and reject passenger/inactive vehicles.
- `flutter analyze --no-fatal-infos --no-fatal-warnings`: completed with **224 findings**, including warnings, deprecated API use, missing type annotations, unused imports, and dependency declarations missing from `pubspec.yaml`.
- The installed debug APK runs on API 35, so the project is buildable despite the runtime/backend failures.

## Highest-priority fixes

1. Implement and deploy the required callable backend, then enable/configure Firebase App Check.
2. Make startup/config loading fail safely with visible retry/error states instead of unhandled exceptions or permanent loaders.
3. Remove/filter passenger-vehicle records from every history/result surface, including historical Firestore data.
4. Fix move-detail null safety and do not build payment UI until payment configuration is available.
5. Replace the Scheduled Moves drawer destination with an actual scheduled-move history.
6. Provide bundled or safely cached legal/currency/map configuration so core UI is not blank when the backend is unavailable.
7. Complete Arabic/Hindi moving terminology and new-label translations.
8. Add explicit empty/error feedback to Notifications and statement generation.

## Evidence files

The emulator screenshots captured during the audit are stored under:

`C:\Users\Sam\AppData\Local\Temp\inmotione-*.png`

Key files include:

- `inmotione-home-ready.png`
- `inmotione-completed-details-now.png`
- `inmotione-wallet.png`
- `inmotione-privacy.png`
- `inmotione-terms.png`
- `inmotione-arabic-drawer.png`
- `inmotione-delete-dialog.png`
- `inmotione-logout-dialog2.png`

