import 'dart:typed_data';
import 'package:flutter/material.dart';

class RotatingAlbumArt extends StatefulWidget {
  final Uint8List? artwork;
  final bool isPlaying;
  final double size;

  const RotatingAlbumArt({
    super.key,
    required this.artwork,
    required this.isPlaying,
    required this.size,
  });

  @override
  State<RotatingAlbumArt> createState() => _RotatingAlbumArtState();
}

class _RotatingAlbumArtState extends State<RotatingAlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(RotatingAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _rotationController.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _rotationController.stop();
    }
    // Reset rotation when artwork changes (new song)
    if (widget.artwork != oldWidget.artwork) {
      _rotationController.reset();
      if (widget.isPlaying) {
        _rotationController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: widget.isPlaying ? widget.size : widget.size * 0.88,
        height: widget.isPlaying ? widget.size : widget.size * 0.88,
        child: RotationTransition(
          turns: _rotationController,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildArtwork(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    if (widget.artwork != null) {
      return Image.memory(
        widget.artwork!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }
    return Container(
      color: const Color(0xFF2C2C2E),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Color(0xFF8E8E93),
          size: 80,
        ),
      ),
    );
  }
}
