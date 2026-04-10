# Merge-коммиты и карта экранов

Чтобы в истории Git было понятно, **какой смысл у слияния**, а не только «sync», используй осмысленные сообщения merge-коммита с двумя частями: **заголовок** + **тело** с картой UI и действиями.

## Карта экрана (куда что ведёт)

Один экран `MailCommandCenterScreen` (см. `lib/screens/mail_command_center_screen.dart`), сверху вниз:

```text
┌─────────────────────────────────────────────────────────────────────┐
│ TopBar: заголовок, «Live sync», «Mark visible mail as read»         │
└─────────────────────────────────────────────────────────────────────┘
┌──────────┬──────────┬──────────┬──────────┐
│ Metrics  │ Metrics  │ Metrics  │ Metrics│  ← Unread / Urgent / Open tasks / Team threads
└──────────┴──────────┴──────────┴──────────┘
┌─────────┬──────────┬────────────────────┬─────────────┐
│ Queues  │ Mailbox  │ Opened message     │ Task panel  │
│ (folder)│ (список) │ (деталь треда)     │ (чеклист)   │
│         │          │                    │             │
│ Inbox…  │ поиск    │ теги, Signal, body │ прогресс    │
│         │ карточки │ Activity, вложения│ задачи ✓    │
└─────────┴──────────┴────────────────────┴─────────────┘
```

**Переходы / что делать пользователю**

| Зона | Действие | Эффект |
|------|-----------|--------|
| **Queues** | Нажать папку (Inbox, Priority, Team, Follow up) | Фильтр списка писем по правилам папки |
| **Mailbox** | Ввести текст в Search | Узкий поиск по sender, subject, preview, summary, route, tags |
| **Mailbox** | Нажать карточку письма | Выбор треда → справа деталь и задачи; письмо помечается прочитанным |
| **Detail** | Reply draft / Assign owner / Escalate | Переключает «текущую команду» (текст в сайдбаре и внизу задач) |
| **Tasks** | Чекбокс задачи | Отмечает done / не done для **текущего** письма |
| **TopBar** | Mark visible mail as read | Снимает unread со всех писем **в текущем отфильтрованном** списке |

На узком экране те же блоки идут **колонкой** (см. брейкпоинты в `MailCommandCenterScreen`), логика та же.

## Ветки

| Ветка | Назначение |
|-------|------------|
| `main` | Источник для **GitHub Pages** (`deploy.yml` на push) |
| `develop` | Интеграция; догоняется merge из `main` после релиза на `main` |
| `staging` | Препрод / проверка перед тем же составом, что на `main` |

## Шаблон сообщения merge-коммита

**Заголовок (первая строка):** что сливается и зачем.

```text
merge(main→develop): подтянуть релиз Pages после Flutter-миграции
```

**Тело (вторая и следующие строки):** что в UI затронуто и что проверить.

```text
UI: TopBar → Metrics → Workspace [Queues | Mailbox | Detail | Tasks].
Проверить: смена папки, поиск, выбор письма (unread), чекбоксы задач,
кнопки Reply draft / Assign owner / Escalate, Mark visible as read.
Деплой: только main; develop/staging — без билда Pages.
```

## Как сделать merge с телом (PowerShell)

Из ветки `develop`:

```powershell
git fetch origin
git merge origin/main `
  -m "merge(main→develop): <коротко что приехало с main>" `
  -m "UI поток: Queues→Mailbox→Detail→Tasks. Действия: папка, поиск, выбор письма, задачи, команды. Проверить локально: flutter run -d chrome."
```

Из ветки `staging` — то же, с пометкой `main→staging`.

## Чего избегать

- Пустой или одно слово: `sync`, `merge`, `wip` — в логе непонятно, что проверять.
- Только fast-forward без merge-коммита — ок, если историю держишь линейной; тогда **осмысленность** переносится в обычные коммиты на `main`.

## Связь с кодом

- Один файл экрана: `lib/screens/mail_command_center_screen.dart`
- Данные/состояние: `lib/data/initial_mails.dart`, `lib/models/mail_models.dart`
