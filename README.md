# Mail Command Center

Responsive mail workspace built with React, TypeScript and Vite.

## What It Includes

- mailbox with queue filters and search
- opened email view with message body, activity timeline and attachments
- task panel linked to the selected thread
- live metrics for unread mail, urgent threads, open tasks and team traffic
- desktop and narrow-screen layouts

## Run Locally

```bash
npm install
npm run dev
```

Open the local URL printed by Vite in the terminal.

## Production Check

```bash
npm run build
npm run lint
```

## Interaction Model

- click any mail card to open the full thread
- switch queues from the left sidebar
- use search to filter conversations by sender, subject, route or tag
- toggle checklist items in the task panel to track progress for the active thread

## Stack

- React 19
- TypeScript
- Vite 8
- plain CSS with responsive grid layout
