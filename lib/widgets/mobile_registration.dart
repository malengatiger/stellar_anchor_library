import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/api/auth.dart';
import 'package:stellar_anchor_library/bloc/agent_bloc.dart';
import 'package:stellar_anchor_library/models/anchor.dart';
import 'package:stellar_anchor_library/models/client.dart';
import 'package:stellar_anchor_library/util/functions.dart';
import 'package:stellar_anchor_library/util/prefs.dart';
import 'package:stellar_anchor_library/util/snack.dart';
import 'package:stellar_anchor_library/util/util.dart';
import 'package:stellar_anchor_library/widgets/id_upload.dart';
import 'package:stellar_anchor_library/widgets/proof_residence_upload.dart';
import 'package:stellar_anchor_library/widgets/selfie_upload.dart';
import 'package:uuid/uuid.dart';

class RegistrationMobile extends StatefulWidget {
  @override
  _RegistrationMobileState createState() => _RegistrationMobileState();
}

class _RegistrationMobileState extends State<RegistrationMobile>
    implements SnackBarListener, PageListener {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool isBusy = false;
  final _controller = PageController();
  Client _client = Client.create();
  ClientCache _clientCache;
  Anchor _anchor;
  Uuid _uuid = Uuid();
  double currentPageValue = 0.0;
  bool formComplete = false,
      idUploaded = false,
      selfieUploaded = false,
      proofOfResidenceUploaded = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      p('PageController event fired.  💙 setting state with page ${_controller.page}');
      setState(() {
        currentPageValue = _controller.page;
      });
    });
    _getAnchor();
  }

  _getCache() async {
    p('⭐️⭐️⭐️ Getting cache for old data input ...');
    _clientCache = await Prefs.getClientCache();
    if (_clientCache != null) {
      _client = _clientCache.client;
      //todo - update form with stuff from client ....
    } else {
      _client.clientId = _uuid.v4();
      _client.anchorId = _anchor == null ? null : _anchor.anchorId;
      _clientCache = ClientCache(client: _client);
      Prefs.saveClientCache(_clientCache);
    }
  }

  _getAnchor() async {
    p('Getting anchor from cache or Database');
    _anchor = await agentBloc.getAnchor();
    if (_anchor != null) {
      _getCache();
    }
  }

  _goToNextPage() {
    p('_goToNextPage using PageController  ');
    int currentPage = currentPageValue as int;
    switch (currentPage) {
      case 0:
        _controller.animateToPage(1,
            duration: Duration(seconds: 1), curve: Curves.easeInOut);
        break;
      case 1:
        _controller.animateToPage(2,
            duration: Duration(seconds: 1), curve: Curves.easeInOut);
        break;
      case 2:
        _controller.animateToPage(0,
            duration: Duration(seconds: 1), curve: Curves.easeInOut);
        break;
    }
  }

  _goToPreviousPage() {
    p('_goToPreviousPage using PageController  ');
    int currentPage = currentPageValue as int;
    switch (currentPage) {
      case 0:
//        _controller.animateToPage(1,
//            duration: Duration(seconds: 1), curve: Curves.easeInOut);
        break;
      case 1:
        _controller.animateToPage(0,
            duration: Duration(seconds: 1), curve: Curves.easeInOut);
        break;
      case 2:
        _controller.animateToPage(1,
            duration: Duration(seconds: 1), curve: Curves.easeInOut);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _key,
        backgroundColor: baseColor,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Client Registration',
            style: Styles.blackSmall,
          ),
          backgroundColor: baseColor,
          bottom: PreferredSize(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.teal,
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Submit Registration',
                            style: Styles.whiteSmall,
                          ),
                        ),
                        onPressed: () {
                          p('🚺 🚺 🚺 🚺 🚺 🚺 Submit Registration ... check and validate client cache  😡  😡');
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              preferredSize: Size.fromHeight(60)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PageView(
            children: <Widget>[
              RegistrationForm(
                client: _client,
                pageListener: this,
              ),
              IDUpload(
                client: _client,
                pageListener: this,
              ),
              SelfieUpload(client: _client, pageListener: this),
              ProofOfResidenceUpload(client: _client, pageListener: this),
            ],
          ),
        ),
      ),
      onWillPop: () => doNothing(),
    );
  }

  Future<bool> doNothing() async {
    return false;
  }

  @override
  onActionPressed(int action) {
    return null;
  }

  @override
  onIDUploaded() {
    p('💙 onIDUploaded ...');
    return null;
  }

  @override
  onProofOfResidenceUploaded() {
    p('🍐 onProofOfResidenceUploaded ...');
    return null;
  }

  @override
  onRegistrationFormComplete() {
    p('🍎 onRegistrationFormComplete ...');
    return null;
  }

  @override
  onSelfieUploaded() {
    p('onSelfieUploaded ...');
    return null;
  }

  @override
  onCancel() {
    p('onCancel ...');
    return null;
  }

  @override
  onNext(String currentPage) {
    p('🍐  🍐  🍐 onNext ... CurrentPageDesc: $currentPage');
    _goToNextPage();
  }

  @override
  onPrevious(String currentPage) {
    p('🍎 🍎 🍎 onPrevious ... CurrentPageDesc: $currentPage');
    _goToPreviousPage();
  }
}

class RegistrationForm extends StatefulWidget {
  final Client client;
  final PageListener pageListener;

  const RegistrationForm(
      {Key key, @required this.client, @required this.pageListener})
      : super(key: key);
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm>
    with SingleTickerProviderStateMixin {
  TextEditingController emailCntr = TextEditingController();
  TextEditingController pswdCntr = TextEditingController();
  AnimationController titleController;
  Animation titleAnimation, btnAnimation;

  bool isBusy = false;
  Animation<double> boxAnimation;
  Animation<double> classificationAnimation;
  Animation<Offset> pulseAnimation;
  Animation<Offset> meanAnimation;
  @override
  void initState() {
    super.initState();
    //todo - remove creds after test
    emailCntr.text = 'a1588261736345@anchor.com';
    pswdCntr.text = 'pTiger3#Word!isWannamaker#23';
    _setUpAnimation();
  }

  _setUpAnimation() {
    titleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    titleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: titleController,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut)));
    btnAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: titleController,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut)));

    titleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        p(".......... 💦 💦 💦 Title Animation completed");
      }
    });

    titleController.forward();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  var _key = GlobalKey<ScaffoldState>();

  void _onEmailChanged(String value) {
    print(value);
  }

  void _signIn() async {
    if (emailCntr.text.isEmpty || pswdCntr.text.isEmpty) {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key,
          message: "Credentials missing or invalid",
          actionLabel: 'Error');
      return;
    }
    setState(() {
      isBusy = true;
    });
    try {
      p('............ Signing in by calling Auth signIn ...');
      var agent = await Auth.signInAgent(
          email: emailCntr.text, password: pswdCntr.text);
      print(
          '🍎 🍎  🍎  🍎 ️signed in ok, ✳️ popping TO dashboard..... AGENT: ${agent.toJson()}');
      Navigator.pop(context, true);
    } catch (e) {
      print(e);
      setState(() {
        isBusy = false;
      });
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key,
          message: 'We have a problem $e',
          actionLabel: 'Err');
    }
  }

  void _onPasswordChanged(String value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 1,
                color: baseColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      ScaleTransition(
                        scale: titleAnimation,
                        alignment: Alignment(0.0, 0.0),
                        child: GestureDetector(
                          onTap: () {
                            titleController.reset();
                            titleController.forward();
                          },
                          child: Row(
                            children: <Widget>[
                              Hero(
                                tag: 'logo',
                                child: Image.asset(
                                  'assets/logo/logo.png',
                                  width: 48,
                                  height: 48,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Client Sign in',
                                style: Styles.blackBoldMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(dummy),
                      SizedBox(
                        height: 40,
                      ),
                      TextField(
                        onChanged: _onEmailChanged,
                        keyboardType: TextInputType.emailAddress,
                        controller: emailCntr,
                        style: Styles.blueBoldSmall,
                        decoration: InputDecoration(
                            hintText: 'Enter  email address',
                            labelText: 'Email'),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      TextField(
                        onChanged: _onPasswordChanged,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        controller: pswdCntr,
                        decoration: InputDecoration(
                            hintText: 'Enter password', labelText: 'Password'),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      ScaleTransition(
                        scale: btnAnimation,
                        child: Container(
                          height: 60,
                          width: 300,
                          decoration: BoxDecoration(
                              boxShadow: customShadow,
                              color: Colors.brown[100]),
                          child: isBusy
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : FlatButton(
                                  onPressed: () {
                                    p('💙 tapped to go logging in ...');
                                    _signIn();
                                  },
                                  child: Text(
                                    "Submit Credentials",
                                    style: Styles.blackBoldSmall,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

abstract class PageListener {
  onRegistrationFormComplete();
  onIDUploaded();
  onProofOfResidenceUploaded();
  onSelfieUploaded();
  onNext(String currentPage);
  onPrevious(String currentPage);
  onCancel();
}
