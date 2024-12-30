import 'package:flutter/cupertino.dart';
import '../models/player.dart';
import '../services/player_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PlayerService _playerService = PlayerService();
  final TextEditingController _newPlayerController = TextEditingController();
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void dispose() {
    _newPlayerController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    final players = await _playerService.getPlayers();
    setState(() {
      _players = players;
    });
  }

  void _showAddPlayerDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Add New Player'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: CupertinoTextField(
            controller: _newPlayerController,
            placeholder: 'Player Name',
            autofocus: true,
            onSubmitted: (_) => _addPlayer(),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel'),
            onPressed: () {
              _newPlayerController.clear();
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text('Add'),
            onPressed: _addPlayer,
          ),
        ],
      ),
    );
  }

  void _addPlayer() async {
    if (_newPlayerController.text.trim().isEmpty) {
      return;
    }

    final success = await _playerService.addPlayer(_newPlayerController.text);
    
    if (mounted) {
      if (!success) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Duplicate Player'),
            content: const Text('A player with this name already exists.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        Navigator.pop(context);
        _loadPlayers();
      }
    }
    _newPlayerController.clear();
  }

  void _showDeleteConfirmation(Player player) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete ${player.displayName}?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Delete'),
            onPressed: () async {
              await _playerService.removePlayer(player.id);
              if (mounted) {
                Navigator.pop(context);
                _loadPlayers();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profile'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Players',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _showAddPlayerDialog,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.add_circled_solid),
                        SizedBox(width: 4),
                        Text('Add Player'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_players.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No players added yet.\nTap the Add Player button to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                      child: CupertinoListTile(
                        title: Text(
                          player.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          player.name,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                        ),
                        trailing: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            CupertinoIcons.delete,
                            color: CupertinoColors.destructiveRed,
                          ),
                          onPressed: () => _showDeleteConfirmation(player),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
} 