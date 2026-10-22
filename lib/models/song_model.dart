class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String? albumArtUri;
  final int duration; // in milliseconds
  final String? data; // file path

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtUri,
    required this.duration,
    this.data,
  });

  String get durationFormatted {
    final totalSeconds = duration ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  SongModel copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    String? albumArtUri,
    int? duration,
    String? data,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtUri: albumArtUri ?? this.albumArtUri,
      duration: duration ?? this.duration,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SongModel{id: $id, title: $title, artist: $artist, album: $album}';
}
