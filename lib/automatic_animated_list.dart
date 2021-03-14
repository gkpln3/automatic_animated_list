import 'package:flutter/widgets.dart';

const Duration _kDuration = Duration(milliseconds: 300);

class AutomaticAnimatedList<T> extends StatefulWidget {
  AutomaticAnimatedList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.keyingFunction,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.insertDuration = _kDuration,
    this.removeDuration = _kDuration,
  }) : super(key: key);

  final List<T> items;
  final Widget Function(BuildContext, T, Animation<double>) itemBuilder;
  final Key Function(T item) keyingFunction;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  final Duration insertDuration;
  final Duration removeDuration;

  @override
  _AutomaticAnimatedListState<T> createState() =>
      _AutomaticAnimatedListState<T>();
}

class _AutomaticAnimatedListState<T> extends State<AutomaticAnimatedList<T>> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void didUpdateWidget(AutomaticAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    List<Key> oldKeys =
        oldWidget.items.map((e) => oldWidget.keyingFunction(e)).toList();
    List<Key> newKeys =
        this.widget.items.map((e) => this.widget.keyingFunction(e)).toList();

    // This variable holds the current offset between the lists. it thrives to make
    int offset = 0;
    for (int i = 0; i < oldKeys.length; i++) {
      // We reached the end if the new list, this means all other old items here were removed.
      if (newKeys.length < i + offset + 1) {
        // This item is not present in the new list. which means it was removed.
        _listKey.currentState!.removeItem(
            i,
            (context, animation) =>
                oldWidget.itemBuilder(context, oldWidget.items[i], animation),
            duration: this.widget.removeDuration);
        offset--;
        continue;
      }

      // Check if the current item is the same item.
      if (oldKeys[i] != newKeys[i + offset]) {
        // The current items differ, check if this item was removed or just moved index.
        int tempOffset = newKeys.indexOf(oldKeys[i]);
        if (tempOffset != -1) {
          // This item exists in the new list!, this means all items between them are new ones.
          for (int j = i; j < tempOffset; j++) {
            _listKey.currentState!
                .insertItem(j, duration: this.widget.insertDuration);
            offset++;
          }
        } else {
          // This item is not present in the new list. which means it was removed.
          _listKey.currentState!.removeItem(
              i,
              (context, animation) =>
                  oldWidget.itemBuilder(context, oldWidget.items[i], animation),
              duration: this.widget.removeDuration);
          offset--;
        }
      }
    }

    // All the rest.
    for (int i = oldKeys.length; i < newKeys.length - offset; i++) {
      _listKey.currentState!
          .insertItem(i, duration: this.widget.insertDuration);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      scrollDirection: this.widget.scrollDirection,
      reverse: this.widget.reverse,
      controller: this.widget.controller,
      primary: this.widget.primary,
      physics: this.widget.physics,
      shrinkWrap: this.widget.shrinkWrap,
      padding: this.widget.padding,
      initialItemCount: this.widget.items.length,
      itemBuilder: (BuildContext context, int index, Animation animation) =>
          this.widget.itemBuilder(context, this.widget.items[index],
              animation as Animation<double>),
    );
  }
}
