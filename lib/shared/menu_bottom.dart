import 'package:flutter/material.dart';

class MenuBottom extends StatefulWidget {
  const MenuBottom(this.index, {Key? key}) : super(key: key);

  final int index;

  @override
  State<MenuBottom> createState() => _MenuBottomState();
}

class _MenuBottomState extends State<MenuBottom> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.index,
      onTap: (int index) {
        switch (index) {
          case 0:
            if (widget.index == 0) {
              break;
            }
            else {
              Navigator.pop(context);
            }
            break;
          case 1:
            if (widget.index == 1) break;
            Navigator.pushNamed(context, '/user');
            break;
          default:
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home,),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'user',
        ),
      ],
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.grey,
    );
  }
}
