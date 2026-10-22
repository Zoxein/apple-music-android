import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model.dart';

enum RepeatMode { none, all, one }

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PositionData(this.position, this.bufferedPosition, this.duration);
}

class MusicProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<SongModel> _songs = [];
  List<SongModel> _filteredSongs = [];
  SongModel? _currentSong;
  int _currentIndex = -1;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.none;
  bool _isLiked = false;
  bool _permissionGranted = false;

  Color _dominantColor = const Color(0xFF1C1C1E);
  Color _vibrantColor = const Color(0xFFFA2D48);
  Uint8List? _currentArtwork;

  List<int> _shuffleOrder = [];

  // Getters
  List<SongModel> get songs => _songs;
  List<SongModel> get filteredSongs => _filteredSongs;
  SongModel? get currentSong => _currentSong;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;
  bool get isLiked => _isLiked;
  bool get permissionGranted => _permissionGranted;
  Color get dominantColor => _dominantColor;
  Color get vibrantColor => _vibrantColor;
  Uint8List? get currentArtwork => _currentArtwork;
  AudioPlayer get audioPlayer => _audioPlayer;

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );

  MusicProvider() {
    _init();
  }

  Future<void> _init() async {
    _setupAudioPlayerListeners();
    await requestPermission();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onSongCompleted();
      }
    });
  }

  Future<void> requestPermission() async {
    _isLoading = true;
    notifyListeners();

    bool granted = false;

    // Try Android 13+ permission first
    final audioPermission = await Permission.audio.request();
    if (audioPermission.isGranted) {
      granted = true;
    } else {
      // Fallback for older Android versions
      final storagePermission = await Permission.storage.request();
      if (storagePermission.isGranted) {
        granted = true;
      }
    }

    _permissionGranted = granted;
    if (granted) {
      await loadSongs();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final songList = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      _songs = songList
          .where((s) => s.duration != null && s.duration! > 30000)
          .map((s) => SongModel(
                id: s.id,
                title: s.title,
                artist: s.artist ?? 'Unknown Artist',
                album: s.album ?? 'Unknown Album',
                duration: s.duration ?? 0,
                data: s.data,
              ))
          .toList();

      _filteredSongs = List.from(_songs);
    } catch (e) {
      debugPrint('Error loading songs: $e');
      _songs = [];
      _filteredSongs = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchSongs(String query) {
    if (query.isEmpty) {
      _filteredSongs = List.from(_songs);
    } else {
      final q = query.toLowerCase();
      _filteredSongs = _songs.where((s) {
        return s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> playSong(SongModel song, {List<SongModel>? queue}) async {
    final playQueue = queue ?? _songs;
    _currentIndex = playQueue.indexWhere((s) => s.id == song.id);
    if (_currentIndex == -1) {
      _currentIndex = 0;
    }

    if (queue != null) {
      _songs = List.from(queue);
    }

    _currentSong = song;
    _isLiked = false;

    if (_isShuffle) {
      _buildShuffleOrder();
    }

    try {
      await _audioPlayer.setFilePath(song.data!);
      await _audioPlayer.play();
      await _loadArtwork(song);
    } catch (e) {
      debugPrint('Error playing song: $e');
    }

    notifyListeners();
  }

  Future<void> _loadArtwork(SongModel song) async {
    try {
      final artwork = await _audioQuery.queryArtwork(
        song.id,
        ArtworkType.AUDIO,
        quality: 100,
        size: 500,
      );
      _currentArtwork = artwork;

      if (artwork != null) {
        await _extractColors(artwork);
      } else {
        _dominantColor = const Color(0xFF1C1C1E);
        _vibrantColor = const Color(0xFFFA2D48);
      }
    } catch (e) {
      _dominantColor = const Color(0xFF1C1C1E);
      _vibrantColor = const Color(0xFFFA2D48);
    }
    notifyListeners();
  }

  Future<void> _extractColors(Uint8List imageBytes) async {
    try {
      final image = MemoryImage(imageBytes);
      final generator = await PaletteGenerator.fromImageProvider(
        image,
        size: const Size(200, 200),
      );

      _dominantColor =
          generator.dominantColor?.color ?? const Color(0xFF1C1C1E);

      final vibrant = generator.vibrantColor?.color;
      final darkVibrant = generator.darkVibrantColor?.color;
      final muted = generator.mutedColor?.color;

      _vibrantColor =
          vibrant ?? darkVibrant ?? muted ?? const Color(0xFFFA2D48);

      // Darken colors for background use
      _dominantColor = _darkenColor(_dominantColor, 0.4);
    } catch (e) {
      _dominantColor = const Color(0xFF1C1C1E);
      _vibrantColor = const Color(0xFFFA2D48);
    }
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.05, 0.35))
        .toColor();
  }

  Future<Uint8List?> getArtworkForSong(int songId) async {
    try {
      return await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        quality: 100,
        size: 300,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> playNext() async {
    if (_songs.isEmpty) return;

    int nextIndex;
    if (_isShuffle && _shuffleOrder.isNotEmpty) {
      final currentShufflePos = _shuffleOrder.indexOf(_currentIndex);
      if (currentShufflePos < _shuffleOrder.length - 1) {
        nextIndex = _shuffleOrder[currentShufflePos + 1];
      } else {
        nextIndex = _shuffleOrder[0];
      }
    } else {
      nextIndex = (_currentIndex + 1) % _songs.length;
    }

    _currentIndex = nextIndex;
    await playSong(_songs[nextIndex]);
  }

  Future<void> playPrevious() async {
    if (_songs.isEmpty) return;

    // If more than 3 seconds in, restart the song
    if (_audioPlayer.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      return;
    }

    int prevIndex;
    if (_isShuffle && _shuffleOrder.isNotEmpty) {
      final currentShufflePos = _shuffleOrder.indexOf(_currentIndex);
      if (currentShufflePos > 0) {
        prevIndex = _shuffleOrder[currentShufflePos - 1];
      } else {
        prevIndex = _shuffleOrder.last;
      }
    } else {
      prevIndex = (_currentIndex - 1 + _songs.length) % _songs.length;
    }

    _currentIndex = prevIndex;
    await playSong(_songs[prevIndex]);
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle) {
      _buildShuffleOrder();
    }
    notifyListeners();
  }

  void _buildShuffleOrder() {
    _shuffleOrder = List.generate(_songs.length, (i) => i)
      ..remove(_currentIndex)
      ..shuffle();
    _shuffleOrder.insert(0, _currentIndex);
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }

  void toggleLike() {
    _isLiked = !_isLiked;
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  void _onSongCompleted() {
    if (_repeatMode == RepeatMode.one) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else {
      playNext();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
