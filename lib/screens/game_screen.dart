import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/storage_service.dart';
import '../widgets/pill_tab_selector.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  const GameScreen({super.key, required this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Game _game;
  final StorageService _storageService = StorageService();
  final Map<int, TextEditingController> _newScoreControllers = {};
  int _selectedTab = 0;
  String? _roundWinner;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var i = 0; i < _game.players.length; i++) {
      _newScoreControllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _newScoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges()) return true;

    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Save Game'),
        content: const Text('Do you want to save this game as a draft?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Discard'),
            onPressed: () async {
              Navigator.pop(context, false);
            },
          ),
          CupertinoDialogAction(
            child: const Text('Save Draft'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result ?? false) {
      // Save as draft
      await _storageService.saveDraftGame(_game);
      if (mounted) {
        Navigator.of(context).pop('draft_updated');
      }
      return false; // We handled the navigation
    } else if (result == false) {
      // Discard game
      await _storageService.deleteDraftGame(widget.game.id);
      await _storageService.deleteGame(widget.game.id);
      if (mounted) {
        Navigator.of(context).pop('draft_updated');
      }
      return false; // We handled the navigation
    }

    return true; // Only return true if the dialog was dismissed
  }

  bool _hasUnsavedChanges() {
    // Add your logic to determine if there are unsaved changes
    // For example, check if scores have been modified
    return true; // For now, always show the save draft dialog
  }

  void _addNewRound() {
    if (_newScoreControllers.values.any((controller) => controller.text.isEmpty) || _roundWinner == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please enter scores for all players and select a winner.'),
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

    setState(() {
      final newScores = _newScoreControllers.entries
          .map((e) => int.tryParse(e.value.text) ?? 0)
          .toList();
      
      _game = _game.copyWith(
        scores: List<List<int>>.from(_game.scores)..add(newScores),
        roundWinners: List<String>.from(_game.roundWinners)..add(_roundWinner!),
        lastModified: DateTime.now(),
      );

      // Clear controllers and winner selection
      for (var controller in _newScoreControllers.values) {
        controller.clear();
      }
      _roundWinner = null;

      // Switch to scores tab
      _selectedTab = 0;
    });
    
    // Only save to draft storage while game is in progress
    _storageService.saveDraftGame(_game);
  }

  void _endGame() async {
    final shouldEnd = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('End Game'),
        content: const Text('Are you sure you want to end this game?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: const Text('End Game'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;

    if (shouldEnd && mounted) {
      // Save as a completed game (not a draft)
      final completedGame = _game.copyWith(isDraftGame: false);
      await _storageService.saveGame(completedGame);
      await _storageService.deleteDraftGame(_game.id);
      
      // Return to home with draft_updated result
      Navigator.of(context).pop('draft_updated');
    }
  }

  Widget _buildScoresTab() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: max(MediaQuery.of(context).size.width, (_game.players.length + 1) * 100.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: Text(
                        'Round',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey.darkColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...List.generate(_game.players.length, (index) {
                      return Expanded(
                        child: Text(
                          _game.players[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CupertinoColors.systemGrey.darkColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // Scores rows
              Expanded(
                child: ListView.builder(
                  itemCount: _game.scores.length,
                  itemBuilder: (context, roundIndex) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Text(
                              '${roundIndex + 1}',
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                          ...List.generate(_game.players.length, (playerIndex) {
                            final isWinner = roundIndex < _game.roundWinners.length &&
                                _game.roundWinners[roundIndex] == _game.players[playerIndex];
                            return Expanded(
                              child: Text(
                                '${_game.scores[roundIndex][playerIndex]}${isWinner ? ' *' : ''}',
                                textAlign: TextAlign.center,
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Totals row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...List.generate(_game.players.length, (index) {
                      return Expanded(
                        child: Text(
                          _game.totalScores[index].toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Player score inputs
                ..._game.players.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            player,
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoTextField(
                            controller: _newScoreControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            placeholder: 'Score',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                // Winner selection
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Round Winner',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _game.players.map((player) {
                    final isSelected = _roundWinner == player;
                    return CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      color: isSelected ? CupertinoColors.activeBlue : null,
                      child: Text(
                        player,
                        style: TextStyle(
                          color: isSelected ? CupertinoColors.white : CupertinoColors.activeBlue,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _roundWinner = player;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              child: const Text('Add Scores'),
              onPressed: _addNewRound,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    // Calculate stats
    final List<Map<String, dynamic>> playerStats = List.generate(_game.players.length, (index) {
      final scores = _game.scores.map((round) => round[index]).toList();
      final total = scores.fold<int>(0, (sum, score) => sum + score);
      final average = scores.isEmpty ? 0.0 : total / scores.length;
      // Count rounds won based on selected winners
      final roundsWon = _game.roundWinners.where((winner) => winner == _game.players[index]).length;

      return {
        'name': _game.players[index],
        'total': total,
        'average': average.toStringAsFixed(1),
        'roundsWon': roundsWon,
      };
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: playerStats.length,
      itemBuilder: (context, index) {
        final stats = playerStats[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stats['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatRow('Total Score', stats['total'].toString()),
              _buildStatRow('Average Score', stats['average']),
              _buildStatRow('Rounds Won', stats['roundsWon'].toString()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.systemBackground,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          middle: Text(_game.title),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text('End'),
            onPressed: _endGame,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                child: PillTabSelector(
                  options: const ['Scores', 'Add', 'Stats'],
                  selectedOption: ['Scores', 'Add', 'Stats'][_selectedTab],
                  onOptionSelected: (option) {
                    setState(() {
                      _selectedTab = ['Scores', 'Add', 'Stats'].indexOf(option);
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Builder(
                  builder: (context) {
                    switch (_selectedTab) {
                      case 0:
                        return _buildScoresTab();
                      case 1:
                        return _buildAddTab();
                      case 2:
                        return _buildStatsTab();
                      default:
                        return _buildScoresTab();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 