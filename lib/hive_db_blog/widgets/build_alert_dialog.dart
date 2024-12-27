import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stayease/hive_db_blog/hive_models/cat_model.dart';
import 'package:stayease/hive_db_blog/hive_service_provider.dart';
import 'package:stayease/notifications_channel.dart';

class AddCatAlert extends StatefulWidget {
  final String? state;
  final String? city;
  const AddCatAlert({super.key, this.state, this.city});

  @override
  State<AddCatAlert> createState() => _AddCatAlertState();
}

class _AddCatAlertState extends State<AddCatAlert> {
  bool _isMale = true;
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _ageEditingController = TextEditingController();

  void submit() {
    if (_nameEditingController.text.isNotEmpty &&
        _ageEditingController.text.isNotEmpty) {
      var catModel = CatModel(
        _nameEditingController.text.trim(),
        _ageEditingController.text.trim(),
        _isMale,
        widget.city!=null?widget.city.toString():'',
        widget.state!=null?widget.state.toString():''

      );
      var provider = Provider.of<HiveServiceProvider>(context, listen: false);
      provider.addCat(catModel);
      provider.getCats();
      Navigator.of(context).pop();
      showAnimatedSnackBar(context, 'Tenant Added Successfully');
      Timer(Duration(milliseconds: 2000), createTenantNotification)
  ;
    } else {
      showAnimatedSnackBar(context, 'Please provide all details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // surfaceTintColor: Colors.white,
      shadowColor: Colors.black45,
      // backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Add Tenant",style: TextStyle( fontFamily:'Roboto',fontWeight: FontWeight.bold,color: Colors.deepPurpleAccent),),
          GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
              child: const Icon(Icons.close,color:Colors.deepPurpleAccent,))
        ],
      ),
      content: SizedBox(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-z. A-Z]')), // Allow only alphabets
              ],

              style: const TextStyle(
                // color: Colors.black, // Set the text color to black
                fontSize: 16, // Optional: Set font size
              ),
              controller: _nameEditingController,
              decoration:  InputDecoration(
                suffixIcon: const Icon(Icons.person,color: Colors.deepPurpleAccent,),
                label: const Text("Name"),
                // labelStyle: const TextStyle(color: Colors.black),
                hintText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Colors.black)
                )
              ),
            ),
            const SizedBox(height: 10.0,),
            TextField(
               keyboardType: TextInputType.number,
              style: const TextStyle(
                // color: Colors.black, // Set the text color to black
                fontSize: 16, // Optional: Set font size
              ),              controller: _ageEditingController,
              decoration:  InputDecoration(
                label: const Text("Age"),
                // labelStyle: const TextStyle(color: Colors.black),
                hintText: "Age",
                  suffixIcon: const Icon(Icons.numbers,color: Colors.deepPurpleAccent,),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                          color: Colors.black)
                  )
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text("Gender"),
            RadioListTile(
              activeColor: Colors.deepPurpleAccent,
                title: const Text("Male"),
                value: true,
                groupValue: _isMale,
                onChanged: (value) {
                  setState(() {
                    _isMale = value as bool;
                  });
                }),
            RadioListTile(
              activeColor: Colors.deepPurpleAccent,
                title: const Text("Female"),
                value: false,
                groupValue: _isMale,
                onChanged: (value) {
                  setState(() {
                    _isMale = value as bool;
                  });
                }),
            const Spacer(),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                        backgroundColor:
                            WidgetStateProperty.all(Colors.deepPurpleAccent),
                        padding:
                            WidgetStateProperty.all(const EdgeInsets.all(10)),
                        textStyle: WidgetStateProperty.all(const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600))),
                    onPressed: submit,
                    child: const Text(
                      "Add",
                      style: TextStyle(color: Colors.white),
                    )))
          ],
        ),
      ),
    );
  }
}

// Function to show SnackBar with animation
void showAnimatedSnackBar(BuildContext context, msg) {
  final snackBar = SnackBar(
    content: Text(msg),
    duration: const Duration(milliseconds: 1000),
    backgroundColor: Colors.green,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(5),
  );
  // Show SnackBar with custom animation
  ScaffoldMessenger.of(context).showSnackBar(
    snackBar,
  );
}
