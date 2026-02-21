class Compliance {
  final String id;
  final String? employeeId;
  final String title;
  final String complianceType;
  final String description;
  final String status;
  final DateTime dueDate;
  final String? note;
  final List<RequiredDocument> requiredDocuments;
  final List<ActionLink> actionLinks;
  final List<SubmittedDocument> submittedDocuments;

  Compliance({
    required this.id,
    this.employeeId,

    required this.title,
    required this.complianceType,
    required this.description,
    required this.status,
    required this.dueDate,
    this.note,
    this.requiredDocuments = const [],
    this.actionLinks = const [],
    this.submittedDocuments = const [],
  });

  // ---------------- FROM JSON ----------------
  factory Compliance.fromJson(Map<String, dynamic> json) {
    return Compliance(
      id: json['complianceId'] ?? json['_id'] ?? '',
      employeeId: json['employeeId']?.toString(),
      complianceType: json['complianceType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      note: json['note'],

      // Required documents (API sends list of strings)
      requiredDocuments: (json['requiredDocuments'] as List?)
              ?.map((e) => RequiredDocument(name: e.toString()))
              .toList() ??
          [],

      // Action links
      actionLinks: (json['actionLinks'] as List?)
              ?.map((e) => ActionLink.fromJson(e))
              .toList() ??
          [],

      // Submitted documents (API sends list of URLs)
      submittedDocuments: (json['submittedDocuments'] as List?)
              ?.map((e) => SubmittedDocument(
                    name: e.toString().split('/').last,
                    url: e.toString(),
                  ))
              .toList() ??
          [],
    );
  }

  // ---------------- TO JSON (FOR LOCAL CACHE) ----------------
  Map<String, dynamic> toJson() {
    return {
      'complianceId': id,
      'employeeId' : employeeId,
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'note': note,
      'requiredDocuments':
          requiredDocuments.map((e) => e.name).toList(),
      'actionLinks':
          actionLinks.map((e) => e.toJson()).toList(),
      'submittedDocuments':
          submittedDocuments.map((e) => e.url).toList(),
    };
  }
}

// ============================================================
// REQUIRED DOCUMENT
// ============================================================

class RequiredDocument {
  final String name;

  RequiredDocument({required this.name});

  factory RequiredDocument.fromJson(dynamic json) {
    return RequiredDocument(name: json.toString());
  }

  dynamic toJson() => name;
}

// ============================================================
// ACTION LINK
// ============================================================

class ActionLink {
  final String title;
  final String url;

  ActionLink({
    required this.title,
    required this.url,
  });

  factory ActionLink.fromJson(Map<String, dynamic> json) {
    return ActionLink(
      title: json['label'] ?? json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
    };
  }
}

// ============================================================
// SUBMITTED DOCUMENT
// ============================================================

class SubmittedDocument {
  final String name;
  final String url;

  SubmittedDocument({
    required this.name,
    required this.url,
  });

  factory SubmittedDocument.fromJson(dynamic json) {
    final url = json.toString();
    return SubmittedDocument(
      name: url.split('/').last,
      url: url,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }
}