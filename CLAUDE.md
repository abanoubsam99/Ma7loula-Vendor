# Ma7loula Vendor — Project Guide

Flutter vendor app for the Ma7loula platform. Vendors (service providers) receive orders, send price offers, accept/reject, and deliver. Arabic-first (RTL), uses `easy_localization`.

- **Package name:** `ma7lola_vendor` (note the spelling — imports use `package:ma7lola_vendor/...`)
- **Flutter SDK:** `^3.6.1` · **State management:** `provider` · **HTTP:** `dio`
- **Base API:** `https://api.ma7loula.com/api/v1/` (see [api_endpoints.dart](lib/core/services/http/api_endpoints.dart))

## Vendor / service types

The app is one binary serving **4 distinct vendor backends**, chosen by `vendorID` stored in secure storage. Login endpoint is picked by id in [user_api.dart](lib/core/services/http/apis/user_api.dart) `login`:

| vendorID | type        | login endpoint            | notes |
|----------|-------------|---------------------------|-------|
| 1        | `bt-vendor` (battery) | `bt-vendor/login`         | product-based (battery) |
| 2        | `car-parts` | `car-parts-vendor/login`  | product-based (car parts, tires) |
| 3        | `winch`     | `winch/login`             | live service + map + offers |
| else     | `emergency` | `emergency/login`         | live service + map + offers + services list |

Endpoint constants are grouped per vendor in [api_endpoints.dart](lib/core/services/http/api_endpoints.dart) (bt-vendor / car-parts-vendor / winch / emergency blocks).

The notification `data.type` field uses these strings: `winch`, `emergency`, `car-parts`, `tire`, `battery`.

## Notification system (most-worked-on area)

Two layers: **FCM** (Firebase Cloud Messaging) for transport + **flutter_local_notifications** for display. Core: [notifyHelper.dart](lib/core/utils/notifyHelper.dart) (`NotificationsHelper` singleton).

### Flow
- `main()` ([main.dart](lib/main.dart)): `Firebase.initializeApp` → **registers `firebaseMessagingBackgroundHandler` (top-level, before `runApp`)** → `NotificationsHelper().initialize()`.
- `initialize()`: init Firebase + local notifications, create channels, set up FCM listeners (`onMessage`, `onMessageOpenedApp`, `onTokenRefresh`), fetch token.
- Channels: `order_alerts_channel` (orders) and `visit_alerts_channel` (visits), both `Importance.max`, full-screen intent, strong vibration. `order_alerts_channel` is also the manifest `default_notification_channel_id`.
- `navigatorKey` (`NotificationsHelper.navigatorKey`) is wired into `MaterialApp` so navigation works from anywhere.

### Message handling
- **Foreground** (`onMessage`) → `processIncomingMessage(showFullScreen: true)` → opens `OrderAlertScreen` directly (no tray notification).
- **Background/terminated** (`firebaseMessagingBackgroundHandler`) → `processIncomingMessage` → shows a tray notification for **any** incoming message (does NOT drop non-actionable ones).
- **Tap on notification** (`onMessageOpenedApp`, local-notification tap, or `getInitialMessage` via `handleLaunchNotification`) → `_openDetailsAndAlertFromData` → **navigates to the correct details page for the type, then shows `OrderAlertScreen` on top** (closing the alert returns to details). Details routing in `_navigateToDetails`:
  - `winch` → `WinchOrderDetails`, `emergency` → `EmergencyOrderDetails`, `battery/tire/car-parts` → `OrderDetails(orderType: 0/1/2)`.

### ⚠️ Known constraint — notifications when app is killed/terminated
This is a **platform limitation, not a code bug**: when the app is force-killed (swiped from recents), Android does **not** deliver data-only FCM messages until the app reopens. The only reliable fix is **backend-side**: send a `notification` block (not data-only) with `android.priority = HIGH`. Then Google Play Services displays it without waking the app. See [order-alert-status-model](#) discussions in memory.

### ⚠️ FCM token refresh
The backend has **no endpoint to update the FCM token** independently — token is sent only at **login** (`fcm_token` field). `_syncFcmToken` (on `onTokenRefresh`) currently only logs; the real `UserApi.updateFcmToken` call + import are left commented, ready to enable once a backend endpoint exists. A rotated token mid-session can stop notifications until next login.

## Order status model & alert screen

[order_alert_screen.dart](lib/core/widgets/order_alert_screen.dart) — full-screen `OrderAlertScreen` with 30s countdown, alarm sound (`assets/sounds/order_alert.mp3`), accept/reject. Status strings: `new`, `preparing`, `on_the_run`, `delivered`, `complete`, `cancelled` (see `OrderStatus` in [my_orders_card.dart](lib/view/screens/main_screen/tabs/my_orders_tab/local_widet/my_orders_card.dart)).

Action mapping (confirmed with user):

**Winch / Emergency:**
- `new` → offer phase: "قبول" = send offer (`sentWinchOffer`/`sentEmergencyOffer`), "رفض" = reject. Closes on success.
- `accepted` / `preparing` / `on_the_run` → **deliver phase** (only after customer accepts): "تم التوصيل" = `updateOrderStatus...`, "اتصال" = call customer (`_showDeliverPhase`).
- `offer_pending` / `pending_customer` → "offer sent, waiting" — NOT deliver phase; tray notification only (not opened as full-screen, see `_isActionableAlert`).

**Car-parts / Tire / Battery:**
- `new` only → accept (`updateCarPartsOrderStatus`) / reject (cancel) / change price. Other statuses handled by the details screen.

`_isActionableAlert` (in notifyHelper) gates which statuses auto-open the full-screen alert, and is **type-aware** (winch/emergency: new + deliver statuses; others: new only).

> Assumption to verify with backend: the post-acceptance status string is assumed to be `preparing`/`on_the_run`/`accepted`. If different, update `_showDeliverPhase` and `_isActionableAlert`.

## API layer

- [api_client.dart](lib/core/services/http/api_client.dart) — Dio instance.
- [api_interceptor.dart](lib/core/services/http/interceptors/api_interceptor.dart) — if a request includes the `Authorization` header key, the interceptor fills it with `Bearer <token>` from secure storage.
- [user_api.dart](lib/core/services/http/apis/user_api.dart) — auth (login/register/profile/password).
- [miscellaneous_api.dart](lib/core/services/http/apis/miscellaneous_api.dart) — almost everything else (orders, products, offers, status updates, details, addresses, cars, wallet). Key methods: `sentWinchOffer`, `sentEmergencyOffer`, `updateOrderStatusWinch`, `updateOrderStatusEmergency`, `updateCarPartsOrderStatus`, `carPartsSubmitPriceOffer`, `reject*Offer`, `cancel*Order`, `get*OrderDetails`.
- Secure storage keys in [secure_storage_keys.dart.dart](lib/core/services/secure_storage/secure_storage_keys.dart.dart): `token`, `vendorID`, `name`, `password`, etc.

## Key screens

- Winch: [winch_order_request.dart](lib/view/screens/main_screen/tabs/winch/winch_order_request.dart) (map + offer), [winch_order_details_screen.dart](lib/view/screens/main_screen/tabs/winch/winch_order_details_screen.dart).
- Emergency: [emergency_order_request.dart](lib/view/screens/main_screen/tabs/emergency/emergency_order_request.dart), [emergency_order_details_screen.dart](lib/view/screens/main_screen/tabs/emergency/emergency_order_details_screen.dart), [services_details_screen.dart](lib/view/screens/main_screen/tabs/emergency/services_details_screen.dart).
- Car-parts/tire/battery: [order_details_screen.dart](lib/view/screens/main_screen/tabs/my_orders_tab/order_details_screen.dart) (`OrderDetails`, `orderType`: 0=battery, 1=tire, else=car-parts).
- Offer polling providers: [get_offers_provider.dart](lib/controller/get_offers_provider.dart) (winch), [get_emergency_offers_provider.dart](lib/controller/get_emergency_offers_provider.dart). In request screens, deliver phase is keyed on `acceptedOffer != null` (customer accepted).

## Conventions

- UI text via `LocaleKeys.<key>.tr()` ([locale_keys.g.dart](lib/core/generated/locale_keys.g.dart)); translations in `assets/translations/`.
- Colors via `ColorsPalette` / `AppTheme` (AppTheme is local to order_alert_screen).
- `ResponsiveHelper` for font/icon sizing; `sizer` (`.sp`, `%`) used in many screens.
- Pre-existing analyzer noise: many `DioError` deprecation warnings and some unused legacy elements — not introduced by recent work.
