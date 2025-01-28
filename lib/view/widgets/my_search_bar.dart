import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_constants.dart';

class MySearchBar extends StatefulWidget {
  final Function(String) performSearch;
  final String hintText;

  const MySearchBar({
    super.key,
    required this.performSearch,
    this.hintText = 'SEARCH...',
  });

  @override
  MySearchBarState createState() => MySearchBarState();
}

class MySearchBarState extends State<MySearchBar> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch(String query) {
    // Arama işlemi için dışarıdan gelen fonksiyonu çağır
    widget.performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.h,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: myThightStyle(),
          prefixIcon: GestureDetector(
            onTap: () {
              _performSearch(_searchController.text);
            },
            child: Icon(
              Icons.search,
              color: myIconsColor,
              size: 17.w,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: myIconsColor,
                    size: 13.w,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    // _performSearch(_searchController.text);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: myPrimaryColor,
        ),
        onSubmitted: (query) {
          // Klavyede Enter tuşuna basıldığında arama yapılır
          _performSearch(query);
        },
      ),
    );
  }

  // @override
  // void dispose() {
  //   _searchController.dispose();
  //   super.dispose();
  // }
}
