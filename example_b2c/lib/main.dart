import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:omar_aad_oauth/aad_oauth.dart';
import 'package:omar_aad_oauth/model/config.dart';

void main() => runApp(MyApp());

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAD B2C Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AAD B2C Home'),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final Config configB2Ca = Config(
    customDomainUrlWithTenantId: 'https://win-k4v3p7r1ff2.sso.id',
    policy: "adfs",
    clientId: '82b0d4fd-419c-41b3-8c06-40c9b6bab0fa',
    scope: 'openid profile Emloyee offline_access',
    navigatorKey: navigatorKey,
    isB2C: true,
    tenant: '',
    loader: const SizedBox(),
  );

  static final Config configB2Cb = Config(
      tenant: 'YOUR_TENANT_NAME',
      clientId: 'YOUR_CLIENT_ID',
      scope: 'YOUR_CLIENT_ID offline_access',
      navigatorKey: navigatorKey,
      clientSecret: 'YOUR_CLIENT_SECRET',
      isB2C: true,
      policy: 'YOUR_USER_FLOW___USER_FLOW_B',
      tokenIdentifier: 'UNIQUE IDENTIFIER B',
      loader: SizedBox());

  static final Config configB2Cc = Config(
      tenant: 'YOUR_TENANT_NAME',
      clientId: 'YOUR_CLIENT_ID',
      scope: 'YOUR_CLIENT_ID offline_access',
      navigatorKey: navigatorKey,
      redirectUri: 'YOUR_REDIRECT_URL',
      isB2C: true,
      policy: 'YOUR_CUSTOM_POLICY',
      tokenIdentifier: 'UNIQUE IDENTIFIER C',
      customParameters: {'YOUR_CUSTOM_PARAMETER': 'CUSTOM_VALUE'},
      loader: SizedBox());

  //You can have as many B2C flows as you want

  final AadOAuth oauthB2Ca = AadOAuth(configB2Ca);
  final AadOAuth oauthB2Cb = AadOAuth(configB2Cb);
  final AadOAuth oauthB2Cc = AadOAuth(configB2Cc);

  @override
  Widget build(BuildContext context) {
    // adjust window size for browser login

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'AzureAD B2C A',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              logout(oauthB2Ca);
              login(oauthB2Ca);
            },
          ),
          ListTile(
            leading: Icon(Icons.data_array),
            title: Text('HasCachedAccountInformation'),
            onTap: () => hasCachedAccountInformation(oauthB2Ca),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              logout(oauthB2Ca);
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              'AzureAD B2C B',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login(oauthB2Cb);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              logout(oauthB2Cb);
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              'AzureAD B2C C',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login(oauthB2Cc);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              logout(oauthB2Cc);
            },
          ),
        ],
      ),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login(AadOAuth oAuth) async {
    final result = await oAuth.login();
    result.fold(
      (l) => showError(l.toString()),
      (r) => showMessage('Logged in successfully, your access token: $r'),
    );

    var accessToken = await oAuth.getAccessToken();
    var idToken = await oAuth.getIdToken();

    if (idToken != null) {
      log('idToken : $idToken');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(idToken)));
    }
  }

  void hasCachedAccountInformation(AadOAuth oAuth) async {
    var hasCachedAccountInformation = await oAuth.hasCachedAccountInformation;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('HasCachedAccountInformation: $hasCachedAccountInformation'),
      ),
    );
  }

  void logout(AadOAuth oAuth) async {
    await oAuth.logout();
    showMessage('Logged out');
  }
}
