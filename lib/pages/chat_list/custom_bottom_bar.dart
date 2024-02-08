import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart' as sdk;
import 'package:matrix/matrix.dart';

import 'package:tawkie/pages/chat_list/chat_list.dart';
import 'package:tawkie/pages/chat_list/chat_list_item.dart';
import 'package:tawkie/pages/chat_list/search_title.dart';
import 'package:tawkie/utils/localized_exception_extension.dart';
import 'package:tawkie/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:tawkie/widgets/avatar.dart';
import 'package:tawkie/widgets/matrix.dart';
import 'chat_list_header.dart';

class CustomBottomBar extends StatefulWidget {
  final ChatListController controller;
  final ScrollController scrollController;
  const CustomBottomBar(
      this.controller, {
        super.key,
        required this.scrollController,
      });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  static final Map<String, GetSpaceHierarchyResponse> _lastResponse = {};

  String? prevBatch;
  Object? error;
  bool loading = false;

  @override
  void initState() {
    loadHierarchy();
    super.initState();
  }

  void _refresh() {
    _lastResponse.remove(widget.controller.activeSpaceId);
    loadHierarchy();
  }

  Future<GetSpaceHierarchyResponse> loadHierarchy([String? prevBatch]) async {
    final activeSpaceId = widget.controller.activeSpaceId!;
    final client = Matrix.of(context).client;

    final activeSpace = client.getRoomById(activeSpaceId);
    await activeSpace?.postLoad();

    setState(() {
      error = null;
      loading = true;
    });

    try {
      final response = await client.getSpaceHierarchy(
        activeSpaceId,
        maxDepth: 1,
        from: prevBatch,
      );

      if (prevBatch != null) {
        response.rooms.insertAll(0, _lastResponse[activeSpaceId]?.rooms ?? []);
      }
      setState(() {
        _lastResponse[activeSpaceId] = response;
      });
      return _lastResponse[activeSpaceId]!;
    } catch (e) {
      setState(() {
        error = e;
      });
      rethrow;
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _onJoinSpaceChild(SpaceRoomsChunk spaceChild) async {
    final client = Matrix.of(context).client;
    final space = client.getRoomById(widget.controller.activeSpaceId!);
    if (client.getRoomById(spaceChild.roomId) == null) {
      final result = await showFutureLoadingDialog(
        context: context,
        future: () async {
          await client.joinRoom(
            spaceChild.roomId,
            serverName: space?.spaceChildren
                .firstWhereOrNull(
                  (child) => child.roomId == spaceChild.roomId,
            )
                ?.via,
          );
          if (client.getRoomById(spaceChild.roomId) == null) {
            // Wait for room actually appears in sync
            await client.waitForRoomInSync(spaceChild.roomId, join: true);
          }
        },
      );
      if (result.error != null) return;
      _refresh();
    }
    if (spaceChild.roomType == 'm.space') {
      if (spaceChild.roomId == widget.controller.activeSpaceId) {
        context.go('/rooms/${spaceChild.roomId}');
      } else {
        widget.controller.setActiveSpace(spaceChild.roomId);
      }
      return;
    }
    context.go('/rooms/${spaceChild.roomId}');
  }

  void _onSpaceChildContextMenu([
    SpaceRoomsChunk? spaceChild,
    Room? room,
  ]) async {
    final client = Matrix.of(context).client;
    final activeSpaceId = widget.controller.activeSpaceId;
    final activeSpace =
    activeSpaceId == null ? null : client.getRoomById(activeSpaceId);
    final action = await showModalActionSheet<SpaceChildContextAction>(
      context: context,
      title: spaceChild?.name ??
          room?.getLocalizedDisplayname(
            MatrixLocals(L10n.of(context)!),
          ),
      message: spaceChild?.topic ?? room?.topic,
      actions: [
        if (room == null)
          SheetAction(
            key: SpaceChildContextAction.join,
            label: L10n.of(context)!.joinRoom,
            icon: Icons.send_outlined,
          ),
        if (spaceChild != null &&
            (activeSpace?.canChangeStateEvent(EventTypes.spaceChild) ?? false))
          SheetAction(
            key: SpaceChildContextAction.removeFromSpace,
            label: L10n.of(context)!.removeFromSpace,
            icon: Icons.delete_sweep_outlined,
          ),
        if (room != null)
          SheetAction(
            key: SpaceChildContextAction.leave,
            label: L10n.of(context)!.leave,
            icon: Icons.delete_outlined,
            isDestructiveAction: true,
          ),
      ],
    );
    if (action == null) return;

    switch (action) {
      case SpaceChildContextAction.join:
        _onJoinSpaceChild(spaceChild!);
        break;
      case SpaceChildContextAction.leave:
        await showFutureLoadingDialog(
          context: context,
          future: room!.leave,
        );
        break;
      case SpaceChildContextAction.removeFromSpace:
        await showFutureLoadingDialog(
          context: context,
          future: () => activeSpace!.removeSpaceChild(spaceChild!.roomId),
        );
        break;
    }
  }

  void _addChatOrSubSpace() async {
    final roomType = await showConfirmationDialog(
      context: context,
      title: L10n.of(context)!.addChatOrSubSpace,
      actions: [
        AlertDialogAction(
          key: AddRoomType.subspace,
          label: L10n.of(context)!.createNewSpace,
        ),
        AlertDialogAction(
          key: AddRoomType.chat,
          label: L10n.of(context)!.createGroup,
        ),
      ],
    );
    if (roomType == null) return;

    final names = await showTextInputDialog(
      context: context,
      title: roomType == AddRoomType.subspace
          ? L10n.of(context)!.createNewSpace
          : L10n.of(context)!.createGroup,
      textFields: [
        DialogTextField(
          hintText: roomType == AddRoomType.subspace
              ? L10n.of(context)!.spaceName
              : L10n.of(context)!.groupName,
          minLines: 1,
          maxLines: 1,
          maxLength: 64,
          validator: (text) {
            if (text == null || text.isEmpty) {
              return L10n.of(context)!.pleaseChoose;
            }
            return null;
          },
        ),
        DialogTextField(
          hintText: L10n.of(context)!.chatDescription,
          minLines: 4,
          maxLines: 8,
          maxLength: 255,
        ),
      ],
      okLabel: L10n.of(context)!.create,
      cancelLabel: L10n.of(context)!.cancel,
    );
    if (names == null) return;
    final client = Matrix.of(context).client;
    final result = await showFutureLoadingDialog(
      context: context,
      future: () async {
        late final String roomId;
        final activeSpace = client.getRoomById(
          widget.controller.activeSpaceId!,
        )!;

        if (roomType == AddRoomType.subspace) {
          roomId = await client.createSpace(
            name: names.first,
            topic: names.last.isEmpty ? null : names.last,
            visibility: activeSpace.joinRules == JoinRules.public
                ? sdk.Visibility.public
                : sdk.Visibility.private,
          );
        } else {
          roomId = await client.createGroupChat(
            groupName: names.first,
            initialState: names.length > 1 && names.last.isNotEmpty
                ? [
              sdk.StateEvent(
                type: sdk.EventTypes.RoomTopic,
                content: {'topic': names.last},
              ),
            ]
                : null,
          );
        }
        await activeSpace.setSpaceChild(roomId);
      },
    );
    if (result.error != null) return;
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    final activeSpaceId = widget.controller.activeSpaceId;
    final activeSpace = activeSpaceId == null
        ? null
        : client.getRoomById(
      activeSpaceId,
    );
    final allSpaces = client.rooms.where((room) => room.isSpace);

    final rootSpaces = allSpaces
        .where(
          (space) => !allSpaces.any(
            (parentSpace) => parentSpace.spaceChildren
            .any((child) => child.roomId == space.id),
      ),
    )
        .toList();

    return Container(
      height: 64,
      color: Theme.of(context).colorScheme.background, // Background color
      child: Row(
        children: [
          // ListView.builder for existing filter list
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rootSpaces.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Avatar(
                        mxContent: rootSpaces[index].avatar,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Fixed circle on right for filter parameters
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: (){
                // Navigate to FiltersListSetting
                context.go('/rooms/filters_list_setting');
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}

enum SpaceChildContextAction {
  join,
  leave,
  removeFromSpace,
}

enum AddRoomType { chat, subspace }
