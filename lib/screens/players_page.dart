import 'package:flutter/cupertino.dart';
import '../models/player.dart';
import '../services/player_service.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final PlayerService _playerService = PlayerService();
  final TextEditingController _newPlayerController = TextEditingController();
  List<Player> _players = [];
  bool _isLoading = true;

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
      _isLoading = false;
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Players'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _showAddPlayerDialog,
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _players.isEmpty
                ? const Center(
                    child: Text(
                      'No players added yet.\nTap + to add a player.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      final player = _players[index];
                      return Container(
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
    );
  }
} 