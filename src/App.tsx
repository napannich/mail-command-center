import { startTransition, useDeferredValue, useState } from 'react'
import './App.css'

type Priority = 'Critical' | 'High' | 'Normal'
type Lane = 'External' | 'Internal'
type Folder = 'Inbox' | 'Priority' | 'Team' | 'Follow up'
type Command = 'Reply draft' | 'Assign owner' | 'Escalate'

type TaskItem = {
  id: number
  title: string
  owner: string
  due: string
  done: boolean
}

type TimelineItem = {
  time: string
  label: string
  note: string
}

type MailItem = {
  id: number
  sender: string
  handle: string
  subject: string
  preview: string
  received: string
  route: string
  lane: Lane
  unread: boolean
  priority: Priority
  tone: string
  summary: string
  details: string[]
  tags: string[]
  attachments: string[]
  tasks: TaskItem[]
  timeline: TimelineItem[]
}

const initialMails: MailItem[] = [
  {
    id: 1,
    sender: 'Avery Chen',
    handle: 'avery.chen@acme-industries.com',
    subject: 'Renewal blocked until the security questionnaire is signed',
    preview:
      'Procurement says the account pauses today unless we return a signed package and name a single owner for follow-up.',
    received: '08:12 MSK',
    route: 'Revenue Ops',
    lane: 'External',
    unread: false,
    priority: 'Critical',
    tone: 'Escalated by buyer',
    summary:
      'The customer is willing to renew, but the deal will stall if we do not send a signed security packet and confirm one accountable contact before noon.',
    details: [
      'Hi team, procurement reviewed the latest renewal draft and flagged the unsigned security questionnaire. They can keep the order moving, but only if we return the signed packet today and tell them who owns the remaining answers.',
      'We also need a short response for legal explaining whether the logging retention note changed after the last redline. If it helps, I can jump on a call with your security lead right after lunch.',
      'Please treat this as time-sensitive because our internal purchasing workflow auto-closes the request at the end of the day if there is no named owner on the vendor side.',
    ],
    tags: ['Renewal', 'Security', 'Q2 close'],
    attachments: ['security-questionnaire.pdf', 'renewal-redlines.docx'],
    tasks: [
      {
        id: 11,
        title: 'Assign one accountable owner for security follow-up',
        owner: 'Revenue Ops',
        due: '11:30',
        done: true,
      },
      {
        id: 12,
        title: 'Return signed questionnaire to procurement',
        owner: 'Security',
        due: '11:45',
        done: false,
      },
      {
        id: 13,
        title: 'Draft legal note on retention language',
        owner: 'Legal',
        due: '12:10',
        done: false,
      },
    ],
    timeline: [
      {
        time: '08:12',
        label: 'Customer escalation received',
        note: 'ACME requested a signed packet and single-thread owner.',
      },
      {
        time: '08:19',
        label: 'Revenue Ops triaged',
        note: 'Thread moved into critical queue with same-day SLA.',
      },
      {
        time: '08:27',
        label: 'Security pinged',
        note: 'Owner confirmed, waiting for final signature on attachment.',
      },
    ],
  },
  {
    id: 2,
    sender: 'Marina Volkova',
    handle: 'marina.volkova@product.example',
    subject: 'Customer bug: forwarded attachments disappear from the thread',
    preview:
      'A support lead attached repro steps and wants engineering eyes before the next client call starts.',
    received: '09:05 MSK',
    route: 'Product QA',
    lane: 'Internal',
    unread: true,
    priority: 'High',
    tone: 'Needs triage',
    summary:
      'Support reproduced a forwarding bug where attachments vanish after the second handoff. The thread already has repro notes and needs an owner plus a customer-safe summary.',
    details: [
      'Support could reproduce the bug in staging twice this morning. The attachment uploads correctly in the first send, but disappears after the message is forwarded from the shared inbox.',
      'The account team has a customer call at 14:00 and asked whether we should tell them this is only a UI issue or a real file-loss scenario. We need a confident answer before then.',
      'I attached the repro checklist and a short screen recording. If someone from frontend can confirm root cause, I can prepare the comms update for support.',
    ],
    tags: ['Bug', 'Support', 'Forwarding'],
    attachments: ['repro-checklist.md', 'screen-recording.mp4'],
    tasks: [
      {
        id: 21,
        title: 'Confirm whether files are lost or only hidden in UI',
        owner: 'Frontend',
        due: '12:20',
        done: false,
      },
      {
        id: 22,
        title: 'Prepare customer-safe status note',
        owner: 'Support',
        due: '13:10',
        done: false,
      },
      {
        id: 23,
        title: 'Link thread to bug tracker',
        owner: 'Product QA',
        due: '11:50',
        done: true,
      },
    ],
    timeline: [
      {
        time: '09:05',
        label: 'Internal report landed',
        note: 'Support shared a verified staging repro and call deadline.',
      },
      {
        time: '09:11',
        label: 'Bug record attached',
        note: 'Issue linked to the QA board for noon review.',
      },
      {
        time: '09:16',
        label: 'Customer comms on hold',
        note: 'Awaiting product confirmation before outbound response.',
      },
    ],
  },
  {
    id: 3,
    sender: 'Finance Bot',
    handle: 'billing@ledger-sync.io',
    subject: 'Invoice 2841 is approved and waiting for legal note',
    preview:
      'Billing closed the payment check, but the vendor record needs one sentence from legal before the invoice can be released.',
    received: '09:42 MSK',
    route: 'Finance',
    lane: 'Internal',
    unread: true,
    priority: 'Normal',
    tone: 'Routine workflow',
    summary:
      'Payment is otherwise clear. A short legal comment is the only remaining blocker before invoice 2841 can move out of draft.',
    details: [
      'Automated billing review finished successfully and confirmed that the amount matches the purchase order. The release is blocked only because the vendor note still says contract language is pending review.',
      'If legal confirms there are no outstanding issues, finance can ship the invoice immediately. There is no customer-facing deadline yet, but the vendor has asked us to close it this week.',
      'I kept the accounting workbook attached in case someone wants to double-check the totals before the note goes out.',
    ],
    tags: ['Billing', 'Legal', 'Ops'],
    attachments: ['invoice-2841.xlsx'],
    tasks: [
      {
        id: 31,
        title: 'Add legal note to vendor record',
        owner: 'Legal',
        due: '16:00',
        done: false,
      },
      {
        id: 32,
        title: 'Release invoice once note is added',
        owner: 'Finance',
        due: '16:20',
        done: false,
      },
    ],
    timeline: [
      {
        time: '09:42',
        label: 'Billing automation completed',
        note: 'Invoice passed amount and PO validation.',
      },
      {
        time: '09:44',
        label: 'Legal dependency detected',
        note: 'Thread routed to finance and legal shared lane.',
      },
      {
        time: '09:47',
        label: 'Release held',
        note: 'Invoice remains queued until note is attached.',
      },
    ],
  },
  {
    id: 4,
    sender: 'Nikita Sokolov',
    handle: 'nikita.sokolov@exec.example',
    subject: 'Board wants launch notes and readiness status before 18:00',
    preview:
      'Executive desk needs a concise rollout update with blockers, owners and the latest confidence score.',
    received: '10:03 MSK',
    route: 'Executive Desk',
    lane: 'Internal',
    unread: true,
    priority: 'High',
    tone: 'Leadership request',
    summary:
      'Leadership is asking for a compact launch brief that includes blockers, named owners and whether the release can stay on the current date.',
    details: [
      'Please send a board-ready summary before 18:00 with three things only: current launch date confidence, blockers that can still move the date, and the owner assigned to each blocker.',
      'Keep the language non-technical because this is going directly into the leadership packet. If there are any red flags for support or legal, call them out in one short line each.',
      'I do not need screenshots, only the written brief and a yes or no recommendation on whether we should keep the planned rollout slot.',
    ],
    tags: ['Launch', 'Executive', 'Status'],
    attachments: ['launch-checklist.pdf'],
    tasks: [
      {
        id: 41,
        title: 'Collect blocker updates from engineering and support',
        owner: 'Program Management',
        due: '15:00',
        done: false,
      },
      {
        id: 42,
        title: 'Write board-ready summary',
        owner: 'Chief of Staff',
        due: '17:00',
        done: false,
      },
      {
        id: 43,
        title: 'Confirm release confidence score',
        owner: 'Engineering',
        due: '14:20',
        done: true,
      },
    ],
    timeline: [
      {
        time: '10:03',
        label: 'Executive request opened',
        note: 'Board packet deadline set for end of day.',
      },
      {
        time: '10:08',
        label: 'Release status requested',
        note: 'Engineering confidence score pulled from launch board.',
      },
      {
        time: '10:14',
        label: 'Program manager assigned',
        note: 'Summary owner confirmed for cross-team updates.',
      },
    ],
  },
  {
    id: 5,
    sender: 'Support Queue',
    handle: 'vip@heliolabs.com',
    subject: 'New VIP thread: customer requests same-day onboarding rescue',
    preview:
      'The onboarding lead says their workspace is frozen and asked for an owner plus callback window in the next hour.',
    received: '10:31 MSK',
    route: 'Customer Support',
    lane: 'External',
    unread: true,
    priority: 'Critical',
    tone: 'VIP rescue',
    summary:
      'Helio Labs cannot complete onboarding because user provisioning stalled after import. The team wants a callback window and a named point person in under an hour.',
    details: [
      'The customer says admin provisioning stopped at 63 percent and no additional users can log in. They already tried restarting the import and now need a same-day rescue plan because training starts later this afternoon.',
      'Please confirm whether we can offer a callback slot before 12:00 and who will stay on point through resolution. They emphasized that a fast owner assignment matters more than a long technical explanation right now.',
      'Logs are attached from the onboarding wizard. If support needs engineering, we should make that clear in the first reply so expectations stay realistic.',
    ],
    tags: ['VIP', 'Onboarding', 'Provisioning'],
    attachments: ['wizard-logs.zip', 'account-roster.csv'],
    tasks: [
      {
        id: 51,
        title: 'Offer callback slot before noon',
        owner: 'Support',
        due: '11:05',
        done: false,
      },
      {
        id: 52,
        title: 'Name a single incident owner',
        owner: 'Support Lead',
        due: '10:50',
        done: false,
      },
      {
        id: 53,
        title: 'Review onboarding logs for provisioning failure',
        owner: 'Engineering',
        due: '11:40',
        done: false,
      },
    ],
    timeline: [
      {
        time: '10:31',
        label: 'VIP message arrived',
        note: 'Support queue elevated the thread to the rescue lane.',
      },
      {
        time: '10:34',
        label: 'Priority override applied',
        note: 'SLA changed from standard to same-hour callback.',
      },
      {
        time: '10:39',
        label: 'Logs attached',
        note: 'Engineering review can start without another customer ask.',
      },
    ],
  },
]

const getOpenTaskCount = (mail: MailItem) =>
  mail.tasks.filter((task) => !task.done).length

const folderDefinitions: Array<{
  key: Folder
  description: string
  matches: (mail: MailItem) => boolean
}> = [
  {
    key: 'Inbox',
    description: 'All active conversations',
    matches: () => true,
  },
  {
    key: 'Priority',
    description: 'Critical and high-touch mail',
    matches: (mail) => mail.priority !== 'Normal',
  },
  {
    key: 'Team',
    description: 'Internal routing and planning threads',
    matches: (mail) => mail.lane === 'Internal',
  },
  {
    key: 'Follow up',
    description: 'Anything with unfinished tasks',
    matches: (mail) => getOpenTaskCount(mail) > 0,
  },
]

const commandMessages: Record<Command, string> = {
  'Reply draft': 'Draft the next response with the current context and open tasks.',
  'Assign owner': 'Route the thread to one accountable owner and notify the queue.',
  Escalate: 'Raise the thread into a higher-priority lane with leadership visibility.',
}

function App() {
  const [mailbox, setMailbox] = useState(initialMails)
  const [selectedFolder, setSelectedFolder] = useState<Folder>('Inbox')
  const [selectedMailId, setSelectedMailId] = useState(initialMails[0].id)
  const [query, setQuery] = useState('')
  const [activeCommand, setActiveCommand] = useState<Command>('Reply draft')

  const deferredQuery = useDeferredValue(query)
  const normalizedQuery = deferredQuery.trim().toLowerCase()
  const activeFolder =
    folderDefinitions.find((folder) => folder.key === selectedFolder) ??
    folderDefinitions[0]

  const visibleMails = mailbox.filter((mail) => {
    const folderMatch = activeFolder.matches(mail)

    if (!normalizedQuery) {
      return folderMatch
    }

    const searchableText = [
      mail.sender,
      mail.subject,
      mail.preview,
      mail.summary,
      mail.route,
      ...mail.tags,
    ]
      .join(' ')
      .toLowerCase()

    return folderMatch && searchableText.includes(normalizedQuery)
  })

  const activeMailId = visibleMails.some((mail) => mail.id === selectedMailId)
    ? selectedMailId
    : (visibleMails[0]?.id ?? 0)
  const selectedMail = visibleMails.find((mail) => mail.id === activeMailId) ?? null
  const unreadCount = mailbox.filter((mail) => mail.unread).length
  const urgentCount = mailbox.filter((mail) => mail.priority === 'Critical').length
  const openTasks = mailbox.reduce(
    (total, mail) => total + getOpenTaskCount(mail),
    0,
  )
  const teamThreads = mailbox.filter((mail) => mail.lane === 'Internal').length
  const selectedCompletedTasks = selectedMail
    ? selectedMail.tasks.filter((task) => task.done).length
    : 0
  const selectedTaskCount = selectedMail?.tasks.length ?? 0
  const completionPercent =
    selectedTaskCount > 0
      ? Math.round((selectedCompletedTasks / selectedTaskCount) * 100)
      : 0
  const nextTask = selectedMail?.tasks.find((task) => !task.done) ?? null

  const selectMail = (id: number) => {
    startTransition(() => {
      setSelectedMailId(id)
      setActiveCommand('Reply draft')
      setMailbox((currentMails) =>
        currentMails.map((mail) =>
          mail.id === id ? { ...mail, unread: false } : mail,
        ),
      )
    })
  }

  const toggleTask = (taskId: number) => {
    setMailbox((currentMails) =>
      currentMails.map((mail) => {
        if (mail.id !== activeMailId) {
          return mail
        }

        return {
          ...mail,
          tasks: mail.tasks.map((task) =>
            task.id === taskId ? { ...task, done: !task.done } : task,
          ),
        }
      }),
    )
  }

  const markVisibleAsRead = () => {
    const visibleIds = new Set(visibleMails.map((mail) => mail.id))

    if (visibleIds.size === 0) {
      return
    }

    setMailbox((currentMails) =>
      currentMails.map((mail) =>
        visibleIds.has(mail.id) ? { ...mail, unread: false } : mail,
      ),
    )
  }

  return (
    <div className="app-shell">
      <header className="topbar panel">
        <div className="topbar-copy">
          <p className="eyebrow">Mail Command Center</p>
          <h1>Inbox, opened thread, task panel.</h1>
          <p className="muted-copy">
            A single workspace for triage, reading and turning messages into
            accountable follow-up.
          </p>
        </div>

        <div className="topbar-actions">
          <div className="status-chip">Live sync active</div>
          <button
            className="secondary-button"
            type="button"
            onClick={markVisibleAsRead}
          >
            Mark visible mail as read
          </button>
        </div>
      </header>

      <section className="overview-grid">
        <article className="metric-card panel">
          <p className="metric-label">Unread</p>
          <strong className="metric-value">{unreadCount}</strong>
          <p className="metric-note">Messages still waiting for a first pass.</p>
        </article>

        <article className="metric-card panel">
          <p className="metric-label">Urgent</p>
          <strong className="metric-value">{urgentCount}</strong>
          <p className="metric-note">Critical threads that need fast routing.</p>
        </article>

        <article className="metric-card panel">
          <p className="metric-label">Open tasks</p>
          <strong className="metric-value">{openTasks}</strong>
          <p className="metric-note">
            Actions extracted from current conversations.
          </p>
        </article>

        <article className="metric-card panel">
          <p className="metric-label">Team threads</p>
          <strong className="metric-value">{teamThreads}</strong>
          <p className="metric-note">Internal planning, billing and launch mail.</p>
        </article>
      </section>

      <main className="workspace">
        <aside className="sidebar panel">
          <div className="panel-heading">
            <p className="eyebrow">Queues</p>
            <h2>{selectedFolder}</h2>
          </div>

          <div className="folder-list">
            {folderDefinitions.map((folder) => {
              const count = mailbox.filter(folder.matches).length

              return (
                <button
                  key={folder.key}
                  className={`folder-button ${
                    selectedFolder === folder.key ? 'is-active' : ''
                  }`}
                  type="button"
                  onClick={() =>
                    startTransition(() => {
                      setSelectedFolder(folder.key)
                    })
                  }
                >
                  <span className="folder-row">
                    <span className="folder-name">{folder.key}</span>
                    <span className="folder-count">{count}</span>
                  </span>
                  <span className="folder-description">{folder.description}</span>
                </button>
              )
            })}
          </div>

          <div className="info-card">
            <p className="section-label">Current action lane</p>
            <strong>{activeCommand}</strong>
            <p>{commandMessages[activeCommand]}</p>
          </div>

          <div className="info-card">
            <p className="section-label">Today&apos;s operating note</p>
            <div className="queue-row">
              <span>Critical queue SLA</span>
              <strong>15 min</strong>
            </div>
            <div className="queue-row">
              <span>Next executive deadline</span>
              <strong>18:00</strong>
            </div>
            <div className="queue-row">
              <span>VIP threads</span>
              <strong>01 active</strong>
            </div>
          </div>
        </aside>

        <section className="mail-column panel">
          <div className="panel-heading panel-heading-tight">
            <div>
              <p className="eyebrow">Mailbox</p>
              <h2>{visibleMails.length} conversations</h2>
            </div>

            <label className="search-box">
              <span className="search-label">Search</span>
              <input
                type="search"
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="sender, subject, tag"
              />
            </label>
          </div>

          <div className="mail-list">
            {visibleMails.map((mail, index) => (
              <button
                key={mail.id}
                className={`mail-card ${
                  selectedMail?.id === mail.id ? 'is-active' : ''
                }`}
                type="button"
                onClick={() => selectMail(mail.id)}
                style={{ animationDelay: `${index * 55}ms` }}
              >
                <div className="mail-card-header">
                  <div>
                    <div className="sender-row">
                      <span className="sender-name">{mail.sender}</span>
                      {mail.unread ? (
                        <span className="unread-indicator">Unread</span>
                      ) : null}
                    </div>
                    <p className="mail-subject">{mail.subject}</p>
                  </div>

                  <span
                    className={`priority-badge priority-${mail.priority.toLowerCase()}`}
                  >
                    {mail.priority}
                  </span>
                </div>

                <p className="mail-preview">{mail.preview}</p>

                <div className="mail-meta">
                  <span>{mail.received}</span>
                  <span>{mail.route}</span>
                  <span>{getOpenTaskCount(mail)} open tasks</span>
                </div>
              </button>
            ))}

            {visibleMails.length === 0 ? (
              <div className="empty-state">
                <p className="section-label">No conversations found</p>
                <h3>Try another folder or clear the search.</h3>
                <p>
                  The current filters do not match any thread in the mailbox.
                </p>
              </div>
            ) : null}
          </div>
        </section>

        <article className="detail-column panel">
          {selectedMail ? (
            <>
              <div className="panel-heading detail-heading">
                <div>
                  <p className="eyebrow">Opened message</p>
                  <h2>{selectedMail.subject}</h2>
                  <div className="mail-identity">
                    <span>{selectedMail.sender}</span>
                    <span>{selectedMail.handle}</span>
                    <span>{selectedMail.received}</span>
                  </div>
                </div>

                <div className="action-group">
                  {(['Reply draft', 'Assign owner', 'Escalate'] as Command[]).map(
                    (command) => (
                      <button
                        key={command}
                        className={`action-button ${
                          activeCommand === command ? 'is-active' : ''
                        }`}
                        type="button"
                        onClick={() => setActiveCommand(command)}
                      >
                        {command}
                      </button>
                    ),
                  )}
                </div>
              </div>

              <div className="tag-row">
                {selectedMail.tags.map((tag) => (
                  <span key={tag} className="tag-pill">
                    {tag}
                  </span>
                ))}
              </div>

              <section className="focus-brief">
                <div className="focus-copy">
                  <p className="section-label">Signal</p>
                  <p>{selectedMail.summary}</p>
                </div>

                <div className="brief-meta">
                  <div className="meta-card">
                    <span>Tone</span>
                    <strong>{selectedMail.tone}</strong>
                  </div>
                  <div className="meta-card">
                    <span>Attachments</span>
                    <strong>{selectedMail.attachments.length}</strong>
                  </div>
                </div>
              </section>

              <section className="message-stream">
                <p className="section-label">Message body</p>
                {selectedMail.details.map((paragraph) => (
                  <p key={paragraph}>{paragraph}</p>
                ))}
              </section>

              <section className="timeline">
                <p className="section-label">Activity</p>
                {selectedMail.timeline.map((entry) => (
                  <div key={entry.time + entry.label} className="timeline-item">
                    <span className="timeline-time">{entry.time}</span>
                    <div>
                      <strong>{entry.label}</strong>
                      <p>{entry.note}</p>
                    </div>
                  </div>
                ))}
              </section>

              <section className="attachments">
                <p className="section-label">Attachments</p>
                <div className="attachment-row">
                  {selectedMail.attachments.map((attachment) => (
                    <span key={attachment} className="attachment-pill">
                      {attachment}
                    </span>
                  ))}
                </div>
              </section>
            </>
          ) : (
            <div className="empty-state empty-state-spacious">
              <p className="section-label">No thread selected</p>
              <h3>Pick a conversation from the mailbox.</h3>
              <p>The open message area will show context, activity and files.</p>
            </div>
          )}
        </article>

        <aside className="task-column panel">
          {selectedMail ? (
            <>
              <div className="panel-heading panel-heading-tight">
                <div>
                  <p className="eyebrow">Task panel</p>
                  <h2>{selectedMail.route}</h2>
                </div>

                <span className="completion-pill">
                  {selectedCompletedTasks}/{selectedTaskCount} done
                </span>
              </div>

              <div className="progress-card">
                <div className="progress-track">
                  <span
                    className="progress-fill"
                    style={{ width: `${completionPercent}%` }}
                  />
                </div>
                <p>
                  {nextTask
                    ? `Next step: ${nextTask.title} by ${nextTask.due}.`
                    : 'All tasks are covered for this thread.'}
                </p>
              </div>

              <div className="task-list">
                {selectedMail.tasks.map((task) => (
                  <label
                    key={task.id}
                    className={`task-item ${task.done ? 'is-done' : ''}`}
                  >
                    <input
                      type="checkbox"
                      checked={task.done}
                      onChange={() => toggleTask(task.id)}
                    />
                    <div>
                      <strong>{task.title}</strong>
                      <p>
                        {task.owner} · due {task.due}
                      </p>
                    </div>
                  </label>
                ))}
              </div>

              <div className="info-card">
                <p className="section-label">Command note</p>
                <strong>{activeCommand}</strong>
                <p>{commandMessages[activeCommand]}</p>
              </div>

              <div className="info-card">
                <p className="section-label">Handoff status</p>
                <div className="queue-row">
                  <span>Owner lane</span>
                  <strong>{selectedMail.route}</strong>
                </div>
                <div className="queue-row">
                  <span>SLA target</span>
                  <strong>
                    {selectedMail.priority === 'Critical' ? '15 min' : '45 min'}
                  </strong>
                </div>
                <div className="queue-row">
                  <span>Attachments to review</span>
                  <strong>{selectedMail.attachments.length}</strong>
                </div>
              </div>
            </>
          ) : (
            <div className="empty-state empty-state-spacious">
              <p className="section-label">Task panel</p>
              <h3>Select mail to see tasks.</h3>
              <p>
                This area keeps owners, checklists and handoff status in one
                place.
              </p>
            </div>
          )}
        </aside>
      </main>
    </div>
  )
}

export default App
