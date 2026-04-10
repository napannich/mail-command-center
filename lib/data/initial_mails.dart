import '../models/mail_models.dart';

List<MailItem> initialMails() => [
      MailItem(
        id: 1,
        sender: 'Avery Chen',
        handle: 'avery.chen@acme-industries.com',
        subject:
            'Renewal blocked until the security questionnaire is signed',
        preview:
            'Procurement says the account pauses today unless we return a signed package and name a single owner for follow-up.',
        received: '08:12 MSK',
        route: 'Revenue Ops',
        lane: Lane.external,
        unread: false,
        priority: Priority.critical,
        tone: 'Escalated by buyer',
        summary:
            'The customer is willing to renew, but the deal will stall if we do not send a signed security packet and confirm one accountable contact before noon.',
        details: const [
          'Hi team, procurement reviewed the latest renewal draft and flagged the unsigned security questionnaire. They can keep the order moving, but only if we return the signed packet today and tell them who owns the remaining answers.',
          'We also need a short response for legal explaining whether the logging retention note changed after the last redline. If it helps, I can jump on a call with your security lead right after lunch.',
          'Please treat this as time-sensitive because our internal purchasing workflow auto-closes the request at the end of the day if there is no named owner on the vendor side.',
        ],
        tags: const ['Renewal', 'Security', 'Q2 close'],
        attachments: const ['security-questionnaire.pdf', 'renewal-redlines.docx'],
        tasks: const [
          TaskItem(
            id: 11,
            title: 'Assign one accountable owner for security follow-up',
            owner: 'Revenue Ops',
            due: '11:30',
            done: true,
          ),
          TaskItem(
            id: 12,
            title: 'Return signed questionnaire to procurement',
            owner: 'Security',
            due: '11:45',
            done: false,
          ),
          TaskItem(
            id: 13,
            title: 'Draft legal note on retention language',
            owner: 'Legal',
            due: '12:10',
            done: false,
          ),
        ],
        timeline: const [
          TimelineItem(
            time: '08:12',
            label: 'Customer escalation received',
            note: 'ACME requested a signed packet and single-thread owner.',
          ),
          TimelineItem(
            time: '08:19',
            label: 'Revenue Ops triaged',
            note: 'Thread moved into critical queue with same-day SLA.',
          ),
          TimelineItem(
            time: '08:27',
            label: 'Security pinged',
            note: 'Owner confirmed, waiting for final signature on attachment.',
          ),
        ],
      ),
      MailItem(
        id: 2,
        sender: 'Marina Volkova',
        handle: 'marina.volkova@product.example',
        subject: 'Customer bug: forwarded attachments disappear from the thread',
        preview:
            'A support lead attached repro steps and wants engineering eyes before the next client call starts.',
        received: '09:05 MSK',
        route: 'Product QA',
        lane: Lane.internal,
        unread: true,
        priority: Priority.high,
        tone: 'Needs triage',
        summary:
            'Support reproduced a forwarding bug where attachments vanish after the second handoff. The thread already has repro notes and needs an owner plus a customer-safe summary.',
        details: const [
          'Support could reproduce the bug in staging twice this morning. The attachment uploads correctly in the first send, but disappears after the message is forwarded from the shared inbox.',
          'The account team has a customer call at 14:00 and asked whether we should tell them this is only a UI issue or a real file-loss scenario. We need a confident answer before then.',
          'I attached the repro checklist and a short screen recording. If someone from frontend can confirm root cause, I can prepare the comms update for support.',
        ],
        tags: const ['Bug', 'Support', 'Forwarding'],
        attachments: const ['repro-checklist.md', 'screen-recording.mp4'],
        tasks: const [
          TaskItem(
            id: 21,
            title: 'Confirm whether files are lost or only hidden in UI',
            owner: 'Frontend',
            due: '12:20',
            done: false,
          ),
          TaskItem(
            id: 22,
            title: 'Prepare customer-safe status note',
            owner: 'Support',
            due: '13:10',
            done: false,
          ),
          TaskItem(
            id: 23,
            title: 'Link thread to bug tracker',
            owner: 'Product QA',
            due: '11:50',
            done: true,
          ),
        ],
        timeline: const [
          TimelineItem(
            time: '09:05',
            label: 'Internal report landed',
            note: 'Support shared a verified staging repro and call deadline.',
          ),
          TimelineItem(
            time: '09:11',
            label: 'Bug record attached',
            note: 'Issue linked to the QA board for noon review.',
          ),
          TimelineItem(
            time: '09:16',
            label: 'Customer comms on hold',
            note: 'Awaiting product confirmation before outbound response.',
          ),
        ],
      ),
      MailItem(
        id: 3,
        sender: 'Finance Bot',
        handle: 'billing@ledger-sync.io',
        subject: 'Invoice 2841 is approved and waiting for legal note',
        preview:
            'Billing closed the payment check, but the vendor record needs one sentence from legal before the invoice can be released.',
        received: '09:42 MSK',
        route: 'Finance',
        lane: Lane.internal,
        unread: true,
        priority: Priority.normal,
        tone: 'Routine workflow',
        summary:
            'Payment is otherwise clear. A short legal comment is the only remaining blocker before invoice 2841 can move out of draft.',
        details: const [
          'Automated billing review finished successfully and confirmed that the amount matches the purchase order. The release is blocked only because the vendor note still says contract language is pending review.',
          'If legal confirms there are no outstanding issues, finance can ship the invoice immediately. There is no customer-facing deadline yet, but the vendor has asked us to close it this week.',
          'I kept the accounting workbook attached in case someone wants to double-check the totals before the note goes out.',
        ],
        tags: const ['Billing', 'Legal', 'Ops'],
        attachments: const ['invoice-2841.xlsx'],
        tasks: const [
          TaskItem(
            id: 31,
            title: 'Add legal note to vendor record',
            owner: 'Legal',
            due: '16:00',
            done: false,
          ),
          TaskItem(
            id: 32,
            title: 'Release invoice once note is added',
            owner: 'Finance',
            due: '16:20',
            done: false,
          ),
        ],
        timeline: const [
          TimelineItem(
            time: '09:42',
            label: 'Billing automation completed',
            note: 'Invoice passed amount and PO validation.',
          ),
          TimelineItem(
            time: '09:44',
            label: 'Legal dependency detected',
            note: 'Thread routed to finance and legal shared lane.',
          ),
          TimelineItem(
            time: '09:47',
            label: 'Release held',
            note: 'Invoice remains queued until note is attached.',
          ),
        ],
      ),
      MailItem(
        id: 4,
        sender: 'Nikita Sokolov',
        handle: 'nikita.sokolov@exec.example',
        subject: 'Board wants launch notes and readiness status before 18:00',
        preview:
            'Executive desk needs a concise rollout update with blockers, owners and the latest confidence score.',
        received: '10:03 MSK',
        route: 'Executive Desk',
        lane: Lane.internal,
        unread: true,
        priority: Priority.high,
        tone: 'Leadership request',
        summary:
            'Leadership is asking for a compact launch brief that includes blockers, named owners and whether the release can stay on the current date.',
        details: const [
          'Please send a board-ready summary before 18:00 with three things only: current launch date confidence, blockers that can still move the date, and the owner assigned to each blocker.',
          'Keep the language non-technical because this is going directly into the leadership packet. If there are any red flags for support or legal, call them out in one short line each.',
          'I do not need screenshots, only the written brief and a yes or no recommendation on whether we should keep the planned rollout slot.',
        ],
        tags: const ['Launch', 'Executive', 'Status'],
        attachments: const ['launch-checklist.pdf'],
        tasks: const [
          TaskItem(
            id: 41,
            title: 'Collect blocker updates from engineering and support',
            owner: 'Program Management',
            due: '15:00',
            done: false,
          ),
          TaskItem(
            id: 42,
            title: 'Write board-ready summary',
            owner: 'Chief of Staff',
            due: '17:00',
            done: false,
          ),
          TaskItem(
            id: 43,
            title: 'Confirm release confidence score',
            owner: 'Engineering',
            due: '14:20',
            done: true,
          ),
        ],
        timeline: const [
          TimelineItem(
            time: '10:03',
            label: 'Executive request opened',
            note: 'Board packet deadline set for end of day.',
          ),
          TimelineItem(
            time: '10:08',
            label: 'Release status requested',
            note: 'Engineering confidence score pulled from launch board.',
          ),
          TimelineItem(
            time: '10:14',
            label: 'Program manager assigned',
            note: 'Summary owner confirmed for cross-team updates.',
          ),
        ],
      ),
      MailItem(
        id: 5,
        sender: 'Support Queue',
        handle: 'vip@heliolabs.com',
        subject: 'New VIP thread: customer requests same-day onboarding rescue',
        preview:
            'The onboarding lead says their workspace is frozen and asked for an owner plus callback window in the next hour.',
        received: '10:31 MSK',
        route: 'Customer Support',
        lane: Lane.external,
        unread: true,
        priority: Priority.critical,
        tone: 'VIP rescue',
        summary:
            'Helio Labs cannot complete onboarding because user provisioning stalled after import. The team wants a callback window and a named point person in under an hour.',
        details: const [
          'The customer says admin provisioning stopped at 63 percent and no additional users can log in. They already tried restarting the import and now need a same-day rescue plan because training starts later this afternoon.',
          'Please confirm whether we can offer a callback slot before 12:00 and who will stay on point through resolution. They emphasized that a fast owner assignment matters more than a long technical explanation right now.',
          'Logs are attached from the onboarding wizard. If support needs engineering, we should make that clear in the first reply so expectations stay realistic.',
        ],
        tags: const ['VIP', 'Onboarding', 'Provisioning'],
        attachments: const ['wizard-logs.zip', 'account-roster.csv'],
        tasks: const [
          TaskItem(
            id: 51,
            title: 'Offer callback slot before noon',
            owner: 'Support',
            due: '11:05',
            done: false,
          ),
          TaskItem(
            id: 52,
            title: 'Name a single incident owner',
            owner: 'Support Lead',
            due: '10:50',
            done: false,
          ),
          TaskItem(
            id: 53,
            title: 'Review onboarding logs for provisioning failure',
            owner: 'Engineering',
            due: '11:40',
            done: false,
          ),
        ],
        timeline: const [
          TimelineItem(
            time: '10:31',
            label: 'VIP message arrived',
            note: 'Support queue elevated the thread to the rescue lane.',
          ),
          TimelineItem(
            time: '10:34',
            label: 'Priority override applied',
            note: 'SLA changed from standard to same-hour callback.',
          ),
          TimelineItem(
            time: '10:39',
            label: 'Logs attached',
            note: 'Engineering review can start without another customer ask.',
          ),
        ],
      ),
    ];
