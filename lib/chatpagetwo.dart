import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:poc_top_mentor/l10n/intl.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPageTwo extends StatefulWidget {
  const ChatPageTwo({super.key});

  @override
  State<ChatPageTwo> createState() => _ChatPageTwoState();
}

class _ChatPageTwoState extends State<ChatPageTwo> {
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

  void handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toIso8601String(),
      text: message.text,
    );

    _addMessage(textMessage);
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
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: theme.scaffoldBackgroundColor,
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: predefinedMessages.length,
          itemBuilder: (context, index) {
            final message = predefinedMessages[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
          },
        ),
      ),
    );
  }
}
