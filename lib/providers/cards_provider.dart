import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
            SizedBox.square(
              dimension: 400,
              child: FittedBox(child: card.content),
            ),
            key: "card_${card.id}",
            logicalSize: const Size(400, 400),
            pixelRatio:
                PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 3,
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
        iOSName: 'PocWidgets',
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
