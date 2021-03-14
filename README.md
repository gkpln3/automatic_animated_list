# AutomaticAnimatedList

An AnimatedList which automatically computes the item deltas each time the underlying list changes and animates the list items automatically.

## Example

<img src="https://user-images.githubusercontent.com/8081679/111062612-998afd00-84b2-11eb-957d-553262c1d836.gif" width="350" />

## Usage
Just provide `AutomaticAnimatedList<T>` your list, a `keyingFunction`, which will return an identifing key for each item, and the `itemBuilder`.

`AutomaticAnimatedList<T>` will take care of the rest.

```dart
class ItemsAnimatedList extends StatelessWidget {
  final List<ItemModel> items;
  const ItemsList({
    Key key,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutomaticAnimatedList<ItemModel>(
      items: items,
      insertDuration: Duration(seconds: 1),
      removeDuration: Duration(seconds: 1),
      keyingFunction: (ItemModel item) => Key(item.id),
      itemBuilder:
          (BuildContext context, ItemModel item, Animation<double> animation) {
        return FadeTransition(
          key: Key(item.id),
          opacity: animation,
          child: SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
              reverseCurve: Curves.easeIn,
            ),
            child: ListTile(title: Text(item.name)),
          ),
        );
      },
    );
  }
}
```