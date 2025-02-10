import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:poc_top_mentor/l10n/intl.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> messages = [];
  final user = const types.User(id: '0123456789');
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _messageController = TextEditingController();
  List<String> predefinedMessages = ["Je veux des défis quotidiens", "Je préfère avancer à mon rythme"];
  bool _manuallyStopped = false;
  bool _speechEnabled = false;
  bool _isListening = false;
  late String _lastWords = '';
  String _interimWords = '';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      await _initSpeech();
    }
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
      if (_speechEnabled) {
        setState(() {});
      }
    } catch (_) {}
  }

  void _startListening() async {
    if (_speechEnabled) {
      _manuallyStopped = false;
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: Duration(seconds: 30),
        cancelOnError: true,
        partialResults: true,
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() async {
    _manuallyStopped = true;
    await _speechToText.stop();
    setState(() {
      _lastWords += ' ' + _interimWords;
      _interimWords = '';
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _interimWords = result.recognizedWords;
      _messageController.text = _lastWords + ' ' + _interimWords;
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );

      if (result.finalResult) {
        _lastWords += ' ' + _interimWords;
        _interimWords = '';
        _messageController.text = _lastWords;
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
      }
    });

    if (!_speechToText.isListening && !_manuallyStopped) {
      _startListening();
    }
  }

  void _addMessage(types.Message message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  Future<void> _simulateReceivedMessage(String text) async {
    const typingMessage = types.TextMessage(
      id: 'typing',
      author: types.User(id: 'system'),
      text: '',
    );
    _addMessage(typingMessage);

    String displayedText = '';
    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      displayedText += text[i];
      setState(() {
        messages[0] = types.TextMessage(
          id: 'typing',
          author: types.User(id: 'system'),
          text: displayedText,
        );
      });
    }

    setState(() {
      messages[0] = types.TextMessage(
        id: DateTime.now().toIso8601String(),
        author: types.User(id: 'system'),
        text: displayedText,
      );
    });
  }

  void handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toIso8601String(),
      text: message.text,
    );

    _addMessage(textMessage);
    Future.delayed(const Duration(seconds: 1), () {
      _simulateReceivedMessage(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum mollis suscipit rhoncus. Mauris ultricies luctus ipsum non convallis. Sed posuere lobortis tincidunt. Aenean imperdiet orci sed est aliquet, vitae sollicitudin velit bibendum. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce molestie diam vitae enim accumsan, sed dignissim metus pellentesque. Duis suscipit sagittis nisl a pretium. Praesent semper."
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          AppLocalizations.of(context)?.chatTitle ?? 'Chat',
          style: TextStyle(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: messages,
              onSendPressed: handleSendPressed,
              user: user,
              theme: DefaultChatTheme(
                backgroundColor: theme.scaffoldBackgroundColor,
                inputTextColor: Colors.white,
                inputContainerDecoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              customBottomWidget: _buildPredefinedMessages(theme),
            ),
          ),
          _buildCustomInput(theme),
        ],
      ),
    );
  }

  Widget _buildCustomInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.startMessage ?? 'Send a message',
                hintStyle: TextStyle(color: theme.hintColor),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: theme.iconTheme.color),
            onPressed: () {
              final text = _messageController.text.trim();
              if (text.isNotEmpty) {
                handleSendPressed(types.PartialText(text: text));
                _messageController.clear();
                _lastWords = '';
              }
            },
          ),
        ],
      ),
    );
  }
  Widget _buildPredefinedMessages(ThemeData theme) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: predefinedMessages.map((message) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              onPressed: () {
                handleSendPressed(types.PartialText(text: message));
                setState(() {
                  predefinedMessages = ["Option 1", "Option 2"];
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.cardColor,
                foregroundColor: theme.textTheme.bodyMedium?.color,
              ),
              child: Text(message),
            ),
          );
        }).toList(),
      ),
    );
  }
}
