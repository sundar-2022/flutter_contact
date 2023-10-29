import 'package:contact/controllers/crud_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UpdateContact extends StatefulWidget {
  const UpdateContact({super.key, required this.docID, required this.name, required this.phone, required this.email, required this.profile});
  final String docID,name,phone,email,profile;

  @override
  State<UpdateContact> createState() => _UpdateContactState();
}

class _UpdateContactState extends State<UpdateContact> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String imageUrl = '';

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController.text = widget.email;
    _phoneController.text = widget.phone;
    _nameController.text = widget.name;
    imageUrl = widget.profile;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Contact")),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 25,),
                CircleAvatar(
              maxRadius: 35,
              // child: Text("Vicky"
              // .toString()[0]
              // .toUpperCase()),
              backgroundImage:NetworkImage(imageUrl),
              child: (imageUrl == '') ? IconButton(onPressed: () async{
                        ImagePicker imagePicker = ImagePicker();
                        XFile? file =await imagePicker.pickImage(source: ImageSource.gallery);
                        if(file == null) return;
                        print(file?.path);
                        String uniqueName = '${file?.name}_'+DateTime.now().millisecondsSinceEpoch.toString();
                        Reference reference = FirebaseStorage.instance.ref();
                        Reference referenceImages = reference.child('profile_pictures');

                        Reference referenceToUpload = referenceImages.child(uniqueName);
                        try{
                           await referenceToUpload.putFile(File(file!.path));
                           imageUrl = await referenceToUpload.getDownloadURL();
                           print(imageUrl);
                        }catch(error){
                          print(error.toString());
                        }

                      }, icon: Icon(Icons.camera_alt)) : SizedBox(height: 0)
            ),

                SizedBox(height: 25,),
                
                 SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      validator: (value) => value!.isEmpty?"Enter any name":null,
                      controller: _nameController,
                      decoration: InputDecoration(border: OutlineInputBorder(),
                      label: Text("Name"), 
                      ),
                  )),
                  SizedBox(height: 15,),
                
                 SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(border: OutlineInputBorder(),
                      label: Text("Phone"), 
                      ),
                  )),
                  SizedBox(height: 15,),
                
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(border: OutlineInputBorder(),
                      label: Text("Email"), 
                      ),
                  )),
                 
                  SizedBox(height: 15,),
                
                   SizedBox( 
                    height: 65,
                    width: MediaQuery.of(context).size.width * .9,
                    child: ElevatedButton(onPressed: (){
                      if(formKey.currentState!.validate()){
                        // print(imageUrl)
                        CRUDService().updateContacts(_nameController.text, 
                        _phoneController.text, _emailController.text, widget.docID,imageUrl);
                        Navigator.pop(context);
                      }
                    }, 
                    child: Text("Update",
                     style: TextStyle(fontSize: 20),
                    ))),

                     SizedBox(height: 15,),
                
                   SizedBox( 
                    height: 65,
                    width: MediaQuery.of(context).size.width * .9,
                    child: OutlinedButton(onPressed: (){
                      CRUDService().deleteContact(widget.docID);
                      Navigator.pop(context);
                    }, 
                    child: Text("Delete",
                     style: TextStyle(fontSize: 20),
                    ))),
              ],
            ),
          ),
        ),
      ),
    
    );
}
}