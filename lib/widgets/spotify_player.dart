import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Converts any open.spotify.com link (playlist, album, track, artist) to its
/// embeddable player URL. Returns null if the link isn't a Spotify link.
String? spotifyEmbedUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.host.contains('spotify.com')) return null;
  // Drop locale prefixes like /intl-fr/ and the /embed/ prefix if present.
  final segments = uri.pathSegments
      .where((s) => s.isNotEmpty && !s.startsWith('intl-'))
      .toList();
  final start = segments.isNotEmpty && segments.first == 'embed' ? 1 : 0;
  if (segments.length < start + 2) return null;
  final type = segments[start];
  final id = segments[start + 1];
  const supported = {'playlist', 'album', 'track', 'artist', 'show', 'episode'};
  if (!supported.contains(type)) return null;
  return 'https://open.spotify.com/embed/$type/$id?utm_source=generator&theme=0';
}

/// In-app Spotify player using Spotify's official embed widget.
/// Works without any Spotify API keys. On platforms without WebView support
/// it falls back to an "Open in Spotify" card.
class SpotifyPlayer extends StatefulWidget {
  final String url;
  final double height;

  const SpotifyPlayer({super.key, required this.url, this.height = 152});

  @override
  State<SpotifyPlayer> createState() => _SpotifyPlayerState();
}

class _SpotifyPlayerState extends State<SpotifyPlayer> {
  WebViewController? _controller;

  static bool get _webViewSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant SpotifyPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _initController();
    }
  }

  void _initController() {
    final embed = spotifyEmbedUrl(widget.url);
    if (!_webViewSupported || embed == null) {
      _controller = null;
      return;
    }
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF121212))
      ..loadRequest(Uri.parse(embed));
    setState(() => _controller = controller);
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_controller == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.music_note, color: Color(0xFF1DB954)),
          title: const Text('Workout playlist'),
          subtitle: Text(
            spotifyEmbedUrl(widget.url) == null
                ? 'Invalid Spotify link'
                : 'In-app player not supported on this platform',
            style: theme.textTheme.bodySmall,
          ),
          trailing: FilledButton.tonalIcon(
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Spotify'),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: WebViewWidget(controller: _controller!),
      ),
    );
  }
}
