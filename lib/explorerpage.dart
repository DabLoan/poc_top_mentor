import 'package:flutter/material.dart';
import 'tm_card_header.dart';
import 'card_widget.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  final List<Map<String, dynamic>> _cardsData = [
    {
      "header": "Activité physique",
      "duration": "20 min",
      "title": "20 min de marche",
      "description":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin turpis et velit libero habitant urna tincidunt blandit.",
      "advice": "Aliquam erat volutpat. Mauris mauris morbi faucibus consectetur.",
      "actionText": "Poser une question",
      "actionIcon": Icons.chat_bubble_outline,
      "backgroundColor": const Color(0xFFCADDF5),
      "actionTextColor": Colors.black,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const TMCardHeader(
            title: 'Changer mes habitudes au quotidien',
            subtitle: 'Vie quotidienne',
            progress: 0.10,
            progressLabel: '10%',
            backgroundColor: Color(0xFFCADDF5),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: const Text(
              'Aujourd\'hui :',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _cardsData.length,
                itemBuilder: (context, index) {
                  final card = _cardsData[index];
                  return CardWidget(
                    header: card['header'],
                    duration: card['duration'],
                    title: card['title'],
                    description: card['description'],
                    advice: card['advice'],
                    onActionTap: () => debugPrint("${card['actionText']} tapped"),
                    backgroundColor: card['backgroundColor'],
                    actionText: card['actionText'],
                    actionIcon: card['actionIcon'],
                    actionTextColor: card['actionTextColor'],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
