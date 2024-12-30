import 'package:flutter/cupertino.dart';
import './models/game.dart';
import './screens/game_screen.dart';
import './screens/home_page.dart';
import './screens/profile_page.dart';
import './screens/statistics_page.dart';
import './screens/draft_games_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Card Game Counter',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: const MainScreen(),
      routes: {
        '/profile': (context) => const ProfilePage(),
        '/drafts': (context) => const DraftGamesPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/game') {
          final game = settings.arguments as Game;
          return CupertinoPageRoute(
            builder: (context) => GameScreen(game: game),
          );
        }
        return null;
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
            switch (index) {
              case 0:
            return const HomePage();
              case 1:
            return const StatisticsPage();
              case 2:
            return const ProfilePage();
              default:
            return const HomePage();
            }
      },
    );
  }
}
