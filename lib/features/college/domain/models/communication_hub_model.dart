class CommunicationHubDataModel {
  final List<BroadcastTab> broadcastTabs;
  final List<ActiveCampaign> activeCampaigns;
  final List<MessageHistoryItem> messageHistory;
  final List<EmailTemplate> emailTemplates;
  final List<SegmentationGroup> segmentationGroups;

  const CommunicationHubDataModel({
    required this.broadcastTabs,
    required this.activeCampaigns,
    required this.messageHistory,
    required this.emailTemplates,
    required this.segmentationGroups,
  });

  factory CommunicationHubDataModel.fromJson(Map<String, dynamic> json) {
    return CommunicationHubDataModel(
      broadcastTabs: json['broadcastTabs'] != null
          ? (json['broadcastTabs'] as List<dynamic>)
              .map((e) => BroadcastTab.fromJson(e as Map<String, dynamic>))
              .toList()
          : BroadcastTab.defaultList,
      activeCampaigns: json['activeCampaigns'] != null
          ? (json['activeCampaigns'] as List<dynamic>)
              .map((e) => ActiveCampaign.fromJson(e as Map<String, dynamic>))
              .toList()
          : ActiveCampaign.defaultList,
      messageHistory: json['messageHistory'] != null
          ? (json['messageHistory'] as List<dynamic>)
              .map((e) => MessageHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : MessageHistoryItem.defaultList,
      emailTemplates: json['emailTemplates'] != null
          ? (json['emailTemplates'] as List<dynamic>)
              .map((e) => EmailTemplate.fromJson(e as Map<String, dynamic>))
              .toList()
          : EmailTemplate.defaultList,
      segmentationGroups: json['segmentationGroups'] != null
          ? (json['segmentationGroups'] as List<dynamic>)
              .map((e) => SegmentationGroup.fromJson(e as Map<String, dynamic>))
              .toList()
          : SegmentationGroup.defaultList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'broadcastTabs': broadcastTabs.map((e) => e.toJson()).toList(),
      'activeCampaigns': activeCampaigns.map((e) => e.toJson()).toList(),
      'messageHistory': messageHistory.map((e) => e.toJson()).toList(),
      'emailTemplates': emailTemplates.map((e) => e.toJson()).toList(),
      'segmentationGroups': segmentationGroups.map((e) => e.toJson()).toList(),
    };
  }

  static CommunicationHubDataModel get mockData => CommunicationHubDataModel(
        broadcastTabs: BroadcastTab.defaultList,
        activeCampaigns: ActiveCampaign.defaultList,
        messageHistory: MessageHistoryItem.defaultList,
        emailTemplates: EmailTemplate.defaultList,
        segmentationGroups: SegmentationGroup.defaultList,
      );
}

class BroadcastTab {
  final String id;
  final String label;
  final String iconType;

  const BroadcastTab({
    required this.id,
    required this.label,
    required this.iconType,
  });

  factory BroadcastTab.fromJson(Map<String, dynamic> json) {
    return BroadcastTab(
      id: json['id'] as String? ?? 'broadcast',
      label: json['label'] as String? ?? 'Broadcast',
      iconType: json['iconType'] as String? ?? 'send',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'iconType': iconType,
      };

  static List<BroadcastTab> get defaultList => const [
        BroadcastTab(id: 'broadcast', label: 'Broadcast', iconType: 'send'),
        BroadcastTab(id: 'search', label: 'Search', iconType: 'search'),
        BroadcastTab(id: 'draft', label: 'Draft', iconType: 'fileText'),
      ];
}

class ActiveCampaign {
  final String id;
  final String title;
  final String subtitle;
  final double progress;
  final int emailCount;
  final String progressLabel;
  final List<String> tags;

  const ActiveCampaign({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.emailCount,
    required this.progressLabel,
    required this.tags,
  });

  factory ActiveCampaign.fromJson(Map<String, dynamic> json) {
    return ActiveCampaign(
      id: json['id'] as String? ?? 'c1',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      emailCount: (json['emailCount'] as num?)?.toInt() ?? 0,
      progressLabel: json['progressLabel'] as String? ?? '',
      tags: json['tags'] != null
          ? (json['tags'] as List<dynamic>).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'progress': progress,
        'emailCount': emailCount,
        'progressLabel': progressLabel,
        'tags': tags,
      };

  static List<ActiveCampaign> get defaultList => const [
        ActiveCampaign(
          id: 'c1',
          title: 'PLACEMENT DRIVE',
          subtitle: '65% Sent',
          progress: 0.65,
          emailCount: 1240,
          progressLabel: '65% Sent',
          tags: ['Senior'],
        ),
        ActiveCampaign(
          id: 'c2',
          title: 'Google EMEA \'24 Recruitment',
          subtitle: '82% Opened',
          progress: 0.82,
          emailCount: 890,
          progressLabel: '82% Opened',
          tags: ['Career', 'Tech'],
        ),
      ];
}

class MessageHistoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String status;
  final String openRate;

  const MessageHistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.openRate,
  });

  factory MessageHistoryItem.fromJson(Map<String, dynamic> json) {
    return MessageHistoryItem(
      id: json['id'] as String? ?? 'm1',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      status: json['status'] as String? ?? 'Delivered',
      openRate: json['openRate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'status': status,
        'openRate': openRate,
      };

  static List<MessageHistoryItem> get defaultList => const [
        MessageHistoryItem(
          id: 'm1',
          title: 'Internal Mock Interview Registration',
          subtitle: '142 Students - Engineering Dept',
          status: 'DELIVERED',
          openRate: '92.4% Open',
        ),
        MessageHistoryItem(
          id: 'm2',
          title: 'Holiday Notice: Diwali Break',
          subtitle: 'All Students - University-wide',
          status: 'SUCCESS',
          openRate: '98.7% Open',
        ),
        MessageHistoryItem(
          id: 'm3',
          title: 'Urgent: Accenture Doc Verification',
          subtitle: '142 Students - Selected-Accenture',
          status: 'PENDING',
          openRate: '',
        ),
      ];
}

class EmailTemplate {
  final String id;
  final String title;
  final String subtitle;
  final String iconType;

  const EmailTemplate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconType,
  });

  factory EmailTemplate.fromJson(Map<String, dynamic> json) {
    return EmailTemplate(
      id: json['id'] as String? ?? 'e1',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      iconType: json['iconType'] as String? ?? 'mail',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'iconType': iconType,
      };

  static List<EmailTemplate> get defaultList => const [
        EmailTemplate(
          id: 'e1',
          title: 'Weekly Newsletter',
          subtitle: '342 Graduating',
          iconType: 'mail',
        ),
        EmailTemplate(
          id: 'e2',
          title: 'Offer Letter Invite',
          subtitle: '142 Selected',
          iconType: 'award',
        ),
        EmailTemplate(
          id: 'e3',
          title: 'Deadline Reminder',
          subtitle: '342 Graduating',
          iconType: 'clock',
        ),
      ];
}

class SegmentationGroup {
  final String id;
  final String label;
  final List<SegmentationChip> chips;

  const SegmentationGroup({
    required this.id,
    required this.label,
    required this.chips,
  });

  factory SegmentationGroup.fromJson(Map<String, dynamic> json) {
    return SegmentationGroup(
      id: json['id'] as String? ?? 'dept',
      label: json['label'] as String? ?? '',
      chips: json['chips'] != null
          ? (json['chips'] as List<dynamic>)
              .map((e) => SegmentationChip.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'chips': chips.map((e) => e.toJson()).toList(),
      };

  static List<SegmentationGroup> get defaultList => const [
        SegmentationGroup(
          id: 'dept',
          label: 'By Department',
          chips: [
            SegmentationChip(id: 'cse', label: 'CSE (320)', isSelected: true),
            SegmentationChip(id: 'ece', label: 'ECE (250)', isSelected: false),
            SegmentationChip(id: 'mech', label: 'Mechanical (280)', isSelected: false),
          ],
        ),
        SegmentationGroup(
          id: 'batch',
          label: 'By Batch',
          chips: [
            SegmentationChip(id: '2024', label: '2024 Graduating', isSelected: true),
            SegmentationChip(id: '2025', label: '2025 Prefinal', isSelected: false),
          ],
        ),
      ];
}

class SegmentationChip {
  final String id;
  final String label;
  final bool isSelected;

  const SegmentationChip({
    required this.id,
    required this.label,
    required this.isSelected,
  });

  factory SegmentationChip.fromJson(Map<String, dynamic> json) {
    return SegmentationChip(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'isSelected': isSelected,
      };
}
