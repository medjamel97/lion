import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/spotify_player.dart';

/// Full-size Spotify player plus quick playlist switching.
class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final _linkCtrl = TextEditingController();

  static const _suggestions = <(String, String)>[
    ('Beast Mode', 'https://open.spotify.com/playlist/37i9dQZF1DX76Wlfdnj7AP'),
    ('Gym Phonk', 'https://open.spotify.com/playlist/37i9dQZF1DWWY64wDtewQt'),
    ('Rock Hard', 'https://open.spotify.com/playlist/37i9dQZF1DWXRqgorJj26U'),
    ('Hype', 'https://open.spotify.com/playlist/37i9dQZF1DX0vHZ8elq0UK'),
  ];

  @override
  void dispose() {
    _linkCtrl.dispose();
    super.dispose();
  }

  void _applyLink(BuildContext context, String url) {
    if (spotifyEmbedUrl(url) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'That doesn\'t look like a Spotify link (playlist, album, track or artist).')),
      );
      return;
    }
    context.read<AppState>().setSpotifyUrl(url);
    _linkCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Music',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          SpotifyPlayer(url: state.spotifyUrl, height: 360),
          const SizedBox(height: 16),
          Text('Quick playlists',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (name, url) in _suggestions)
                ChoiceChip(
                  label: Text(name),
                  selected: state.spotifyUrl == url,
                  onSelected: (_) =>
                      context.read<AppState>().setSpotifyUrl(url),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Use your own playlist',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _linkCtrl,
            decoration: InputDecoration(
              hintText: 'Paste a Spotify link…',
              prefixIcon: const Icon(Icons.link),
              suffixIcon: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _applyLink(context, _linkCtrl.text),
              ),
            ),
            onSubmitted: (v) => _applyLink(context, v),
          ),
          const SizedBox(height: 8),
          Text(
            'Any Spotify playlist, album, track or artist link works. Playback uses the official Spotify embed — log into the Spotify app for full tracks.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
