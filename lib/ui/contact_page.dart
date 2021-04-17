import 'dart:io';

import 'package:app_agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _contactEdit = false;
  Contact _editedContact;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  Future<bool> _requestPop() {
    if (_contactEdit) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Deseja descartar as alterações?"),
              content: Text("Se sim, todas as suas alterações serão perdidas"),
              actions: [
                // ignore: deprecated_member_use
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
            title: Text(_editedContact.name ?? "Novo Contato"),
            backgroundColor: Colors.red,
            centerTitle: true),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
          onPressed: () {
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            }
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null
                              ? FileImage(File(_editedContact.img))
                              : AssetImage('images/person.png'),
                          fit: BoxFit.cover)),
                ),
                onTap: () {
                  // ignore: invalid_use_of_visible_for_testing_member
                  ImagePicker.platform
                      .pickImage(source: ImageSource.camera)
                      .then((file) {
                    if (file != null) {
                      setState(() {
                        _editedContact.img = file.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _contactEdit = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                onChanged: (text) {
                  _contactEdit = true;
                  _editedContact.email = text;
                },
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Telefone"),
                keyboardType: TextInputType.phone,
                onChanged: (text) {
                  _contactEdit = true;
                  _editedContact.phone = text;
                },
              )
            ],
          ),
        ),
      ),
      onWillPop: _requestPop,
    );

    // ignore: dead_code
  }
}
