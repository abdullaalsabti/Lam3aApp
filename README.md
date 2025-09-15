
# Lam3a – Flutter Tech Stack

| Tool / Package                        | Purpose / Role                                   | Notes / Why we use it                             |
|---------------------------------------|--------------------------------------------------|--------------------------------------------------|
| **flutter_form_builder**              | Forms & validation                               | Handles form state, validators, input widgets     |
| **flutter_localizations + intl**      | Internationalization (Arabic/English)            | Official Flutter i18n support                     |
| **Riverpod**                          | Global state management & DI                     | Modern, testable, recommended over Provider       |
| **flutter_hooks**                     | Widget-level state mgmt (React-like hooks)       | Works well with Riverpod for cleaner state        |
| **dio + retrofit**                    | API requests & networking                        | Powerful HTTP client + declarative API layer      |
| **go_router**                         | Navigation & deep linking                        | Google-recommended, scalable for large apps       |
| **google_maps_flutter**               | Maps integration                                 | Embeds Google Maps in Flutter                     |
| **geolocator**                        | Location services                                | Access GPS, permissions, background location      |
| **flutter_polyline_points**           | Routes & polylines on maps                       | For route drawing and live tracking               |
| **Firebase Cloud Messaging (FCM)**    | Push notifications                               | Standard, reliable solution                       |
|                                       |                                                  |                                                  |
| **flutter_test** (built-in)           | Unit & widget testing                            | Ships with Flutter SDK                            |
| **mocktail / mockito**                | Mocking dependencies                             | For unit & service tests                          |
| **integration_test**                  | End-to-end testing                               | For automated app-level workflows                 |

