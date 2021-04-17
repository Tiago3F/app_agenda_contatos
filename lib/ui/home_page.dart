import 'dart:io';

import 'package:app_agenda_contatos/helpers/contact_helper.dart';
import 'package:app_agenda_contatos/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> _contacts = List();

  List<Contact> contactsFilter = List();
  TextEditingController _searchController = new TextEditingController();

  void _getAllContacts() {
    helper.getAllContact().then((list) {
      setState(() {
        _contacts = list;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    /* Contact c = Contact();
    c.name = "Tiago";
    c.email = "tiagomoreira@gmail.com";
    c.phone = "293203";
    c.img = "img";
    helper.saveContact(c).then((contact) {
      print(contact.id);
    }); */
    _getAllContacts();
  }

  void searchContacts(String text) {
    if (text.isEmpty) {
      _searchController.text = "";
      _getAllContacts();
    } else {
      print(text);
      helper.searchContact(text).then((contact) {
        setState(() {
          _contacts = contact;
        });
      });
    }
  }

  Widget _contactCard(BuildContext context, int index) {
    var contact = _contacts[index];
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contact.img != null
                            ? FileImage(File(contact.img))
                            : AssetImage('images/person.png'),
                        fit: BoxFit.cover)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contact.name ?? "",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(contact.email ?? "",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                    Text(contact.phone ?? "",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, contact);
      },
    );
  }

  void _showOptions(BuildContext context, Contact contact) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          // ignore: missing_required_param
          return BottomSheet(
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ignore: deprecated_member_use
                    FlatButton(
                      child: Text(
                        "Ligar",
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      onPressed: () {
                        launch("tel:${contact.phone}");
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Editar",
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contact);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Remover",
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      onPressed: () {
                        print(contact);
                        helper.deleteContact(contact.id).then((value) {
                          Navigator.pop(context);
                          _getAllContacts();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
            onClosing: () {},
          );
        });
  }

  void _showContactPage({Contact contact}) async {
    final redContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    if (redContact != null) {
      if (contact != null) {
        await helper.updateContact(redContact);
      } else {
        await helper.saveContact(redContact);
      }
      _getAllContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: () {
          _showContactPage();
        },
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Container(
              child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquise pelo Contato',
                    border: OutlineInputBorder(
                      borderSide:
                          new BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onChanged: searchContacts),
            ),
            Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    return _contactCard(context, index);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
