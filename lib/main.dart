import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'utils/model.dart';
import 'package:encrypt/encrypt.dart' as Crypto;
import 'package:flushbar/flushbar.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget{
  Widget build(BuildContext ctx)=>MaterialApp(theme:ThemeData(primarySwatch:Colors.blueGrey),home:AuthPage());
}

class AuthPage extends StatefulWidget{_AuthPageState createState()=>_AuthPageState();}
class _AuthPageState extends State<AuthPage>{
  final LocalAuthentication _auth=LocalAuthentication();
  bool _isAuthorized= false;
  _authorizeNow()async{
    bool authorize=false;
    try{ authorize=await _auth.authenticateWithBiometrics(localizedReason:"Authenticate to open the vault",useErrorDialogs:true,stickyAuth:true);
    } on PlatformException catch(e){print(e);}
    if (!mounted) return false;
    setState((){(authorize)?_isAuthorized=true:_isAuthorized=false;});
  }
  Widget build(BuildContext ctx){
    if(_isAuthorized) return Home();
    else _authorizeNow();
    return Container(color:Colors.white);
  }
}

class Home extends StatefulWidget{_HomeState createState()=>_HomeState();}
class _HomeState extends State<Home>{
  DBHelper db=DBHelper();
  List _entries;
  String _key;
  var _cryptor;

  getCryptor(){
    if(_key!=null){
      final key=Crypto.Key.fromUtf8(_key);
      final iv =Crypto.IV.fromLength(16);
      final cryptor=Crypto.Encrypter(Crypto.AES(key,iv));
      if(cryptor!=null) setState((){_cryptor=cryptor;});
    }}

  getEntries()async{
    var entries= await db.getAll();
    setState((){_entries=entries;});
  }

  getKey()async{
    if(Platform.isAndroid){
      AndroidDeviceInfo androidDeviceInfo= await DeviceInfoPlugin().androidInfo;
      setState((){_key=androidDeviceInfo.androidId;});}
    if(Platform.isIOS){
      IosDeviceInfo iosDeviceInfo= await DeviceInfoPlugin().iosInfo;
      setState((){_key=iosDeviceInfo.identifierForVendor;});
    }}

  initState(){
    super.initState();
    getEntries();
    getKey();
    getCryptor();
  }

  addEntry()async{
    await Navigator.push(context,MaterialPageRoute(builder:(BuildContext ctx){
      TextEditingController service=TextEditingController(),user=TextEditingController(),pass=TextEditingController();
      return Scaffold(body:ListView(padding:EdgeInsets.fromLTRB(20.0,100.0,20.0,0.0),
          children: <Widget>[
            Padding(padding:EdgeInsets.all(8.0),child:TextField(controller: service,decoration:InputDecoration(icon:Icon(Icons.language),labelText:"Enter Service",hintText:"Eg: Twitter, Facebook etc"))),
            Padding(padding:EdgeInsets.all(8.0),child:TextField(controller: user,decoration:InputDecoration(icon:Icon(Icons.supervised_user_circle),labelText:"Enter UserName",hintText:"User Name"))),
            Padding(padding:EdgeInsets.all(8.0),child:TextField(controller: pass,decoration:InputDecoration(icon:Icon(Icons.dialpad),labelText:"Enter Password",hintText:"Password"))),
            Padding(padding:EdgeInsets.all(8.0),
                child: RaisedButton.icon(color:Colors.green,label:Text(""),icon:Icon(Icons.save),
                    onPressed:()async{
                      if (service.text.isNotEmpty&&user.text.isNotEmpty&&pass.text.isNotEmpty){
                        getCryptor();
                        Entry e=Entry(service.text,user.text,  _cryptor.encrypt(pass.text).base64);
                        await db.saveEntry(e);
                        Navigator.pop(context);
                      } else{
                        Flushbar(title:"Hey,",message:"Fill all details",duration:Duration(seconds:3))..show(ctx);
                      }}))]));
    }));
    getEntries();
  }

  Widget build(BuildContext ctx)=>Scaffold(appBar:AppBar(title:Text("PassVault"),centerTitle:true),
    body:(_entries==null)?Center(child:CircularProgressIndicator()):
    ListView.builder(itemCount:_entries.length,itemBuilder:(BuildContext ctx,int pos){
      var entry=_entries[pos];
      return Card(elevation:5.0,margin:EdgeInsets.all(5.0),child:ListTile(
          title: Text(entry[SERVICE]),subtitle:Text(entry[USERNAME]),trailing:Row(mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(icon:Icon(Icons.delete),onPressed:()async{
              await db.deleteEntry(entry[ID]);
              getEntries();
            }),
            IconButton(icon: Icon(Icons.search), onPressed:(){
              getCryptor();
              showDialog(context:ctx,builder:(ctx)=>AlertDialog(title: Text("Password"),content: Text(_cryptor.decrypt64(entry[PASSWORD]))));
            })])));
    }),
    floatingActionButton: FloatingActionButton(onPressed:addEntry,child:Icon(Icons.edit)),
  );
}
