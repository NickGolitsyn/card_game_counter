import 'package:flutter/cupertino.dart';
import '../services/storage_service.dart';
import '../services/player_service.dart';
import 'players_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StorageService _storageService = StorageService();
  final PlayerService _playerService = PlayerService();
  int _playerCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayerCount();
  }

  Future<void> _loadPlayerCount() async {
    final players = await _playerService.getPlayers();
    setState(() {
      _playerCount = players.length;
      _isLoading = false;
    });
  }

  void _showClearDataConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all players, games, and settings. This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Clear All'),
            onPressed: () async {
              await _storageService.clearAllData();
              if (mounted) {
                Navigator.pop(context);
                _loadPlayerCount();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const PlayersPage(),
          ),
        ).then((_) => _loadPlayerCount());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  const Text(
                    'Players',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$_playerCount ${_playerCount == 1 ? 'player' : 'players'} registered',
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        children: [
          CupertinoListTile(
            title: const Text('Clear All Data'),
            trailing: const Icon(CupertinoIcons.delete),
            onTap: _showClearDataConfirmation,
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
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView(
                children: [
                  const SizedBox(height: 16),
                  _buildPlayersSection(),
                  _buildSettingsSection(),
                ],
              ),
      ),
    );
  }
} 