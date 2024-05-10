import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cards_provider.g.dart';

class WalletCard extends Equatable {
  final int id;
  final String name;
  final Widget content;

  const WalletCard(
      {required this.id, required this.name, required this.content});

  @override
  List<Object?> get props => [id, name];
}

@riverpod
class Cards extends _$Cards {
  @override
  List<WalletCard> build() {
    ref.listenSelf((previous, next) async {
      final data = await Future.wait(
        next.map((card) async {
          final path = await HomeWidget.renderFlutterWidget(
            card.content,
            key: "card_${card.id}",
          );
          return {
            'id': card.id,
            'name': card.name,
            'content': path,
          };
        }),
      );
      await HomeWidget.saveWidgetData(
        'cards',
        jsonEncode(data),
      );
      await HomeWidget.updateWidget(
        name: 'PocWidget',
      );
      print('Updated widget!');
    });
    return [];
  }

  void addCard({required String name, required Widget content}) {
    state = [
      ...state,
      WalletCard(id: state.length, name: name, content: content)
    ];
  }

  void remove(WalletCard card) {
    state = [...state..remove(card)];
  }
}
