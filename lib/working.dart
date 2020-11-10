import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert' as convert;

class HomeScreen2 extends StatefulWidget {
  static const String homeScreenRoute = '/home';
  @override
  final String title;
  HomeScreen2({this.title});
  _HomeScreenState2 createState() => _HomeScreenState2();
}

class _HomeScreenState2 extends State<HomeScreen2> {
  _HomeScreenState2() : crossAxisCount = 4;

  List<int> _sizes = [
    2,
    2,
  ];

  List<String> _dataForGroups = [
    "Manage Groups", // TODO: animation of blinking on initial setup
    "Synchronize with phone to add contacts",
  ];

  int _selectedIndex;
  final int crossAxisCount;
  String token = '';
  bool wasDeleted = false;
  bool isThisFirstTimeForUser = true; // get this from backend
  bool areQuestionsFinished = false; // set this from backend

  void didChangeDependencies() {
    token = ModalRoute.of(context).settings.arguments;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _initialSetup(true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'fasadin'), // TODO: do PUFF animation, perks are inside profile, here will be perks
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
              itemCount: _sizes.length,
              itemBuilder: (BuildContext context, int index) => new Group2(
                data: _dataForGroups[index],
                key: new ObjectKey(index),
                index: index,
                size: _sizes[index],
                onSizeDown: _handleSizeDown,
                onSizeUp: _handleSizeUp,
                onSelectedItemChanged: _handleSelectedItemChanged,
                onDelete: _handleDelete,
                maxSize: crossAxisCount,
                isSelected: _selectedIndex == index && !wasDeleted,
              ),
              // for now only squers are allowed, in future think if rectangle is needed
              staggeredTileBuilder: (int index) => new StaggeredTile.count(
                _sizes[index],
                _sizes[index],
              ),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        //TODO:  There is blinking arrow with animation that looks like it wants me to drag it out
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('those are favorites from user ⭐'),
              ElevatedButton(
                onPressed: _closeEndDrawer,
                child: const Text('Close Drawer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initialSetup(bool isAnimationFinished) {
    //check if new user
    //prompt if gameexpierence should be enable
    //if no, turn off all nice/colorful stuff, enable only needed animations (to be determinated) like grupie icon
    //if yes ask 3 question with nice animations based on that find and add groups if exists to homepage
  }

  //TODO: add puff animation
  void _handleDelete(int index) {
    setState(() {
      wasDeleted = true;
      _sizes.removeAt(index);
    });
  }

  void _handleSizeDown(int index) {
    var currentSize = _sizes[index];
    if (currentSize > 0) {
      setState(() {
        _sizes[index] = currentSize - 1;
      });
    }
  }

  void _handleSizeUp(int index) {
    var currentSize = _sizes[index];
    if (currentSize < crossAxisCount) {
      setState(() {
        _sizes[index] = currentSize + 1;
      });
    }
  }

  void _handleSelectedItemChanged(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
      wasDeleted = false;
    });
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }
}

class Group2 extends StatelessWidget {
  final int index;
  final int size;
  final ValueChanged<int> onSizeDown;
  final ValueChanged<int> onSizeUp;
  final ValueChanged<int> onSelectedItemChanged;
  final ValueChanged<int> onDelete;
  final int maxSize;
  final bool isSelected;
  final String data;

  Group2({
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
          print('tilebutton clicked');
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
  onTap: (Group2 tile) => tile.onSizeDown(tile.index),
);

final _TileButton _kSizeUpTileButton = new _TileButton(
  text: '+',
  isLeft: false,
  isTop: false,
  onTap: (Group2 tile) => tile.onSizeUp(tile.index),
);

final _TileButton _kCloseTileButton = new _TileButton(
  text: 'x',
  isLeft: false,
  isTop: true,
  onTap: (Group2 tile) => tile.onSelectedItemChanged(tile.index),
);

final _TileButton _kDeleteTileButton = new _TileButton(
  text: '🔥',
  isLeft: true,
  isTop: true,
  onTap: (Group2 tile) => tile.onDelete(tile.index),
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
  final ValueChanged<Group2> onTap;
}
