void main() {
  var list = [Item(true), Item(true)];
  var copy = List.from(list);
  copy[0].isSelected = false;
  print("list[0].isSelected: ${list[0].isSelected}");
  print("copy[0].isSelected: ${copy[0].isSelected}");

  var updated = copy[0].copyWith(isSelected: copy[0].isSelected);
  copy[0] = updated;
  print("list[0].isSelected: ${list[0].isSelected}");
  print("copy[0].isSelected: ${copy[0].isSelected}");
}

class Item {
  bool isSelected;
  Item(this.isSelected);
  Item copyWith({bool? isSelected}) {
    return Item(isSelected ?? this.isSelected);
  }
}
