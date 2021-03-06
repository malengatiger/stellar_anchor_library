import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/bloc/generic_bloc.dart';
import 'package:stellar_anchor_library/models/stokvel.dart';
import 'package:stellar_anchor_library/ui/scan/member_scan.dart';
import 'package:stellar_anchor_library/util/functions.dart';
import 'package:stellar_anchor_library/util/slide_right.dart';
import 'package:stellar_anchor_library/util/snack.dart';

class SendInvitation extends StatefulWidget {
  @override
  _SendInvitationState createState() => _SendInvitationState();
}

class _SendInvitationState extends State<SendInvitation>
    implements ScannerListener {
  var _key = GlobalKey<ScaffoldState>();
  List<Contact> _contacts = List();
  List<Stokvel> _stokvels = [];
  bool isBusy = false;
  Member _member;

  String filter;

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    setState(() {
      isBusy = true;
    });
    try {
      _member = await genericBloc.getCachedMember();
      _contacts.clear();
      _contacts = await genericBloc.getContacts();
      print('🥦🥦🥦🥦🥦 ${_contacts.length} contacts returned to UI');
      _stokvels = await genericBloc.getStokvelsAdministered(_member.memberId);
      print('🥦🥦🥦🥦🥦 ${_stokvels.length} stokvels returned to UI');
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Contacts failed');
    }
    setState(() {
      isBusy = false;
    });
  }

  bool sendByWhatsapp = false;
  var emailEditor = TextEditingController();
  var cellEditor = TextEditingController();
  Contact selectedContact;
  Stokvel selectedStokvel;
  List<Contact> filteredContacts = [];

  Widget _getDropDownOrText() {
    if (_stokvels.length == 1) {
      selectedStokvel = _stokvels.elementAt(0);
      return Text(
        selectedStokvel.name,
        style: Styles.blackBoldMedium,
      );
    } else {
      List<DropdownMenuItem<Stokvel>> items = [];
      _stokvels.forEach((s) {
        items.add(DropdownMenuItem(child: Text(s.name)));
      });
      return DropdownButton<Stokvel>(
          items: items, onChanged: _onDropDownChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(
          'Send Invitation',
          style: Styles.whiteSmall,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(380),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Image.asset('assets/logo_white.png', height: 36, width: 36),
                SizedBox(
                  height: 8,
                ),
                Text(
                  'Invite your friends and famility to participate in one or more of your Groups',
                  style: Styles.whiteSmall,
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: <Widget>[
                    Text('Invite People Using: '),
                    SizedBox(
                      width: 4,
                    ),
                    Switch(
                      value: sendByWhatsapp,
                      onChanged: onSwitchChanged,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      sendByWhatsapp ? 'Whatsapp' : 'eMail',
                      style: Styles.whiteBoldMedium,
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                _stokvels.isEmpty ? Container() : _getDropDownOrText(),
                SizedBox(
                  height: 8,
                ),
                isBusy
                    ? Container()
                    : TextField(
                        style: Styles.blackSmall,
                        controller: _textController,
                        decoration: InputDecoration(
                            suffix: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _dismissKeyboard();
                                setState(() {
                                  _textController.text = '';
                                  filteredContacts.clear();
                                });
                              },
                            ),
                            hintText: '  Find Contact '),
                        onChanged: (val) {
                          filter = val;
                          _filterContacts();
                        },
                      ),
                SizedBox(
                  height: 16,
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Scan to Invite Member to Group',
                      style: Styles.whiteSmall,
                    ),
                  ),
                  onPressed: _startScan,
                ),
                SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      ),
      body: isBusy
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _submitInvitation(
                            contact: filteredContacts.elementAt(index));
                      },
                      child: Card(
                        color: getRandomPastelColor(),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            Icons.person,
                            color: getRandomColor(),
                          ),
                          title: Text(
                            filteredContacts.elementAt(index).displayName,
                            style: Styles.blackSmall,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
    );
  }

  var _textController = TextEditingController();
  void _submitInvitation({Contact contact, String email}) async {
    if (selectedStokvel == null) {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Please select Group');
      return;
    }
    if (email == null) {
      var emails = contact.emails.toList();
      if (emails.isEmpty) {
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Contact has no email address');
        _displayEmailDialog(contact);
        return;
      } else {
        email = emails.elementAt(0).value;
      }
    }
    print(
        '🌽 🌽 🌽 Creating invite prior to sending .... 🔵 ${contact.displayName} email: 🔵 $email');
    var invite = Invitation(
        email: email,
        date: DateTime.now().toUtc().toIso8601String(),
        stokvel: selectedStokvel);
    if (sendByWhatsapp) {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Whatsapp feature under construction');
      return;
    } else {
      setState(() {
        isBusy = true;
      });
      try {
        var res = await genericBloc.sendInvitationViaEmail(invitation: invite);
        await genericBloc.addInvitation(invite);
        print(res);
      } catch (e) {
        print(e);
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Invitation failed');
        return;
      }
      setState(() {
        isBusy = false;
      });
    }
  }

  void _displayEmailDialog(Contact contact) async {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Enter eMail Address",
                  style: Styles.blackBoldMedium),
              content: Container(
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'eMail Address',
                        hintText: 'Enter invitee eMail address here',
                      ),
                      onChanged: _onTextChanged,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: FlatButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Use SMS',
                        style: TextStyle(
                            color: Theme.of(context).accentColor, fontSize: 14),
                      ),
                    ),
                    onPressed: () {
                      _sendViaSMS(contact);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, left: 40),
                  child: FlatButton(
                    onPressed: () {
                      if (_controller.text.isEmpty) {
                        AppSnackBar.showErrorSnackBar(
                            scaffoldKey: _key,
                            message:
                                'No email found, invitation cannot be sent');
                        return;
                      }
                      _dismissKeyboard();
                      Navigator.pop(context);
                      _submitInvitation(
                          contact: contact, email: _controller.text);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Use eMail',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  Future<void> _sendViaSMS(Contact contact) async {
    _dismissKeyboard();
    Navigator.pop(context);
    setState(() {
      isBusy = true;
    });
    var invite = Invitation(
        cellphone: contact.phones.toList().elementAt(0).value,
        date: DateTime.now().toUtc().toIso8601String(),
        stokvel: selectedStokvel,
        email: null);
    try {
      await genericBloc.sendInvitationViaSMS(invitation: invite);
      await genericBloc.addInvitation(invite);
      print('Looks like we good with the SMS');
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'SMS send failed');
    }
    setState(() {
      isBusy = false;
    });
  }

  void _filterContacts() {
    if (filter.isEmpty) {
      setState(() {
        filteredContacts.clear();
      });
      return;
    }
    debugPrint('🔵 filter contacts here ... from ${_contacts.length}');
    filteredContacts.clear();
    Map<String, Contact> map = Map();
    _contacts.forEach((v) {
      if (v.displayName.toLowerCase().contains(filter)) {
        map[v.displayName] = v;
      }
    });
    map.values.forEach((v) {
      filteredContacts.add(v);
    });
    filteredContacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    debugPrint('🍎 🍎 🍎 filtered contacts: ${filteredContacts.length}');
    setState(() {});
  }

  void _dismissKeyboard() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void onSwitchChanged(bool value) {
    setState(() {
      sendByWhatsapp = value;
    });
  }

  void _onDropDownChanged(Stokvel value) {
    setState(() {
      selectedStokvel = value;
    });

    print('Group selected : ${selectedStokvel.name}');
  }

  void _onTextChanged(String value) {
    print('🧩 $value');
  }

  void _startScan() {
    print('👽 👽 👽 Scan the person to invite ....');
    Navigator.push(
        context,
        SlideRightRoute(
            widget: MemberScanner(
                scannerListener: this, stokvelId: selectedStokvel.stokvelId)));
  }

  @override
  onMemberAlreadyInStokvel(Member member) {
    prettyPrint(member.toJson(),
        "🌽  🌽 Member ALREADY exists in Stokvel ...👌🏾👌🏾👌🏾");
    return null;
  }

  @override
  onMemberScan(Member member) {
    print('SendInvitation: onMemberScan .... ');
    prettyPrint(
        member.toJson(), "👌🏾👌🏾👌🏾 Member just scanned ...👌🏾👌🏾👌🏾");
    return null;
  }
}
