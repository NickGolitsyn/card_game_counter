import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../services/stats_service.dart';
import '../services/storage_service.dart';
import '../widgets/pill_tab_selector.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final StatsService _statsService = StatsService();
  final StorageService _storageService = StorageService();
  List<PlayerStats> _playerStats = [];
  List<GameSummary> _gameSummaries = [];
  bool _isLoading = true;
  String _selectedGameType = 'Racing Demons';
  final List<String> _gameTypes = ['Racing Demons', '500'];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    final playerStats = await _statsService.getPlayerStats(_selectedGameType);
    final gameSummaries = await _statsService.getGameSummaries(_selectedGameType);

    setState(() {
      _playerStats = playerStats;
      _gameSummaries = gameSummaries;
      _isLoading = false;
    });
  }

  void _onGameTypeChanged(String gameType) {
    setState(() {
      _selectedGameType = gameType;
    });
    _loadStats();
  }

  Widget _buildPlayerStatsSection() {
    if (_playerStats.isEmpty) {
      return const Center(
        child: Text(
          'No player statistics available yet.',
          style: TextStyle(
            color: CupertinoColors.systemGrey,
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildBentoCard(
          'Most Points',
          _getPlayersWithSameValue(_playerStats, (p) => p.totalPoints),
          '${_playerStats.isEmpty ? 0 : _playerStats.map((p) => p.totalPoints).reduce(max)}',
          CupertinoColors.systemBlue,
          CupertinoIcons.star_fill,
        ),
        _buildBentoCard(
          'Best Average',
          _getPlayersWithSameValue(_playerStats, (p) => p.averagePoints),
          _playerStats.isEmpty ? '0' : _playerStats.map((p) => p.averagePoints).reduce(max).toStringAsFixed(1),
          CupertinoColors.systemGreen,
          CupertinoIcons.chart_bar_fill,
        ),
        _buildBentoCard(
          'Most Wins',
          _getPlayersWithSameValue(_playerStats, (p) => p.gamesWon),
          '${_playerStats.isEmpty ? 0 : _playerStats.map((p) => p.gamesWon).reduce(max)}',
          CupertinoColors.systemIndigo,
          CupertinoIcons.rosette,
        ),
        _buildBentoCard(
          'Highest Score',
          _getPlayersWithSameValue(_playerStats, (p) => p.highestScore),
          '${_playerStats.isEmpty ? 0 : _playerStats.map((p) => p.highestScore).reduce(max)}',
          CupertinoColors.systemOrange,
          CupertinoIcons.flame_fill,
        ),
      ],
    );
  }

  Widget _buildBentoCard(String title, String playerName, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
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
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              playerName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteGame(GameSummary game) async {
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Game'),
        content: Text('Are you sure you want to delete "${game.title}"? This action cannot be undone.'),
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
      await _storageService.deleteGame(game.id);
      _loadStats();
    }
  }

  Widget _buildGamesList() {
    if (_gameSummaries.isEmpty) {
      return const Center(
        child: Text(
          'No completed games yet.',
          style: TextStyle(
            color: CupertinoColors.systemGrey,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _gameSummaries.length,
      itemBuilder: (context, index) {
        final game = _gameSummaries[index];
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
          onDismissed: (_) => _deleteGame(game),
          confirmDismiss: (_) async {
            await _deleteGame(game);
            return true;
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Winner',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            game.winner,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Score',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            game.winningScore.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, y').format(game.playedAt),
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getPlayersWithSameValue(List<PlayerStats> players, num Function(PlayerStats) getValue) {
    if (players.isEmpty) return 'No players';
    final maxValue = players.map(getValue).reduce(max);
    final playersWithMaxValue = players.where((p) => getValue(p) == maxValue).map((p) => p.playerName).toList();
    return playersWithMaxValue.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Statistics'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: _loadStats,
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(
                child: CupertinoActivityIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PillTabSelector(
                        options: _gameTypes,
                        selectedOption: _selectedGameType,
                        onOptionSelected: _onGameTypeChanged,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Player Stats',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPlayerStatsSection(),
                    const SizedBox(height: 24),
                    const Text(
                      'Game History',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGamesList(),
                  ],
                ),
              ),
      ),
    );
  }
} 