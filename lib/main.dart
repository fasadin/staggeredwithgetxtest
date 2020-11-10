import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'working.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GetxStaggeredDemo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(title: 'Getx with Staggered Demo'),
    );
  }
}

class HomeScreen extends StatelessWidget {
  int _counter = 0;
  final String title;
  final int crossAxisCount;
  HomeScreenController homeScreenController = Get.put(HomeScreenController());
  int _selectedIndex;

  List<String> _dataForGroups = [
    "Foo",
    "Bar",
  ];

  HomeScreen({this.title}) : crossAxisCount = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('fasadin'),
        centerTitle: true,
        leading: Center(
          child: Text('logo'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.pie_chart),
            onPressed: () {
              //TODO: hide it before initialSetup, and on enable show message "no worries, you can manage group from here, this was small demonstration that our object contains hidden stuff when you tap and hold :)""
              print('groups');
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => print('contacts'),
          ),
          IconButton(
            icon: Icon(Icons.emoji_emotions),
            onPressed: () {
              //TODO: event provider for event. here are all notifications,
              // default first event is tapping on your nickname to see settings
              print('Tutorials / events');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StaggeredGridView.countBuilder(
              crossAxisCount: crossAxisCount,
              itemCount: homeScreenController.sizes.length,
              itemBuilder: (BuildContext context, int index) {
                var isSelected = _selectedIndex == index &&
                    !homeScreenController.wasDeleted.value;
                print('is selected $isSelected');
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Group(
                    data: _dataForGroups[index],
                    key: new ObjectKey(index),
                    index: index,
                    size: homeScreenController.sizes[index],
                    onSizeDown: _handleSizeDown,
                    onSizeUp: _handleSizeUp,
                    onSelectedItemChanged: _handleSelectedItemChanged,
                    onDelete: _handleDelete,
                    maxSize: crossAxisCount,
                    isSelected: isSelected,
                  ),
                  onTap: () {
                    print('homescreen tap');
                  },
                  onLongPress: () {
                    print('homescreen longpress');
                  },
                );
              },
              // for now only squers are allowed, in future think if rectangle is needed
              staggeredTileBuilder: (int index) => new StaggeredTile.count(
                homeScreenController.sizes[index],
                homeScreenController.sizes[index],
              ),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDelete(int index) {
    Obx(() {
      homeScreenController.wasDeleted.value = true;
      homeScreenController.sizes.removeAt(index);
    });
  }

  void _handleSizeDown(int index) {
    var currentSize = homeScreenController.sizes[index];
    if (currentSize > 0) {
      Obx(() {
        homeScreenController.sizes[index] = currentSize - 1;
      });
    }
  }

  void _handleSizeUp(int index) {
    var currentSize = homeScreenController.sizes[index];
    if (currentSize < crossAxisCount) {
      Obx(() {
        homeScreenController.sizes[index] = currentSize + 1;
      });
    }
  }

  void _handleSelectedItemChanged(int index) {
    Obx(() {
      _selectedIndex = _selectedIndex == index ? null : index;
      homeScreenController.wasDeleted.value = false;
    });
  }
}

class HomeScreenController extends GetxController {
  final wasDeleted = false.obs;
  final isThisFirstTimeForUser = false.obs;
  final areQuestionsFinished = false.obs;
  final sizes = [
    2,
    2,
  ].obs;
}

class Group extends StatelessWidget {
  final int index;
  final int size;
  final ValueChanged<int> onSizeDown;
  final ValueChanged<int> onSizeUp;
  final ValueChanged<int> onSelectedItemChanged;
  final ValueChanged<int> onDelete;
  final int maxSize;
  final bool isSelected;
  final String data;

  Group({
    Key key,
    @required this.data,
    @required this.index,
    @required this.size,
    @required this.onSizeDown,
    @required this.onSizeUp,
    @required this.onSelectedItemChanged,
    @required this.maxSize,
    @required this.isSelected,
    @required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = <Widget>[
      new Padding(
        padding: new EdgeInsets.all(isSelected ? 8.0 : 0.0),
        child: new Card(
          color: Colors.green,
          child: new InkWell(
            onLongPress: () => onSelectedItemChanged(index),
            child: new Center(
              child: new Card(
                color: Colors.white,
                child: new Text('$data'),
              ),
            ),
          ),
        ),
      ),
    ];

    if (isSelected) {
      widgets.add(_buildTileButton(_kCloseTileButton));
      widgets.add(_buildTileButton(_kDeleteTileButton));

      if (size > 1) {
        widgets.add(_buildTileButton(_kSizeDownTileButton));
      }

      if (size < maxSize) {
        widgets.add(_buildTileButton(_kSizeUpTileButton));
      }
    }

    return new Stack(children: widgets);
  }

  Widget _buildTileButton(_TileButton tileButton) {
    return new Positioned(
      top: tileButton.top,
      bottom: tileButton.bottom,
      left: tileButton.left,
      right: tileButton.right,
      child: new GestureDetector(
        onTap: () {
          print('tilebutton tap');
          return tileButton.onTap(this);
        },
        onLongPress: () {
          print('group longpress');
        },
        child: new CircleAvatar(
          radius: 16.0,
          backgroundColor: Colors.teal,
          child: new Text(tileButton.text),
        ),
      ),
    );
  }
}

final _TileButton _kSizeDownTileButton = new _TileButton(
  text: '-',
  isLeft: true,
  isTop: false,
  onTap: (Group tile) => tile.onSizeDown(tile.index),
);

final _TileButton _kSizeUpTileButton = new _TileButton(
  text: '+',
  isLeft: false,
  isTop: false,
  onTap: (Group tile) => tile.onSizeUp(tile.index),
);

final _TileButton _kCloseTileButton = new _TileButton(
  text: 'x',
  isLeft: false,
  isTop: true,
  onTap: (Group tile) => tile.onSelectedItemChanged(tile.index),
);

final _TileButton _kDeleteTileButton = new _TileButton(
  text: '🔥',
  isLeft: true,
  isTop: true,
  onTap: (Group tile) => tile.onDelete(tile.index),
);

class _TileButton {
  const _TileButton({
    @required this.text,
    @required this.onTap,
    @required bool isLeft,
    @required bool isTop,
  })  : bottom = isTop ? null : 0.0,
        top = isTop ? 0.0 : null,
        left = isLeft ? 0.0 : null,
        right = isLeft ? null : 0.0;

  final double bottom;
  final double top;
  final double left;
  final double right;
  final String text;
  final ValueChanged<Group> onTap;
}
