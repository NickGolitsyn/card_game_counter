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

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/drafts');
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
        ),
      ],
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDraftGamesSection(),
                    CupertinoButton.filled(
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => const CreateGameModal(),
                        );
                      },
                      child: const Text('Create New Game'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
} 