import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stayease/hive_db_blog/hive_box_helper.dart';
import 'package:stayease/hive_db_blog/hive_models/cat_model.dart';

class HiveServiceProvider extends ChangeNotifier {
  List<CatModel> catModelList = [];
  List<CatModel> filteredItems = [];
  CatModel? _deletedCat;
  final TextEditingController searchController = TextEditingController();
  bool isToggled = false;
  bool isLoading = false;



  void toggle() {
    isToggled = !isToggled;
    searchController.clear();
    // getCats();
    notifyListeners();
  }

  void addCat(CatModel catModel) async {
    Box<CatModel> catBox = await HiveBoxHelperClass.openCatBox();
    await catBox.put(catModel.name, catModel);
    print(catModelList);
    notifyListeners();
  }

  void getCats() async {
    isLoading = true;
    Box<CatModel> catBox = await HiveBoxHelperClass.openCatBox();
    CatModel? catModel = catBox.get('foo');
    catModelList = catBox.values.toList();
    filteredItems= catBox.values.toList();
    print(catModelList);
    notifyListeners();
    isLoading = false;
  }

  void deleteCat(CatModel catModel) async {
    Box<CatModel> catBox = await HiveBoxHelperClass.openCatBox();
    _deletedCat=catModel;
    await catBox.delete(catModel.name);
    notifyListeners();
  }

  void restoreDeletedCat() async {
    if (_deletedCat != null) {
      Box<CatModel> catBox = await HiveBoxHelperClass.openCatBox();
      await catBox.put(_deletedCat!.name, _deletedCat!);
      notifyListeners();
    }
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      // Filter the results based on the query
      List<CatModel> filteredResults = catModelList.where((cat) {
        return cat.name.toLowerCase().contains(query.toLowerCase());
      }).toList();

      // Update the filtered list and notify listeners
      filteredItems = filteredResults;
    } else {
      // If query is empty, reset the filtered list to the original list
      filteredItems = List.from(catModelList);
    }

    notifyListeners();
  }
}
