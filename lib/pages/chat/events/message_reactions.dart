import 'package:flutter/material.dart';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

import 'package:tawkie/config/app_config.dart';
import 'package:tawkie/widgets/avatar.dart';
import 'package:tawkie/widgets/matrix.dart';
import 'package:tawkie/widgets/mxc_image.dart';

class MessageReactions extends StatelessWidget {
  final Event event;
  final Timeline timeline;

  const MessageReactions(this.event, this.timeline, {super.key});

  @override
  Widget build(BuildContext context) {
    final allReactionEvents =
        event.aggregatedEvents(timeline, RelationshipTypes.reaction);
    final reactionMap = <String, _ReactionEntry>{};
    final client = Matrix.of(context).client;

    for (final e in allReactionEvents) {
      final key = e.content
          .tryGetMap<String, dynamic>('m.relates_to')
          ?.tryGet<String>('key');
      if (key != null) {
        if (!reactionMap.containsKey(key)) {
          reactionMap[key] = _ReactionEntry(
            key: key,
            count: 0,
            reacted: false,
            reactors: [],
          );
        }
        reactionMap[key]!.count++;
        reactionMap[key]!.reactors!.add(e.senderFromMemoryOrFallback);
        reactionMap[key]!.reacted |= e.senderId == e.room.client.userID;
      }
    }

    final reactionList = reactionMap.values.toList();
    reactionList.sort((a, b) => b.count - a.count > 0 ? 1 : -1);
    final ownMessage = event.senderId == event.room.client.userID;
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      alignment: ownMessage ? WrapAlignment.end : WrapAlignment.start,
      children: [
        ...reactionList.map(
          (r) => _Reaction(
            reactionKey: r.key,
            count: r.count,
            reacted: r.reacted,
            onTap: () {
              if (r.reacted) {
                final evt = allReactionEvents.firstWhereOrNull(
                  (e) =>
                      e.senderId == e.room.client.userID &&
                      e.content.tryGetMap('m.relates_to')?['key'] == r.key,
                );
                if (evt != null) {
                  showFutureLoadingDialog(
                    context: context,
                    future: () => evt.redactEvent(),
                  );
                }
              } else {
                event.room.sendReaction(event.eventId, r.key!);
              }
            },
            onLongPress: () async => await _AdaptableReactorsDialog(
              client: client,
              reactionEntry: r,
            ).show(context),
          ),
        ),
        if (allReactionEvents.any((e) => e.status.isSending))
          const SizedBox(
            width: 24,
            height: 24,
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: CircularProgressIndicator.adaptive(strokeWidth: 1),
            ),
          ),
      ],
    );
  }
}

class _Reaction extends StatelessWidget {
  final String? reactionKey;
  final int count;
  final bool? reacted;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const _Reaction({
    required this.reactionKey,
    required this.count,
    required this.reacted,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color = Theme.of(context).colorScheme.background;
    final fontSize = DefaultTextStyle.of(context).style.fontSize;
    Widget content;
    if (reactionKey!.startsWith('mxc://')) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxcImage(
            uri: Uri.parse(reactionKey!),
            width: 9999,
            height: fontSize,
          ),
          if (count > 1) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: DefaultTextStyle.of(context).style.fontSize,
              ),
            ),
          ],
        ],
      );
    } else {
      var renderKey = Characters(reactionKey!);
      if (renderKey.length > 10) {
        renderKey = renderKey.getRange(0, 9) + Characters('…');
      }
      content = Text(
        renderKey.toString() + (count > 1 ? ' $count' : ''),
        style: TextStyle(
          color: textColor,
          fontSize: DefaultTextStyle.of(context).style.fontSize,
        ),
      );
    }
    return InkWell(
      onTap: () => onTap != null ? onTap!() : null,
      onLongPress: () => onLongPress != null ? onLongPress!() : null,
      borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            width: 1,
            color: reacted!
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
          ),
          borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: content,
      ),
    );
  }
}

class _ReactionEntry {
  String? key;
  int count;
  bool reacted;
  List<User>? reactors;

  _ReactionEntry({
    this.key,
    required this.count,
    required this.reacted,
    this.reactors,
  });
}

class _AdaptableReactorsDialog extends StatelessWidget {
  final Client? client;
  final _ReactionEntry? reactionEntry;

  const _AdaptableReactorsDialog({
    this.client,
    this.reactionEntry,
  });

  Future<bool?> show(BuildContext context) => showAdaptiveDialog(
        context: context,
        builder: (context) => this,
        barrierDismissible: true,
        useRootNavigator: false,
      );

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: <Widget>[
          for (final reactor in reactionEntry!.reactors!)
            Chip(
              avatar: Avatar(
                mxContent: reactor.avatarUrl,
                name: reactor.displayName,
                client: client,
                presenceUserId: reactor.stateKey,
              ),
              label: Text(reactor.displayName!),
            ),
        ],
      ),
    );

    final title = Center(child: Text(reactionEntry!.key!));

    return AlertDialog.adaptive(
      title: title,
      content: body,
    );
  }
}
