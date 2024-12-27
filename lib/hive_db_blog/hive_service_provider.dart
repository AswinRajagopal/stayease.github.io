import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  Set<Marker> markers = {};
  String cityName = '';
  String stateName = '';
  GoogleMapController? mapController;
  LatLng currentPosition = LatLng(37.7749, -122.4194);



  void toggle() {
    isToggled = !isToggled;
    searchController.clear();
    getCats();
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
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // setState(() {
          cityName = place.locality ?? 'Unknown City';
          stateName = place.administrativeArea ?? 'Unknown State';
          print(cityName);
          print(stateName);
        // });
      }
      // setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        print('lat:${currentPosition.latitude}');
        print('long:${currentPosition.longitude}');
        // Add a marker at the current position
        markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: currentPosition,
            infoWindow: InfoWindow(title: 'You are here'),
          ),
        );
      // });

      // Move the camera to the current position
      mapController?.animateCamera(CameraUpdate.newLatLng(currentPosition));
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }


}
