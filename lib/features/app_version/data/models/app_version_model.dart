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

  /// Normalize version string (remove leading 'v' if present)
  String getNormalizedVersion() {
    return versionNumber.startsWith('v')
        ? versionNumber.substring(1)
        : versionNumber;
  }

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    final versionNum = json['versionNumber'] ?? json['version'];
    final buildNum = json['buildNumber'] ?? json['buildNumber'];
    final plat = json['platform'] ?? 'android';

    return AppVersionModel(
      versionNumber: (versionNum as String).trim(),
      buildNumber: buildNum is int ? buildNum : null,
      platform: (plat as String).toLowerCase().trim(),
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

  @override
  String toString() =>
      'AppVersionModel(v$versionNumber, platform: $platform, forceUpdate: $forceUpdate)';
}
