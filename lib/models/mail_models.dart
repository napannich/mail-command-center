enum Priority { critical, high, normal }

enum Lane { external, internal }

enum MailFolder { inbox, priority, team, followUp }

enum Command { replyDraft, assignOwner, escalate }

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.owner,
    required this.due,
    required this.done,
  });

  final int id;
  final String title;
  final String owner;
  final String due;
  final bool done;

  TaskItem copyWith({bool? done}) =>
      TaskItem(id: id, title: title, owner: owner, due: due, done: done ?? this.done);
}

class TimelineItem {
  const TimelineItem({
    required this.time,
    required this.label,
    required this.note,
  });

  final String time;
  final String label;
  final String note;
}

class MailItem {
  const MailItem({
    required this.id,
    required this.sender,
    required this.handle,
    required this.subject,
    required this.preview,
    required this.received,
    required this.route,
    required this.lane,
    required this.unread,
    required this.priority,
    required this.tone,
    required this.summary,
    required this.details,
    required this.tags,
    required this.attachments,
    required this.tasks,
    required this.timeline,
  });

  final int id;
  final String sender;
  final String handle;
  final String subject;
  final String preview;
  final String received;
  final String route;
  final Lane lane;
  final bool unread;
  final Priority priority;
  final String tone;
  final String summary;
  final List<String> details;
  final List<String> tags;
  final List<String> attachments;
  final List<TaskItem> tasks;
  final List<TimelineItem> timeline;

  MailItem copyWith({
    bool? unread,
    List<TaskItem>? tasks,
  }) =>
      MailItem(
        id: id,
        sender: sender,
        handle: handle,
        subject: subject,
        preview: preview,
        received: received,
        route: route,
        lane: lane,
        unread: unread ?? this.unread,
        priority: priority,
        tone: tone,
        summary: summary,
        details: details,
        tags: tags,
        attachments: attachments,
        tasks: tasks ?? this.tasks,
        timeline: timeline,
      );
}

int openTaskCount(MailItem mail) => mail.tasks.where((t) => !t.done).length;

class FolderDef {
  const FolderDef({
    required this.key,
    required this.description,
    required this.matches,
  });

  final MailFolder key;
  final String description;
  final bool Function(MailItem) matches;
}

final List<FolderDef> mailFolderDefinitions = [
  FolderDef(
    key: MailFolder.inbox,
    description: 'All active conversations',
    matches: (_) => true,
  ),
  FolderDef(
    key: MailFolder.priority,
    description: 'Critical and high-touch mail',
    matches: (m) => m.priority != Priority.normal,
  ),
  FolderDef(
    key: MailFolder.team,
    description: 'Internal routing and planning threads',
    matches: (m) => m.lane == Lane.internal,
  ),
  FolderDef(
    key: MailFolder.followUp,
    description: 'Anything with unfinished tasks',
    matches: (m) => openTaskCount(m) > 0,
  ),
];

extension MailFolderLabel on MailFolder {
  String get label => switch (this) {
        MailFolder.inbox => 'Inbox',
        MailFolder.priority => 'Priority',
        MailFolder.team => 'Team',
        MailFolder.followUp => 'Follow up',
      };
}

extension CommandLabel on Command {
  String get label => switch (this) {
        Command.replyDraft => 'Reply draft',
        Command.assignOwner => 'Assign owner',
        Command.escalate => 'Escalate',
      };

  String get message => switch (this) {
        Command.replyDraft =>
          'Draft the next response with the current context and open tasks.',
        Command.assignOwner =>
          'Route the thread to one accountable owner and notify the queue.',
        Command.escalate =>
          'Raise the thread into a higher-priority lane with leadership visibility.',
      };
}

extension PriorityStyle on Priority {
  String get label => switch (this) {
        Priority.critical => 'Critical',
        Priority.high => 'High',
        Priority.normal => 'Normal',
      };
}
