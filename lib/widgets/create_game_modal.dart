import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../services/player_service.dart';

class CreateGameModal extends StatefulWidget {
  const CreateGameModal({super.key});

  @override
  State<CreateGameModal> createState() => _CreateGameModalState();
}

class _CreateGameModalState extends State<CreateGameModal> {
  final TextEditingController _titleController = TextEditingController();
  final PlayerService _playerService = PlayerService();
  List<Player> _availablePlayers = [];
  List<Player> _selectedPlayers = [];
  String _selectedGameType = 'Racing Demons';
  static const int maxPlayers = 10;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await _playerService.getPlayers();
    setState(() {
      _availablePlayers = players;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _startGame() {
    if (_titleController.text.isEmpty || _selectedPlayers.length < 2) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('Please enter a title and select at least 2 players.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final game = Game(
      id: const Uuid().v4(),
      title: _titleController.text,
      type: _selectedGameType,
      players: _selectedPlayers.map((p) => p.displayName).toList(),
      scores: [],
      roundWinners: [],
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      isDraftGame: true,
    );

    Navigator.pop(context); // Close modal
    Navigator.pushNamed(
      context,
      '/game',
      arguments: game,
    );
  }

  void _togglePlayer(Player player) {
    setState(() {
      if (_selectedPlayers.contains(player)) {
        _selectedPlayers.remove(player);
      } else if (_selectedPlayers.length < maxPlayers) {
        _selectedPlayers.add(player);
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Maximum Players Reached'),
            content: const Text('You cannot add more than 10 players.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'New Game',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Create'),
                  onPressed: _startGame,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CupertinoTextField(
                  controller: _titleController,
                  placeholder: 'Game Title',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CupertinoSlidingSegmentedControl<String>(
                    groupValue: _selectedGameType,
                    children: const {
                      'Racing Demons': Text('Racing Demons'),
                      '500': Text('500'),
                    },
                    onValueChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGameType = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Players',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(2-10 players)',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_availablePlayers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No players available.\nAdd players in the Profile tab.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  )
                else
                  ...List.generate(_availablePlayers.length, (index) {
                    final player = _availablePlayers[index];
                    final isSelected = _selectedPlayers.contains(player);
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoColors.separator,
                            width: 0.0,
                          ),
                        ),
                      ),
                      child: CupertinoListTile(
                        title: Text(player.displayName),
                        trailing: isSelected
                            ? const Icon(
                                CupertinoIcons.checkmark_alt_circle_fill,
                                color: CupertinoColors.activeBlue,
                              )
                            : const Icon(
                                CupertinoIcons.circle,
                                color: CupertinoColors.systemGrey3,
                              ),
                        onTap: () => _togglePlayer(player),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                if (_selectedPlayers.isNotEmpty)
                  Text(
                    'Selected: ${_selectedPlayers.map((p) => p.displayName).join(', ')}',
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 