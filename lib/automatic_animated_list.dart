import 'package:flutter/widgets.dart';
import 'package:diffutil_dart/diffutil.dart';


const Duration _kDuration = Duration(milliseconds: 300);

class AutomaticAnimatedList<T> extends StatefulWidget {
  const AutomaticAnimatedList({
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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void didUpdateWidget(AutomaticAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final List<Key> oldKeys = oldWidget.items.map((T e) => oldWidget.keyingFunction(e)).toList();
    final List<Key> newKeys = widget.items.map((T e) => widget.keyingFunction(e)).toList();

    for (final DataDiffUpdate<Key> update in calculateListDiff<Key>(
      oldKeys,
      newKeys,
      detectMoves: false,
    ).getUpdatesWithData()) {
      if (update is DataInsert<Key>) {
        _listKey.currentState!.insertItem(
          update.position,
          duration: widget.insertDuration,
        );
      } else if (update is DataRemove<Key>) {
        _listKey.currentState!.removeItem(
          update.position,
          (BuildContext context, Animation<double> animation) =>
            oldWidget.itemBuilder(context, oldWidget.items[update.position], animation),
          duration: widget.removeDuration,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedList(
    key: _listKey,
    scrollDirection: widget.scrollDirection,
    reverse: widget.reverse,
    controller: widget.controller,
    primary: widget.primary,
    physics: widget.physics,
    shrinkWrap: widget.shrinkWrap,
    padding: widget.padding,
    initialItemCount: widget.items.length,
    itemBuilder: (BuildContext context, int index, Animation<double> animation) =>
      widget.itemBuilder(context, widget.items[index], animation),
  );
}
