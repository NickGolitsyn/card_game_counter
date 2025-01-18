import 'package:flutter/cupertino.dart';
import '../models/game.dart';
import '../services/storage_service.dart';
import '../widgets/create_game_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storageService = StorageService();
  List<Game> _draftGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDraftGames();
  }

  Future<void> _loadDraftGames() async {
    final draftsMap = await _storageService.getDraftGames();
    final games = draftsMap.entries
        .map((e) => Game.fromJson({...e.value as Map<String, dynamic>, 'id': e.key}))
        .toList();

    setState(() {
      _draftGames = games;
      _isLoading = false;
    });
  }

  Widget _buildDraftGamesSection() {
    if (_draftGames.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/drafts');
        if (result == 'draft_updated') {
          _loadDraftGames();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.doc_text,
                  color: CupertinoColors.systemIndigo,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unfinished Games',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_draftGames.length} ${_draftGames.length == 1 ? 'game' : 'games'} in progress',
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start a New Game',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final result = await showCupertinoModalPopup(
                          context: context,
                          builder: (context) => const CreateGameModal(gameType: 'Racing Demons'),
                        );
                        if (result == 'draft_updated') {
                          _loadDraftGames();
                        }
                      },
                      child: Container(
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemIndigo,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Icon(
                              CupertinoIcons.suit_spade_fill,
                              size: 48,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 24),
                            const Text(
                              'Racing Demons',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final result = await showCupertinoModalPopup(
                          context: context,
                          builder: (context) => const CreateGameModal(gameType: '500'),
                        );
                        if (result == 'draft_updated') {
                          _loadDraftGames();
                        }
                      },
                      child: Container(
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemPink,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Icon(
                              CupertinoIcons.suit_heart_fill,
                              size: 48,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 24),
                            const Text(
                              '500',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildDraftGamesSection(),
                  ],
                ),
              ),
      ),
    );
  }
} 