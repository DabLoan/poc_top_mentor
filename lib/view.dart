import 'package:flutter/material.dart';
import 'package:poc_top_mentor/chatpage.dart';
import 'package:poc_top_mentor/chatpagetwo.dart';
import 'package:poc_top_mentor/explorerpage.dart';
import 'package:poc_top_mentor/l10n/intl.dart';
import 'package:swipe_to_complete/swipe_to_complete.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];
  List<String> _items = ["Item 1", "Item 2", "Item 3"];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages.addAll([
      _buildReorderableListPage(),
      const ChatPage(),
      const ExplorerPage(),
      const ChatPageTwo(),
    ]);
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ChatPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          },
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildReorderableListPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.homeText ?? "Reorderable List"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _items.length,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  key: ValueKey(_items[index]),
                  title: Text(
                    _items[index],
                    style: TextStyle(fontSize: 18),
                  ),
                  leading: const Icon(Icons.drag_handle),
                );
              },
            ),
          ),
          NewSwiper(
            type: SwiperType.horizontal,
            callback: () => showAboutDialog(context: context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)?.homeTitle ?? "Home",
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! < -10) {
                  setState(() {
                    _selectedIndex = 1;
                  });
                }
              },
              child: const Icon(Icons.chat),
            ),
            label: AppLocalizations.of(context)?.chatTitle ?? "Chat",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: AppLocalizations.of(context)?.exploreTitle ?? "Explore",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.accessibility),
            label: AppLocalizations.of(context)?.chatTitle ?? "Chat 2",
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      ),
    );
  }
}
