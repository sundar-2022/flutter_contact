import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRUDService{
  User? user = FirebaseAuth.instance.currentUser;

  //we're adding new contacts here
Future addNewContacts(String name, String phone, String email,String profile)async{
  Map<String,dynamic> data = {
    "name":name,
    "email":email,
    "phone":phone,
    "profile":profile
  };
  try{
      await FirebaseFirestore.instance.collection("users")
      .doc(user!.uid).collection("contacts").add(data);
      print("Document Added");
  }
  catch(e){
      print(e.toString());
  }
 }

 //read from fireStore

Stream<QuerySnapshot> getContacts({String? searchQuery}) async*{
    var contactsQuery = FirebaseFirestore.instance
    .collection("users")
    .doc(user!.uid)
    .collection("contacts")
    .orderBy("name");

    //a filter to seach

    if(searchQuery!=null && searchQuery.isNotEmpty){
      String searchEnd = searchQuery + "\uf8ff";
      contactsQuery = contactsQuery.where("name" , isGreaterThanOrEqualTo: searchQuery, isLessThan: searchEnd );
    }

  var contacts = contactsQuery.snapshots();
    yield* contacts;
 }

 //update a contact
Future updateContacts(String name, String phone, String email, String docID,String profile)async{
  Map<String,dynamic> data = {
    "name":name,
    "email":email,
    "phone":phone,
    "profile":profile
  };
  try{
      await FirebaseFirestore.instance
      .collection("users")
      .doc(user!.uid)
      .collection("contacts")
      .doc(docID)
      .update(data);
      print("Document Updated");
  }
  catch(e){
      print(e.toString());
  }
 }

 //delete contacts from firestore

 Future deleteContact(String docID) async{
  try{
    await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("contacts")
          .doc(docID)
          .delete();
          print("Contact Deleted");
  }catch(e){
    print(e.toString());
  }
 }
}

