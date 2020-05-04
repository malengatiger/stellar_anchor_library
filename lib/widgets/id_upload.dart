import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stellar_anchor_library/api/net.dart';
import 'package:stellar_anchor_library/models/agent.dart';
import 'package:stellar_anchor_library/models/client.dart';
import 'package:stellar_anchor_library/util/functions.dart';
import 'package:stellar_anchor_library/util/prefs.dart';
import 'package:stellar_anchor_library/util/util.dart';

import 'mobile_registration.dart';

class IDUpload extends StatefulWidget {
  final Client client;
  final Agent agent;
  final PageListener pageListener;

  const IDUpload(
      {Key key, this.client, this.agent, @required this.pageListener})
      : super(key: key);
  @override
  _IDUploadState createState() => _IDUploadState();
}

class _IDUploadState extends State<IDUpload> {
  File _imageFront, _imageBack;
  String _id, _name;
  bool isBusy = false;
  List<BottomNavigationBarItem> _items = [];
  var _key = GlobalKey<ScaffoldState>();
  ClientCache _clientCache;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _id = widget.client.clientId;
      _name = widget.client.personalKYCFields == null
          ? null
          : widget.client.personalKYCFields.getFullName();
    }
    if (widget.agent != null) {
      _id = widget.agent.agentId;
      _name = widget.agent.personalKYCFields == null
          ? null
          : widget.agent.personalKYCFields.getFullName();
    }

    _getCache();
  }

  _getCache() async {
    _clientCache = await Prefs.getClientCache();
    if (_clientCache != null) {
      if (_clientCache.idFrontPath != null) {
        _imageFront = File(_clientCache.idFrontPath);
      }
      if (_clientCache.idBackPath != null) {
        _imageBack = File(_clientCache.idBackPath);
      }
      _id = _clientCache.client.clientId;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getImageFront() async {
    _imageFront = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {});
  }

  Future _getImageBack() async {
    _imageBack = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {});
  }

  Future _uploadIDDocs() async {
    p('.... 💧💧💧 Preparing to upload ID ... $_id');
    if (_imageFront == null) {
//      AppSnackBar.showErrorSnackBar(
//          scaffoldKey: _key, message: 'Please get front of ID');
      return;
    }
    if (_imageBack == null) {
//      AppSnackBar.showErrorSnackBar(
//          scaffoldKey: _key, message: 'Please get back of ID');
      return;
    }
    p('💧💧💧 Calling NetUtil ... $_id ........');
    setState(() {
      isBusy = true;
    });
    try {
      var resp = await NetUtil.uploadIDDocuments(
          id: _id, idFront: _imageFront, idBack: _imageBack);
      p(resp);
//      AppSnackBar.showSnackBar(
//          scaffoldKey: _key,
//          message: 'ID uploaded OK',
//          textColor: Colors.greenAccent,
//          backgroundColor: Colors.black);
    } catch (e) {
      p('😈😈😈😈 Boss, we done fucked, 😈😈 shit don\'t work!');
//      AppSnackBar.showErrorSnackBar(
//          scaffoldKey: _key, message: 'Boss, we no can upload');
    }
    setState(() {
      isBusy = false;
    });
  }

  _buildNav() {
    _items.add(BottomNavigationBarItem(
        icon: Icon(Icons.camera_alt), title: Text('Get Front')));
    _items.add(BottomNavigationBarItem(
        icon: Icon(Icons.photo_library), title: Text('Get Back')));
    _items.add(BottomNavigationBarItem(
        icon: Icon(Icons.cloud_upload), title: Text('Upload ID')));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView(
          children: <Widget>[
            Container(
              height: 360,
              decoration:
                  BoxDecoration(boxShadow: customShadow, color: secondaryColor),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Front of ID',
                        style: Styles.blackBoldMedium,
                      ),
                    ),
                    _imageFront == null
                        ? Opacity(
                            child: Image.asset('assets/images/id1.jpeg'),
                            opacity: 0.3,
                          )
                        : Image.file(_imageFront),
                    Spacer(),
                    RaisedButton(
                      color: Colors.pink[300],
                      elevation: 4,
                      child: Text(
                        'Upload Front of ID',
                        style: Styles.whiteSmall,
                      ),
                      onPressed: () {
                        p('💙💙💙 Upload front of ID');
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              height: 360,
              decoration:
                  BoxDecoration(boxShadow: customShadow, color: secondaryColor),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Back of ID', style: Styles.blackBoldMedium),
                    ),
                    _imageBack == null
                        ? Opacity(
                            opacity: 0.3,
                            child: Image.asset('assets/images/id2.png'),
                          )
                        : Image.file(_imageBack),
                    Spacer(),
                    RaisedButton(
                      color: Colors.indigo[300],
                      elevation: 4,
                      child: Text(
                        'Upload Back of ID',
                        style: Styles.whiteSmall,
                      ),
                      onPressed: () {
                        p('💙💙💙 Upload front of ID');
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onNavTapped(int value) {
    p('navigation button tapped: $value');
    switch (value) {
      case 0:
        _getImageFront();
        break;
      case 1:
        _getImageBack();
        break;
      case 2:
        _uploadIDDocs();
        break;
    }
  }
}
