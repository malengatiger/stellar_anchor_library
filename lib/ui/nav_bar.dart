import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/ui/send_invitation.dart';
import 'package:stellar_anchor_library/ui/send_money.dart';
import 'package:stellar_anchor_library/util/slide_right.dart';

import 'member_statement.dart';

const TYPE_ADMIN = 'admin', TYPE_MEMBER = 'member';

class StokkieNavBar extends StatelessWidget {
  final String type;
  final String memberId;

  StokkieNavBar(this.memberId, this.type);

  @override
  Widget build(BuildContext context) {
    void _navigate(int index) {
      switch (index) {
        case 0:
          Navigator.push(
              context,
              SlideRightRoute(
                widget: SendInvitation(),
              ));
          break;
        case 1:
          Navigator.push(
              context,
              SlideRightRoute(
                widget: MemberStatement(memberId),
              ));
          break;
        case 2:
          Navigator.push(
              context,
              SlideRightRoute(
                widget: SendMoney(),
              ));
          break;
      }
    }

    final List<BottomNavigationBarItem> _items = List();
    _items.add(BottomNavigationBarItem(
        icon: Icon(Icons.email), title: Text('Invitations')));
    _items.add(BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet), title: Text('Statements')));
    _items.add(BottomNavigationBarItem(
        icon: Icon(Icons.send), title: Text('Send Money')));
    return BottomNavigationBar(
      items: _items,
      onTap: _navigate,
    );
  }
}
