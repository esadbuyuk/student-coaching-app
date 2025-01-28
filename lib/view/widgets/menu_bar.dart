import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_constants.dart';

class MyMenuBar extends StatefulWidget {
  final double scrollBarWidth;
  final FixedExtentScrollController listScrollController;
  final VoidCallback callbackScrollFlag;

  const MyMenuBar({
    Key? key,
    required this.scrollBarWidth,
    required this.listScrollController,
    required this.callbackScrollFlag,
  }) : super(key: key);

  @override
  MyMenuBarState createState() => MyMenuBarState();
}

class MyMenuBarState extends State<MyMenuBar> {
  int _selectedIndex = 1;
  final List<String> _menuItems = ['CHARTS', 'PROFILE', 'STATS'];
  final ScrollController _scrollController = ScrollController();
  late final double _menuItemWidth;
  final double _paddingBetweenItems = 8;
  final int _animatedDurationTime =
      800; // (milliseconds) bu süre değişirse CallBack fonksiyonundaki delayed süresi de değiştirilmeli

  @override
  void initState() {
    super.initState();
    _menuItemWidth =
        (widget.scrollBarWidth - _paddingBetweenItems * 3) / _menuItems.length;
  }

  void _onMenuTap(int index) {
    // bu fonksiyon her çağırıldığında setSelectedIndex fonksiyonu ListWheel tarafından çağırılıyor (gereksiz ama zararsız)

    widget.callbackScrollFlag();
    setSelectedIndex(index);

    double offset = index * _menuItemWidth;
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: _animatedDurationTime),
      curve: Curves.easeInOut,
    );

    widget.listScrollController.animateToItem(
      index,
      duration: Duration(milliseconds: _animatedDurationTime),
      curve: Curves.easeInOut,
    );
  }

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void nextIndex() {
    int nextItemIndex = _selectedIndex + 1;
    if (nextItemIndex < _menuItems.length) {
      _onMenuTap(nextItemIndex);
    } else {
      _onMenuTap(0);
    }
  }

  void previousIndex() {
    int previousItemIndex = _selectedIndex - 1;
    if (previousItemIndex > -1) {
      _onMenuTap(previousItemIndex);
    } else {
      _onMenuTap(_menuItems.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMenuList(),
        _buildScrollBar(),
      ],
    );
  }

  Widget _buildMenuList() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        itemCount: _menuItems.length,
        itemBuilder: (context, index) => _buildMenuItem(index),
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    return GestureDetector(
      onTap: () => _onMenuTap(index),
      child: Padding(
        padding: EdgeInsets.only(
          right: index == _menuItems.length - 1
              ? 0
              : _paddingBetweenItems, // Son öğede padding yok
        ),
        child: Container(
          decoration: BoxDecoration(
              //border: Border.all(color: myPrimaryColor),
              borderRadius: BorderRadius.all(Radius.circular(8.r))),
          width: _menuItemWidth,
          alignment: Alignment.center,
          child: Text(
            _menuItems[index],
            style: myTonicStyle(
              _selectedIndex == index ? myIconsColor : myPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollBar() {
    return Container(
      height: 28.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: myPrimaryColor),
        borderRadius: BorderRadius.all(Radius.circular(5.r)),
      ),
      child: Stack(
        children: [
          Container(
            height: 4.h,
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _selectedIndex * _menuItemWidth +
                _selectedIndex * _paddingBetweenItems,
            child: Container(
              alignment: Alignment.center,
              height: 4.h,
              width: _menuItemWidth,
              child: Container(
                color: myIconsColor,
                width: 36.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
