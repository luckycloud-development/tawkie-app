import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:tawkie/config/themes.dart';
import 'package:tawkie/pages/chat/chat.dart';
import 'package:tawkie/pages/chat/events/message.dart';
import 'package:tawkie/pages/chat/seen_by_row.dart';
import 'package:tawkie/pages/chat/typing_indicators.dart';
import 'package:tawkie/pages/user_bottom_sheet/user_bottom_sheet.dart';
import 'package:tawkie/utils/adaptive_bottom_sheet.dart';
import 'package:tawkie/utils/matrix_sdk_extensions/filtered_timeline_extension.dart';
import 'package:tawkie/utils/platform_infos.dart';

class ChatEventList extends StatelessWidget {
  final ChatController controller;
  const ChatEventList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = FluffyThemes.isColumnMode(context) ? 8.0 : 0.0;

    final events = controller.timeline!.events
        .where((event) => event.isVisibleInGui)
        .toList();

    // create a map of eventId --> index to greatly improve performance of
    // ListView's findChildIndexCallback
    final thisEventsKeyMap = <String, int>{};
    for (var i = 0; i < events.length; i++) {
      thisEventsKeyMap[events[i].eventId] = i;
    }

    return SelectionArea(
      child: ListView.custom(
        padding: EdgeInsets.only(
          top: 16,
          bottom: 4,
          left: horizontalPadding,
          right: horizontalPadding,
        ),
        reverse: true,
        controller: controller.scrollController,
        keyboardDismissBehavior: PlatformInfos.isIOS
            ? ScrollViewKeyboardDismissBehavior.onDrag
            : ScrollViewKeyboardDismissBehavior.manual,
        childrenDelegate: SliverChildBuilderDelegate(
          (BuildContext context, int i) {
            // Footer to display typing indicator and read receipts:
            if (i == 0) {
              if (controller.timeline!.isRequestingFuture) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                );
              }
              if (controller.timeline!.canRequestFuture) {
                return Center(
                  child: IconButton(
                    onPressed: controller.requestFuture,
                    icon: const Icon(Icons.refresh_outlined),
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SeenByRow(controller),
                  TypingIndicators(controller),
                ],
              );
            }

            // Request history button or progress indicator:
            if (i == events.length + 1) {
              if (controller.timeline!.isRequestingHistory) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                );
              }
              if (controller.timeline!.canRequestHistory) {
                return Center(
                  child: IconButton(
                    onPressed: controller.requestHistory,
                    icon: const Icon(Icons.refresh_outlined),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            i--;

            // The message at this index:
            final event = events[i];

            return AutoScrollTag(
              key: ValueKey(event.eventId),
              index: i,
              controller: controller.scrollController,
              child: Message(
                event,
                onSwipe: () => controller.replyAction(replyTo: event),
                onInfoTab: controller.showEventInfo,
                onAvatarTab: (Event event) => showAdaptiveBottomSheet(
                  context: context,
                  builder: (c) => UserBottomSheet(
                    user: event.senderFromMemoryOrFallback,
                    outerContext: context,
                    onMention: () => controller.sendController.text +=
                        '${event.senderFromMemoryOrFallback.mention} ',
                  ),
                ),
                onSelect: controller.onSelectMessage,
                scrollToEventId: (String eventId) =>
                    controller.scrollToEventId(eventId),
                longPressSelect: controller.selectedEvents.isNotEmpty,
                selected: controller.selectedEvents
                    .any((e) => e.eventId == event.eventId),
                timeline: controller.timeline!,
                displayReadMarker:
                    controller.readMarkerEventId == event.eventId &&
                        controller.timeline?.allowNewEvent == false,
                nextEvent: i + 1 < events.length ? events[i + 1] : null,
              ),
            );
          },
          childCount: events.length + 2,
          findChildIndexCallback: (key) =>
              controller.findChildIndexCallback(key, thisEventsKeyMap),
        ),
      ),
    );
  }
}
