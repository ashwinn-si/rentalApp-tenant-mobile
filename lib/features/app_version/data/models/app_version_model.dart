class AppVersionModel {
  final String versionNumber;
  final int? buildNumber;
  final String platform;
  final bool forceUpdate;
  final String releaseNotes;

  const AppVersionModel({
    required this.versionNumber,
    required this.buildNumber,
    required this.platform,
    required this.forceUpdate,
    required this.releaseNotes,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      versionNumber: json['versionNumber'] as String,
      buildNumber: json['buildNumber'] as int?,
      platform: json['platform'] as String,
      forceUpdate: (json['forceUpdate'] as bool?) ?? false,
      releaseNotes: (json['releaseNotes'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionNumber': versionNumber,
      'buildNumber': buildNumber,
      'platform': platform,
      'forceUpdate': forceUpdate,
      'releaseNotes': releaseNotes,
    };
  }
}
