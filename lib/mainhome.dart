import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as Io;
import 'package:permission_handler/permission_handler.dart';
import 'package:flushbar/flushbar.dart';


class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  void initState() {
    super.initState();
  }
  final snackBar = SnackBar(content: Text('Image is Encrypted and Stored in /Storage/emulated/0/SteganMist/EncryptedImage.png'));
  @override
  File _image_encrypt;
  File _image_decrypt;
  File _tempencrypt;
  File _tempdecrypt;
  Directory rootPath;
  String filePath;
  String dirPath;
  bool is_encrypted=false;
  Uint8List convertedbytes;
  Future _getImageGallaryencrypt() async{
    var image = await ImagePicker().getImage(source:ImageSource.gallery);
    setState(() {
      _image_encrypt=File(image.path);
      _tempencrypt=File(image.path);
    });
  }
  Future _getImageCameraencrypt() async{
    var image = await ImagePicker().getImage(source:ImageSource.camera);
    setState(() {
      _image_encrypt=File(image.path);
      _tempencrypt=File(image.path);
    });
  }
  Future _getImageGallarydecrypt() async{
    var image = await ImagePicker().getImage(source:ImageSource.gallery);
    setState(() {
      _image_decrypt=File(image.path);
      _tempdecrypt=File(image.path);
    });
  }
  Future _getImageCameradecrypt() async{
    var image = await ImagePicker().getImage(source:ImageSource.camera);
    setState(() {
      _image_decrypt=File(image.path);
      _tempdecrypt=File(image.path);
    });
  }


  void convertbytes()async{
    int offset=300;
    String token=tokencont.text..toLowerCase().toString();
    String message=msgcont.text.toLowerCase().toString();
    String totalmsg=token+message;
    List<int> messagebinarys = totalmsg.codeUnits;
    print(messagebinarys);
    List<String> messagebytes=List(messagebinarys.length);
    for(int i=0;i<messagebinarys.length;i++){
      messagebytes[i]=messagebinarys[i].toRadixString(2);
    }
    print(messagebytes);
    String expandedmsg='';
    for(int i=0;i<messagebytes.length;i++){
      String temp='';
      if(messagebytes[i].length<8){
        for(int j=0;j<8-messagebytes[i].length;j++){
          temp+='0';
        }
      }
      expandedmsg=expandedmsg+temp+messagebytes[i];
    }
    print(expandedmsg);
    String tokenlength=token.length.toRadixString(2);
    String messagelength=message.length.toRadixString(2);
    if(tokenlength.length<8){
      String st='';
      for(int i=0;i<8-tokenlength.length;i++){
        st+='0';
      }
      tokenlength=st+tokenlength;
    }
    if(messagelength.length<8){
      String st='';
      for(int i=0;i<8-messagelength.length;i++){
        st+='0';
      }
      messagelength=st+messagelength;
    }
    print(tokenlength);
    print(messagelength);
    Uint8List bytes= _tempencrypt.readAsBytesSync();
    Uint8List originalbytes=_tempencrypt.readAsBytesSync();
    print(bytes);
    print(bytes.length);
    int lastbitmask=254;
    for(int i=offset;i<offset+8;i++){
      if(tokenlength[i-offset]=='0'){
        bytes[i]=(bytes[i]&lastbitmask) | 0;
      }
      else{
        bytes[i]=(bytes[i]&lastbitmask) | 1;
      }
    }
    for(int i=offset+8;i<offset+16;i++){
      if(messagelength[i-8-offset]=='0'){
        bytes[i]=(bytes[i]&lastbitmask) | 0;
      }
      else{
        bytes[i]=(bytes[i]&lastbitmask) | 1;
      }
    }
    for(int i=offset+16;i<offset+16+expandedmsg.length;i++){
      if(expandedmsg[i-16-offset]=='0'){
        bytes[i]=(bytes[i]&lastbitmask) | 0;
        print('$i - ${bytes[i]} - ${expandedmsg[i-16-offset]}');
      }
      else{
        bytes[i]=(bytes[i]&lastbitmask) | 1;
        print('$i - ${bytes[i]} - ${expandedmsg[i-16-offset]}');
      }
    }
    //img.Image abcd=img.decodeImage(bytes);

    print(16+expandedmsg.length);
    print(bytes);
    print(bytes.length);
    var dir = await getExternalStorageDirectory();
    print(dir.path);
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    var testdir = await new Io.Directory('/storage/emulated/0/SteganMist').create(recursive: true);
    Io.File('${testdir.path}/OriginalImage.png')..writeAsBytesSync(originalbytes);
    Io.File('${testdir.path}/EncryptedImage.png')..writeAsBytesSync(bytes);
    for(int i=300;i<=400;i++){
      print(bytes[i]);
    }
    //Io.File('${testdir.path}/OriginalJPGtoPNG.png')..writeAsBytesSync(img.encodePng(abcd));
    File open_encrypted= File('${testdir.path}/EncryptedImage.png');
    if(open_encrypted!=null){
      print('file works');
    }
    is_encrypted=true;
    convertedbytes=bytes;
    print(convertedbytes);
    Uint8List recoveredbytes=open_encrypted.readAsBytesSync();
    print(recoveredbytes);
    print(recoveredbytes.length);
  }

  String decryptmsg(){
    int offset=300;
    Uint8List encryptedbytes=_tempdecrypt.readAsBytesSync();
    print(encryptedbytes);
    List<int> powerof2=List(8);
    powerof2[0]=1;
    for(int i=1;i<8;i++){
      powerof2[i]=powerof2[i-1]*2;
    }
    print(powerof2);
    int dectoklen=0;
    int decmsglen=0;
    String decrypttokenlen='';
    String decryptmessagelen='';
    for(int i=offset+0;i<offset+8;i++){
      String temp=encryptedbytes[i].toRadixString(2);
      decrypttokenlen+=temp[temp.length-1];
      if(temp[temp.length-1]=='0'){
      }
      else{
        dectoklen+=powerof2[8-i-1+offset];
      }
    }
    for(int i=offset+8;i<offset+16;i++){
      String temp=encryptedbytes[i].toRadixString(2);
      decryptmessagelen+=temp[temp.length-1];
      if(temp[temp.length-1]=='0'){
      }
      else{
        decmsglen+=powerof2[8-(i-8)-1+offset];
      }
    }
    String decexpandedtoken='';

    for(int i=16+offset;i<16+dectoklen*8+offset;i++){
      String temp=encryptedbytes[i].toRadixString(2);
      decexpandedtoken+=temp[temp.length-1];
    }
    List<String> tokenbytes=List(dectoklen);
    List<int> tokenints=List(dectoklen);
    for(int i=0;i<dectoklen;i++){
      String temp=decexpandedtoken.substring(8*i,8*(i+1));
      tokenbytes[i]=temp;
      int tot=0;
      for(int k=0;k<8;k++){
        if(temp[k]=='0'){}
        else{
          tot+=powerof2[8-k-1];
        }
      }
      tokenints[i]=tot;
    }
    String decryptedtoken=String.fromCharCodes(tokenints);
    String decexpandedmsg='';
    for(int i=16+dectoklen*8+offset;i<16+(dectoklen*8)+(decmsglen*8)+offset;i++){
      String temp=encryptedbytes[i].toRadixString(2);
      decexpandedmsg+=temp[temp.length-1];
    }

    List<String> decmsgbytes=List(decmsglen);
    List<int> decmsgints=List(decmsglen);
    for(int i=0;i<decmsglen;i++){
      String temp=decexpandedmsg.substring(8*i,8*(i+1));
      decmsgbytes[i]=temp;
      int tot=0;
      for(int k=0;k<8;k++){
        if(temp[k]=='0'){}
        else{
          tot+=powerof2[8-k-1];
        }
      }
      decmsgints[i]=tot;
    }
    String decryptedmessage=String.fromCharCodes(decmsgints);
    print(decrypttokenlen);
    print(decryptmessagelen);
    print(dectoklen);
    print(decmsglen);
    print(decexpandedtoken);
    print(decexpandedtoken.length);
    print(tokenbytes);
    print(tokenints);
    print(decryptedtoken);
    print(decexpandedmsg);
    print(decmsgbytes);
    print(decmsgints);
    print(decryptedmessage);
    if(decryptedtoken!=dectokencont.text.toString()){
      decryptedmessage='False Token';
      err1='False Token';
    }
    print(decryptedmessage);
    return decryptedmessage;
  }

  void _showdialog(int i) async{
    showDialog(
      context:context,
      builder: (BuildContext context){
        return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Select Camera or Gallery'),
            content: Container(
              width:MediaQuery.of(context).size.width*0.65,
              height: MediaQuery.of(context).size.height*0.06,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    padding: EdgeInsets.all(0),
                    color: Colors.blueAccent,
                    minWidth: MediaQuery.of(context).size.width*0.30,
                    height: MediaQuery.of(context).size.height*0.05,
                    onPressed: () { setState(() {
                      if(i==1){
                        _getImageCameraencrypt();
                      }
                      else{
                        _getImageCameradecrypt();
                      }
                    });
                    Navigator.of(context).pop();
                    },
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.photo_camera,color: Colors.white,),
                        Text('CAMERA',style:TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                  MaterialButton(
                    padding: EdgeInsets.all(0),
                    color: Colors.blueAccent,
                    minWidth: MediaQuery.of(context).size.width*0.30,
                    height: MediaQuery.of(context).size.height*0.05,
                    onPressed: () { setState(() {
                      if(i==1){
                        _getImageGallaryencrypt();
                      }
                      else{
                        _getImageGallarydecrypt();
                      }
                    });
                    Navigator.of(context).pop();
                    },
                    child:Row(
                      children: <Widget>[
                        Icon(Icons.image,color: Colors.white,),
                        Text('GALLERY',style:TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                ],
              ),
            )
        );
      },
    );
  }

  String msg;
  String token;
  String err="";
  String err1='';
  String decryptedmsg='';
  TextEditingController tokencont= new TextEditingController();
  TextEditingController msgcont= new TextEditingController();
  TextEditingController dectokencont= new TextEditingController();
  Widget _buildtoken(){
    return TextFormField(
      controller: tokencont,
      decoration: InputDecoration(labelText: 'Secret Token',fillColor: Colors.lightBlueAccent,prefixIcon: Icon(Icons.lock,color:Colors.blue),
      ),
      maxLength: 15,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Token is Required';
        }
        return null;
      },
    );
  }
  Widget _builddectoken(){
    return TextFormField(
      controller: dectokencont,
      decoration: InputDecoration(labelText: 'Secret Token',fillColor: Colors.lightBlueAccent,prefixIcon: Icon(Icons.lock,color:Colors.blue),
      ),
      maxLength: 15,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Token is Required';
        }
        return null;
      },
    );
  }
  Widget _buildmessage(){
    return TextFormField(
      controller: msgcont,
      decoration: InputDecoration(labelText: 'Secret Message',fillColor: Colors.lightBlueAccent,prefixIcon: Icon(Icons.email,color:Colors.blue),
      ),
      maxLength: 15,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Token is Required';
        }
        return null;
      },
    );
  }
  final GlobalKey<FormState> _formKey=GlobalKey<FormState>();
  final GlobalKey<FormState> _decformKey=GlobalKey<FormState>();
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
        length: 2,
        child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent[400],
        bottom: TabBar(tabs: <Widget>[
          Tab(text: "Encrypt",),
          Tab(text: "Decrypt",),
    ],),
    centerTitle: true,
    title: Text("Hide Message",style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white70,
    fontSize: 30
    ),),
    ),
    body: TabBarView(
      children: [
        SingleChildScrollView(
          child: Padding(padding: EdgeInsets.only(left: 15,top: 40,bottom: 50,right: 15),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image_encrypt==null? SizedBox(
                height: MediaQuery.of(context).size.height*0.35,
                width:  MediaQuery.of(context).size.width*0.80 ,
                child: Icon(FontAwesomeIcons.plus),
              ):Container(
                height: MediaQuery.of(context).size.height*0.35,
                width:  MediaQuery.of(context).size.width*0.80 ,
                child:Card(
                    child: Image.file(_image_encrypt,fit: BoxFit.cover,)),
              ),
              FlatButton(
                  onPressed: () async{
                    setState(() {
                      _showdialog(1);
                    });
                  },
                  child:Container(
                      width: MediaQuery.of(context).size.width,
                      height:MediaQuery.of(context).size.height*0.06,
                      child:Card(
                        elevation: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.image,color: Colors.redAccent,size:23),
                            SizedBox(width: MediaQuery.of(context).size.width*0.02),
                            Text('Select An Image',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.1),)
                          ],
                        ),
                      )
                  )
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildtoken(),
                    _buildmessage(),
                  ],
                ),
              ),
              FlatButton(
                  onPressed: () async{
                    if(_formKey.currentState.validate()){
                      if(_image_encrypt!=null){
                       setState(() {
                         err="";
                            convertbytes();
                       });
                       print(is_encrypted);
                       if(is_encrypted){
                         Flushbar(
                           message: 'Image Encrypted and stored in /Storage/emulated/0/SteganMist/EncryptedImage.png',
                           icon: Icon(
                             Icons.check_circle_outline_sharp,
                             size: 28.0,
                             color: Colors.greenAccent[400],
                           ),
                           duration: Duration(seconds: 3),
                           leftBarIndicatorColor: Colors.greenAccent[400],
                           margin: EdgeInsets.all(12),
                             flushbarStyle: FlushbarStyle.FLOATING
                         )..show(context);
                       }
                      }
                      else{
                        setState(() {
                          err="No Image Selected to Encrypt";
                        });
                      }
                    }
                  },
                  child:Container(
                      width: MediaQuery.of(context).size.width,
                      height:MediaQuery.of(context).size.height*0.06,
                      child:Card(
                        elevation: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.envelopeSquare,color: Colors.redAccent,size:23),
                            SizedBox(width: MediaQuery.of(context).size.width*0.02),
                            Text('Encrypt',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.1),)
                          ],
                        ),
                      )
                  )
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02,),
              Center(
                child:Text(err==null?'':'$err',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 20),)
              ),

            ],
          ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(padding: EdgeInsets.only(left: 15,top: 40,bottom: 50,right: 15),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image_decrypt==null? SizedBox(
                  height: MediaQuery.of(context).size.height*0.35,
                  width:  MediaQuery.of(context).size.width*0.80 ,
                  child: Icon(FontAwesomeIcons.plus),
                ):Container(
                  height: MediaQuery.of(context).size.height*0.35,
                  width:  MediaQuery.of(context).size.width*0.80 ,
                  child:Card(
                      child: Image.file(_image_decrypt,fit: BoxFit.cover,)),
                ),
                FlatButton(
                    onPressed: () async{
                      setState(() {
                        _showdialog(2);
                      });
                    },
                    child:Container(
                        width: MediaQuery.of(context).size.width,
                        height:MediaQuery.of(context).size.height*0.06,
                        child:Card(
                          elevation: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(FontAwesomeIcons.image,color: Colors.redAccent,size:23),
                              SizedBox(width: MediaQuery.of(context).size.width*0.02),
                              Text('Select An Image',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.1),)
                            ],
                          ),
                        )
                    )
                ),
                Form(
                  key: _decformKey,
                  child: Column(
                    children: [
                      _builddectoken(),
                    ],
                  ),
                ),
                FlatButton(
                    onPressed: () async{
                      if(_decformKey.currentState.validate()){
                        if(_image_decrypt!=null){
                          setState(() {
                            err1="";
                            String x=decryptmsg();
                            setState(() {
                              decryptedmsg=x;
                            });
                          });
                        }
                        else{
                          setState(() {
                            err1="No Image Selected to Encrypt";
                          });
                        }
                      }
                    },
                    child:Container(
                        width: MediaQuery.of(context).size.width,
                        height:MediaQuery.of(context).size.height*0.06,
                        child:Card(
                          elevation: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(FontAwesomeIcons.envelopeSquare,color: Colors.redAccent,size:23),
                              SizedBox(width: MediaQuery.of(context).size.width*0.02),
                              Text('Decrypt',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.1),)
                            ],
                          ),
                        )
                    )
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                Center(
                    child:Text(decryptedmsg.length!=0?'Decrypted Message: ${decryptedmsg.toUpperCase()}':'Decrypted Message:$err1',style: TextStyle(color: Colors.greenAccent,fontWeight: FontWeight.bold,fontSize: 14),)
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                Center(
                    child:Text(err1==null?'':'$err1',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 20),)
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    ),
    ),
    );
  }
}

