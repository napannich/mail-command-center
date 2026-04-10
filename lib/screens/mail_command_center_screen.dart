import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/initial_mails.dart';
import '../models/mail_models.dart';
import '../theme/app_theme.dart';

class MailCommandCenterScreen extends StatefulWidget {
  const MailCommandCenterScreen({super.key});

  @override
  State<MailCommandCenterScreen> createState() => _MailCommandCenterScreenState();
}

class _MailCommandCenterScreenState extends State<MailCommandCenterScreen> {
  late List<MailItem> _mailbox;
  MailFolder _selectedFolder = MailFolder.inbox;
  int _selectedMailId = 1;
  String _query = '';
  Command _activeCommand = Command.replyDraft;

  @override
  void initState() {
    super.initState();
    _mailbox = List<MailItem>.from(initialMails());
    _selectedMailId = _mailbox.first.id;
  }

  FolderDef get _activeFolder =>
      mailFolderDefinitions.firstWhere((f) => f.key == _selectedFolder);

  List<MailItem> get _visibleMails {
    final q = _query.trim().toLowerCase();
    return _mailbox.where((mail) {
      final folderMatch = _activeFolder.matches(mail);
      if (q.isEmpty) return folderMatch;
      final hay = [
        mail.sender,
        mail.subject,
        mail.preview,
        mail.summary,
        mail.route,
        ...mail.tags,
      ].join(' ').toLowerCase();
      return folderMatch && hay.contains(q);
    }).toList();
  }

  int get _activeMailId {
    final visible = _visibleMails;
    if (visible.any((m) => m.id == _selectedMailId)) return _selectedMailId;
    return visible.isEmpty ? 0 : visible.first.id;
  }

  MailItem? get _selectedMail {
    if (_activeMailId == 0) return null;
    try {
      return _mailbox.firstWhere((m) => m.id == _activeMailId);
    } catch (_) {
      return null;
    }
  }

  void _selectMail(int id) {
    setState(() {
      _selectedMailId = id;
      _activeCommand = Command.replyDraft;
      _mailbox = _mailbox
          .map((m) => m.id == id ? m.copyWith(unread: false) : m)
          .toList();
    });
  }

  void _toggleTask(int taskId) {
    final id = _activeMailId;
    setState(() {
      _mailbox = _mailbox.map((mail) {
        if (mail.id != id) return mail;
        final tasks = mail.tasks
            .map((t) => t.id == taskId ? t.copyWith(done: !t.done) : t)
            .toList();
        return mail.copyWith(tasks: tasks);
      }).toList();
    });
  }

  void _markVisibleAsRead() {
    final ids = _visibleMails.map((m) => m.id).toSet();
    if (ids.isEmpty) return;
    setState(() {
      _mailbox = _mailbox
          .map((m) => ids.contains(m.id) ? m.copyWith(unread: false) : m)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selectedMail;
    final visible = _visibleMails;
    final unreadCount = _mailbox.where((m) => m.unread).length;
    final urgentCount = _mailbox.where((m) => m.priority == Priority.critical).length;
    final openTasks = _mailbox.fold<int>(0, (t, m) => t + openTaskCount(m));
    final teamThreads = _mailbox.where((m) => m.lane == Lane.internal).length;

    final w = MediaQuery.sizeOf(context).width;
    final pad = w < 720 ? 16.0 : 28.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 0, maxWidth: 1500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  onMarkRead: _markVisibleAsRead,
                  theme: theme,
                ),
                const SizedBox(height: 24),
                _MetricsRow(
                  unread: unreadCount,
                  urgent: urgentCount,
                  openTasks: openTasks,
                  teamThreads: teamThreads,
                  wide: w >= 1120,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: (w < 720 ? 1400.0 : 760.0).clamp(600.0, 900.0),
                  child: _WorkspaceLayout(
                    width: constraints.maxWidth,
                    sidebar: _buildSidebar(theme),
                    mailbox: _buildMailbox(theme, visible, selected),
                    detail: _buildDetail(theme, selected),
                    tasks: _buildTaskColumn(theme, selected),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _eyebrow('Queues'),
          Text(_selectedFolder.label, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                for (final folder in mailFolderDefinitions)
                  _FolderTile(
                    label: folder.key.label,
                    description: folder.description,
                    count: _mailbox.where(folder.matches).length,
                    active: folder.key == _selectedFolder,
                    onTap: () => setState(() => _selectedFolder = folder.key),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('Current action lane'),
                Text(_activeCommand.label,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_activeCommand.message, style: TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow("Today's operating note"),
                _queueRow('Critical queue SLA', '15 min'),
                _queueRow('Next executive deadline', '18:00'),
                _queueRow('VIP threads', '01 active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMailbox(ThemeData theme, List<MailItem> visible, MailItem? selected) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('Mailbox'),
                    Text('${visible.length} conversations',
                        style: theme.textTheme.headlineSmall),
                  ],
                ),
              ),
              SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('Search'),
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'sender, subject, tag',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.85),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.panelBorder),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: visible.isEmpty
                ? _emptyMailbox(theme)
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final mail = visible[i];
                      final active = selected?.id == mail.id;
                      return _MailCard(
                        mail: mail,
                        active: active,
                        onTap: () => _selectMail(mail.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyMailbox(ThemeData theme) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('No conversations found'),
          Text('Try another folder or clear the search.',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'The current filters do not match any thread in the mailbox.',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(ThemeData theme, MailItem? mail) {
    if (mail == null) {
      return _Panel(
        child: _emptyState(
          theme,
          'No thread selected',
          'Pick a conversation from the mailbox.',
          'The open message area will show context, activity and files.',
        ),
      );
    }

    return _Panel(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _eyebrow('Opened message'),
                      Text(mail.subject,
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Text(mail.sender,
                              style: const TextStyle(color: AppColors.muted)),
                          Text(mail.handle,
                              style: const TextStyle(color: AppColors.muted)),
                          Text(mail.received,
                              style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final cmd in Command.values)
                      _ActionChip(
                        label: cmd.label,
                        active: _activeCommand == cmd,
                        onTap: () =>
                            setState(() => _activeCommand = cmd),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in mail.tags) _TagPill(tag),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _eyebrow('Signal'),
                        Text(mail.summary,
                            style: const TextStyle(
                                color: AppColors.muted, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      _metaCard('Tone', mail.tone),
                      const SizedBox(height: 12),
                      _metaCard(
                          'Attachments', '${mail.attachments.length}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _eyebrow('Message body'),
                  for (final p in mail.details) ...[
                    Text(p,
                        style: const TextStyle(
                            color: AppColors.muted, height: 1.7)),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _eyebrow('Activity'),
                  for (final e in mail.timeline) ...[
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(e.time,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF85644F))),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkStrong)),
                              Text(e.note,
                                  style: const TextStyle(
                                      color: AppColors.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _eyebrow('Attachments'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final a in mail.attachments)
                        _AttachmentPill(a),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskColumn(ThemeData theme, MailItem? mail) {
    if (mail == null) {
      return _Panel(
        child: _emptyState(
          theme,
          'Task panel',
          'Select mail to see tasks.',
          'This area keeps owners, checklists and handoff status in one place.',
        ),
      );
    }

    final done = mail.tasks.where((t) => t.done).length;
    final total = mail.tasks.length;
    final nextList = mail.tasks.where((t) => !t.done).toList();
    final next = nextList.isEmpty ? null : nextList.first;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('Task panel'),
                    Text(mail.route, style: theme.textTheme.headlineSmall),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$done/$total done',
                  style: const TextStyle(
                    color: AppColors.tealDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: total > 0 ? done / total : 0,
                    minHeight: 12,
                    backgroundColor:
                        AppColors.teal.withValues(alpha: 0.12),
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  next != null
                      ? 'Next step: ${next.title} by ${next.due}.'
                      : 'All tasks are covered for this thread.',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                for (final task in mail.tasks)
                  _TaskTile(
                    task: task,
                    onToggle: () => _toggleTask(task.id),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('Command note'),
                Text(_activeCommand.label,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_activeCommand.message,
                    style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('Handoff status'),
                _queueRow('Owner lane', mail.route),
                _queueRow(
                    'SLA target',
                    mail.priority == Priority.critical
                        ? '15 min'
                        : '45 min'),
                _queueRow('Attachments to review',
                    '${mail.attachments.length}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(
      ThemeData theme, String label, String title, String body) {
    return Center(
      child: _InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _eyebrow(label),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _metaCard(String k, String v) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              color: AppColors.eyebrow,
            ),
          ),
          const SizedBox(height: 8),
          Text(v,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.inkStrong)),
        ],
      ),
    );
  }

  Widget _queueRow(String a, String b) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(child: Text(a, style: const TextStyle(color: Color(0xFF65615B)))),
          Text(b, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _eyebrow(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        t.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.8,
          color: AppColors.eyebrow,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMarkRead, required this.theme});

  final VoidCallback onMarkRead;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xF0F9F5EC),
            const Color(0xCCFFFAF3),
          ],
        ),
        border: Border.all(color: AppColors.panelBorder),
        boxShadow: const [
          BoxShadow(
            blurRadius: 40,
            offset: Offset(0, 18),
            color: Color(0x144E3D2D),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrowStatic('Mail Command Center'),
                Text(
                  'Inbox, opened thread, task panel.',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 14),
                const Text(
                  'A single workspace for triage, reading and turning messages into accountable follow-up.',
                  style: TextStyle(color: AppColors.mutedLight, height: 1.65),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Live sync active',
                  style: TextStyle(
                    color: AppColors.tealDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onMarkRead,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppColors.panelBorder),
                  backgroundColor: Colors.white.withValues(alpha: 0.75),
                ),
                child: const Text('Mark visible mail as read'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _eyebrowStatic(String t) {
    return Text(
      t.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.8,
        color: AppColors.eyebrow,
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.unread,
    required this.urgent,
    required this.openTasks,
    required this.teamThreads,
    required this.wide,
  });

  final int unread;
  final int urgent;
  final int openTasks;
  final int teamThreads;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cols = wide ? 4 : 2;
    final metrics = [
      ('Unread', '$unread', 'Messages still waiting for a first pass.'),
      ('Urgent', '$urgent', 'Critical threads that need fast routing.'),
      ('Open tasks', '$openTasks', 'Actions extracted from current conversations.'),
      ('Team threads', '$teamThreads', 'Internal planning, billing and launch mail.'),
    ];

    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: wide ? 1.4 : 1.2,
      children: [
        for (final m in metrics)
          _MetricCard(title: m.$1, value: m.$2, note: m.$3),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.note,
  });

  final String title;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      padding: 22,
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.8,
              color: AppColors.eyebrow,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.libreBaskerville(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D2527),
            ),
          ),
          const SizedBox(height: 8),
          Text(note, style: const TextStyle(color: AppColors.mutedLight, height: 1.55)),
        ],
      ),
    );
  }
}

class _WorkspaceLayout extends StatelessWidget {
  const _WorkspaceLayout({
    required this.width,
    required this.sidebar,
    required this.mailbox,
    required this.detail,
    required this.tasks,
  });

  final double width;
  final Widget sidebar;
  final Widget mailbox;
  final Widget detail;
  final Widget tasks;

  @override
  Widget build(BuildContext context) {
    if (width < 720) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 380, child: sidebar),
          const SizedBox(height: 18),
          SizedBox(height: 360, child: mailbox),
          const SizedBox(height: 18),
          SizedBox(height: 520, child: detail),
          const SizedBox(height: 18),
          SizedBox(height: 420, child: tasks),
        ],
      );
    }
    if (width < 1120) {
      return Column(
        children: [
          SizedBox(
            height: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 240, child: sidebar),
                const SizedBox(width: 18),
                Expanded(child: mailbox),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: detail),
                const SizedBox(width: 18),
                SizedBox(width: 300, child: tasks),
              ],
            ),
          ),
        ],
      );
    }
    if (width < 1380) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 240, child: sidebar),
          const SizedBox(width: 18),
          Expanded(
            flex: 340,
            child: Column(
              children: [
                Expanded(child: mailbox),
                const SizedBox(height: 18),
                Expanded(child: tasks),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(child: detail),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 250, child: sidebar),
        const SizedBox(width: 18),
        SizedBox(width: 340, child: mailbox),
        const SizedBox(width: 18),
        Expanded(child: detail),
        const SizedBox(width: 18),
        SizedBox(width: 320, child: tasks),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = 22,
    this.radius = 28,
  });

  final Widget child;
  final double padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xD2FFFBF5),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.panelBorder),
        boxShadow: const [
          BoxShadow(
            blurRadius: 40,
            offset: Offset(0, 18),
            color: Color(0x144E3D2D),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.74),
            const Color(0xD2F8F2E9),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x1F756453)),
      ),
      child: child,
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.label,
    required this.description,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String description;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: active
            ? null
            : const Color(0xB8F4EDE4),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: active
                  ? const LinearGradient(
                      colors: [AppColors.teal, AppColors.tealDark],
                    )
                  : null,
              boxShadow: active
                  ? const [
                      BoxShadow(
                        blurRadius: 28,
                        offset: Offset(0, 18),
                        color: Color(0x38175E57),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: active ? const Color(0xFFF5F3EE) : AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(
                        color: active
                            ? const Color(0xC7F5F3EE)
                            : AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    height: 1.45,
                    color: active
                        ? const Color(0xC7F5F3EE)
                        : const Color(0xFF6D665E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MailCard extends StatelessWidget {
  const _MailCard({
    required this.mail,
    required this.active,
    required this.onTap,
  });

  final MailItem mail;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pri = mail.priority;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: active
                    ? AppColors.teal.withValues(alpha: 0.45)
                    : const Color(0x1F756453),
                width: active ? 1.5 : 1,
              ),
              gradient: LinearGradient(
                colors: active
                    ? const [
                        Color(0xE2E2F4F0),
                        Color(0xE0F7F0E7),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.72),
                        const Color(0xCCC5ECE2),
                      ],
              ),
              boxShadow: active
                  ? const [
                      BoxShadow(
                        blurRadius: 32,
                        offset: Offset(0, 18),
                        color: Color(0x1F224845),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                mail.sender,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.inkStrong),
                              ),
                              if (mail.unread) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.unreadBg,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Unread',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.unreadFg,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mail.subject,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: AppColors.inkStrong,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _PriorityBadge(priority: pri),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  mail.preview,
                  style: const TextStyle(color: AppColors.muted, height: 1.58),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  children: [
                    Text(mail.received,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted)),
                    Text(mail.route,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted)),
                    Text('${openTaskCount(mail)} open tasks',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (priority) {
      Priority.critical => (AppColors.criticalBg, AppColors.criticalFg),
      Priority.high => (AppColors.highBg, AppColors.highFg),
      Priority.normal => (AppColors.normalBg, AppColors.normalFg),
    };
    return Container(
      constraints: const BoxConstraints(minWidth: 76),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill(this.tag);

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.tealDark,
        ),
      ),
    );
  }
}

class _AttachmentPill extends StatelessWidget {
  const _AttachmentPill(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1F756453)),
      ),
      child: Text(name,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF243134))),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor:
            active ? AppColors.teal : Colors.white.withValues(alpha: 0.75),
        foregroundColor: active ? const Color(0xFFF7F3EE) : AppColors.ink,
        elevation: active ? 4 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onToggle});

  final TaskItem task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: task.done
            ? const Color(0xB8DFEEE9)
            : const Color(0xC7F8F1E7),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: task.done,
                  onChanged: (_) => onToggle(),
                  activeColor: AppColors.teal,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkStrong,
                          decoration: task.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${task.owner} · due ${task.due}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
