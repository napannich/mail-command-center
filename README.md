<div align="center">

<img src="./public/favicon.svg" width="88" alt="Mail Command Center mark" />

<br/>
<br/>

<strong>Modern mail workspace for triage-heavy teams.</strong>

<br/>

Queues on the left, opened thread in the center, accountable follow-up on the right.

<br/>
<br/>

<a href="https://napannich.github.io/mail-command-center/">
  <img src="https://img.shields.io/badge/Live-GitHub_Pages-0F766E?style=for-the-badge&labelColor=1D2527" alt="Live demo on GitHub Pages" />
</a>
<a href="https://github.com/napannich/mail-command-center">
  <img src="https://img.shields.io/badge/Source-GitHub-7C5C43?style=for-the-badge&labelColor=1D2527" alt="Source on GitHub" />
</a>

<br/>
<br/>

<img src="https://img.shields.io/badge/Flutter-stable-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
<img src="https://img.shields.io/badge/Dart-3-blue?style=flat-square&logo=dart&logoColor=white" alt="Dart" />
<img src="https://img.shields.io/badge/UI-Material_3-757575?style=flat-square&logo=material-design&logoColor=white" alt="Material 3" />
<img src="https://img.shields.io/badge/Target-Web-4285F4?style=flat-square&logo=google-chrome&logoColor=white" alt="Web" />
<img src="https://img.shields.io/badge/Deploy-GitHub_Pages-0F766E?style=flat-square&logo=github&logoColor=white" alt="GitHub Pages" />
<img src="https://img.shields.io/badge/Layout-Responsive-E4A96A?style=flat-square&logo=googlechrome&logoColor=white" alt="Responsive layout" />
<img src="https://img.shields.io/github/actions/workflow/status/napannich/mail-command-center/deploy.yml?branch=main&style=flat-square&label=pages%20deploy" alt="GitHub Pages deploy status" />

</div>

<br/>

## Co-authors

- [@v-litvintsev](https://github.com/v-litvintsev) — [vl.litvintsev@yandex.ru](mailto:vl.litvintsev@yandex.ru)
- [@Razgon21](https://github.com/Razgon21) — [gon.21.arov@gmail.com](mailto:gon.21.arov@gmail.com)

<br/>

## Product Preview

<img src="./.github/assets/mail-command-center-preview.png" width="100%" alt="Mail Command Center application preview" />

<br/>

## What This Is

Mail Command Center is a clean, high-clarity email workspace designed for teams that do more than just read messages.

It turns the inbox into an operating surface:

- queue-aware mailbox for fast triage
- opened thread view for deep reading and context
- task panel that keeps owners, due times and next steps attached to the active conversation
- responsive layout that still feels composed on narrower screens

Instead of scattering work across tabs, notes and chat, the UI keeps the message, the signal and the follow-up in one place.

## Why The Repo Feels Like A Product

<table>
  <tr>
    <td width="33%" valign="top">
      <strong>Queue-first inbox</strong>
      <br/>
      Filter by priority, team traffic or follow-up state.
      Search stays fast and the mailbox always shows how much unresolved work is still in flight.
    </td>
    <td width="33%" valign="top">
      <strong>Opened thread as a workspace</strong>
      <br/>
      The central panel is not just a reading surface.
      It includes summary, sender identity, timeline context and attachment awareness in the same view.
    </td>
    <td width="33%" valign="top">
      <strong>Tasks attached to the conversation</strong>
      <br/>
      Every selected thread brings its own checklist, ownership lane and progress signal, so action lives next to the message that created it.
    </td>
  </tr>
</table>

## Experience Highlights

- Editorial typography and warm dashboard tones keep the interface product-like instead of template-like.
- The three-surface layout makes scanning, reading and acting feel immediate.
- Mail selection marks items as read and updates the detail and task panels in sync.
- Search filters by sender, subject, route, summary and tags.
- Queue counts, unread totals and task totals update from the same in-memory source of truth.
- The Flutter web bundle is built and deployed automatically to GitHub Pages on push to `main`.

## Live Demo

- App: [napannich.github.io/mail-command-center](https://napannich.github.io/mail-command-center/)
- Repository: [github.com/napannich/mail-command-center](https://github.com/napannich/mail-command-center)

## Local Setup

Install [Flutter](https://docs.flutter.dev/get-started/install) (stable channel, web enabled).

```bash
git clone https://github.com/napannich/mail-command-center.git
cd mail-command-center
flutter pub get
flutter run -d chrome
```

## Production Checks

```bash
flutter analyze
flutter test
flutter build web --release --base-href /mail-command-center/
```

## Stack

| Layer | Implementation |
| --- | --- |
| UI | `Flutter` (Material 3) |
| Language | `Dart` 3 |
| Typography | `google_fonts` (Libre Baskerville + Lato) |
| State | `StatefulWidget` — same mailbox / folder / search / task model as before |
| Deployment | `flutter build web` → `GitHub Pages` via GitHub Actions |

## Design Direction

- warm editorial palette instead of generic neon SaaS colors
- serif-driven heading system for a stronger product voice
- glassy panels and soft shadows for depth without visual clutter
- motion kept intentional and minimal rather than overloaded with micro-animations

## Project Structure

```text
mail-command-center/
|
|-- .github/
|   |-- assets/
|   |   `-- mail-command-center-preview.png
|   `-- workflows/
|       `-- deploy.yml
|
|-- lib/
|   |-- main.dart
|   |-- data/
|   |   `-- initial_mails.dart
|   |-- models/
|   |   `-- mail_models.dart
|   |-- screens/
|   |   `-- mail_command_center_screen.dart
|   `-- theme/
|       `-- app_theme.dart
|
|-- public/
|   `-- favicon.svg
|
|-- test/
|   `-- widget_test.dart
|
|-- docs/
|   `-- merge-commit-guide.md
|
|-- analysis_options.yaml
`-- pubspec.yaml
```

## Branches and merge messages

`main` — то, что уходит на **GitHub Pages**; `develop` / `staging` обычно догоняются merge из `main`. Чтобы в истории было видно **какой поток экрана** и **что руками проверить**, пиши merge-коммиты с понятным заголовком и телом (шаблоны и ASCII-схема UI): [**docs/merge-commit-guide.md**](./docs/merge-commit-guide.md).

## Shipping Model

Pushes to `main` trigger the Pages workflow in [deploy.yml](./.github/workflows/deploy.yml), build the app and publish the static bundle to GitHub Pages.

That keeps the repository presentation, source code and live demo tied together in one clean loop.

<div align="center">

<br/>

<strong>Mail Command Center</strong>

<br/>

Built to read faster, route cleaner and look like a finished product on first open.

<br/>
<br/>

</div>
