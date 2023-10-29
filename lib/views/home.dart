import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact/controllers/auth_services.dart';
import 'package:contact/controllers/crud_services.dart';
import 'package:contact/views/update_contact.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<QuerySnapshot> _stream;
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

@override
  void initState() {
    _stream=CRUDService().getContacts();
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _stream.drain();
    super.dispose();
  }

  getContacts(){
     _stream=CRUDService().getContacts();
  }

  // search function logic 

  searchContacts(String search){
    _stream = CRUDService().getContacts(searchQuery: search);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts"),
      //SearchBox Logic
      bottom: PreferredSize(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child:   SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      onChanged: (value) {
                        searchContacts(value);
                        setState(() {});
                      },
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      decoration: InputDecoration(border: OutlineInputBorder(),
                      label: Text("Search"), 
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text
                      .isNotEmpty? IconButton(onPressed: (){
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                        getContacts();
                        
                      }, icon: Icon(Icons.close))
                      :null
                      ),
                  )),
        ),
        preferredSize: Size(MediaQuery.of(context).size.width*8, 80)),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.pushNamed(context, "/add");
      }, 
        child: Icon(Icons.person_add),
        ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.end,
                // crossAxisAlignment: CrossAxisAlignment.start,
                
                children: [
            CircleAvatar(
              maxRadius: 35,
              child: Text(FirebaseAuth.instance.currentUser!.email
              .toString()[0]
              .toUpperCase()),
            ),
            SizedBox(height: 10,),
            Text(FirebaseAuth.instance.currentUser!.email.toString())
          ],
          )),
          ListTile(
            onTap: (){
              AuthService().logout();
              ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Logged Out")));
              Navigator.pushReplacementNamed(context, "/login");
            },
            leading: Icon(Icons.logout_outlined),
            title: Text("Logout"),
          )
          ],
        )),

        body: StreamBuilder <QuerySnapshot> (
          stream: _stream,
          builder: ( BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){

          if(snapshot.hasError){
            return Text("Something Went Wrong");
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(
              child: Text("Loading"),
            );
          }
          return ListView(
            children : snapshot
            .data!.docs.map((DocumentSnapshot document){
              Map<String,dynamic> data = document.data()! as Map<String,dynamic>;
              return ListTile(
                onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (context)=> 
                UpdateContact(
                  name:data["name"],
                  phone:data["phone"], 
                  email:data["email"],
                  profile: (data['profile'] !=  null) ? data['profile'] : "",
                  docID: document.id))),
                leading: CircleAvatar(
                  backgroundImage:NetworkImage((data['profile'] != null) ? data['profile'] : ''),
                  child: (data['profile'] == null) ? Text(data["name"][0]) : null
                  ),
                title: Text(data["name"]),
                subtitle: Text(data["phone"]),
                trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: (){},
                   ),
              );
            }).toList().cast(),
          );
        }),
    );
  }
}

