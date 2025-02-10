import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get homeTitle {
    return Intl.message('Home', name: 'homeTitle');
  }

  String get chatTitle {
    return Intl.message('Chat', name: 'chatTitle');
  }

  String get exploreTitle {
    return Intl.message('Explore', name: 'exploreTitle');
  }

  String get startMessage {
    return Intl.message('Send a message', name: 'startMessage');
  }

  String get noMessages {
    return Intl.message('Start a conversation !', name: 'noMessages');
  }

  String get homeText{
    return Intl.message('Home Page', name: 'homeText');
  }
}