import 'package:flutter/cupertino.dart';
import '../models/game.dart';
import '../services/storage_service.dart';

class DraftGamesPage extends StatefulWidget {
  const DraftGamesPage({super.key});

  @override
  State<DraftGamesPage> createState() => _DraftGamesPageState();
}

class _DraftGamesPageState extends State<DraftGamesPage> {
  final StorageService _storageService = StorageService();
  List<Game> _draftGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDraftGames();
  }

  Future<void> _loadDraftGames() async {
    setState(() => _isLoading = true);
    
    final draftsMap = await _storageService.getDraftGames();
    final games = draftsMap.entries
        .map((e) => Game.fromJson({...e.value as Map<String, dynamic>, 'id': e.key}))
        .toList();

    setState(() {
      _draftGames = games;
      _isLoading = false;
    });
  }

  Future<void> _deleteDraft(String gameId) async {
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Draft'),
        content: const Text('Are you sure you want to delete this draft? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ?? false;

    if (shouldDelete) {
      await _storageService.deleteDraftGame(gameId);
      _loadDraftGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Unfinished Games'),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _draftGames.isEmpty
                ? const Center(
                    child: Text(
                      'No unfinished games',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _draftGames.length,
                    itemBuilder: (context, index) {
                      final game = _draftGames[index];
                      return Dismissible(
                        key: Key(game.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: const BoxDecoration(
                            color: CupertinoColors.destructiveRed,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Icon(
                            CupertinoIcons.delete,
                            color: CupertinoColors.white,
                          ),
                        ),
                        onDismissed: (_) => _deleteDraft(game.id),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/game',
                              arguments: game,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          game.title,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.systemGrey6,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          game.type,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${game.players.length} players',
                                    style: const TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
} 