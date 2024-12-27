import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stayease/hive_db_blog/hive_service_provider.dart';
import 'package:stayease/hive_db_blog/widgets/build_alert_dialog.dart';
import 'package:stayease/notifications_channel.dart';
import 'package:stayease/theme_mode_manager.dart';

class HiveHomeScreen extends StatefulWidget {
  const HiveHomeScreen({super.key});

  @override
  State<HiveHomeScreen> createState() => _HiveHomeScreenState();
}

class _HiveHomeScreenState extends State<HiveHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  var provider;
  void showAddCatDialog() {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        context: context,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(opacity: a1.value, child: const AddCatAlert()),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return Container();
        });
  }

  @override
  void initState() {
    provider = Provider.of<HiveServiceProvider>(context, listen: false);
    provider.getCats();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    AwesomeNotifications().isNotificationAllowed().then(
          (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Allow Notifications'),
              content: Text('Our app would like to send you notifications'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Don\'t Allow',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: Text(
                    'Allow',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
    super.initState();

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showAnimatedSnackBar(BuildContext context, msg) {
    final snackBar = SnackBar(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      content: Text(msg),
      duration: const Duration(milliseconds: 2000),
      backgroundColor: Colors.green,
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(5),
      action: SnackBarAction(
          backgroundColor: Colors.white,
          label: 'Undo',
          textColor: Colors.deepPurpleAccent,
          onPressed: () {
            provider.restoreDeletedCat();
            provider.getCats();
            Timer(const Duration(milliseconds: 2000), createTenantNotification);
          }),
    );

    // Show SnackBar with custom animation
    ScaffoldMessenger.of(context).showSnackBar(
      snackBar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent.shade200,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image(
                    color: Colors.white,
                    image: const AssetImage('assets/images/home_icon.png'),
                    width: MediaQuery.sizeOf(context).width / 6.0,
                    height: 50,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    'StayEase',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                  onTap: () {
                    setState(() {});
                    provider.toggle();
                  },
                  child: !provider.isToggled
                      ? const Icon(
                          Icons.search,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.close,
                          color: Colors.white,
                        ))
            ],
          ),
          actions: [
            themeNotifier.themeMode == ThemeMode.light
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        themeNotifier.setTheme(ThemeMode.dark);
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.dark_mode,
                        color: Colors.black,
                      ),
                    ))
                : const SizedBox(),
            themeNotifier.themeMode == ThemeMode.dark
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        themeNotifier.setTheme(ThemeMode.light);
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.light_mode,
                        color: Colors.white,
                      ),
                    ))
                : const SizedBox()
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurpleAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          onPressed: showAddCatDialog,
          child: const Icon(
            Icons.person_add_alt_1,
            color: Colors.white,
          ),
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () async {
            provider.getCats();
          },
          child: Consumer<HiveServiceProvider>(
              builder: (context, HiveServiceProvider, widget) {
            if (HiveServiceProvider.catModelList.isEmpty) {
              return const Center(
                child: Text("No Tenants found"),
              );
            }
            return Column(children: [
              provider.isToggled
                  ? TextField(
                style: const TextStyle(
                  color: Colors.black, // Set the text color to black
                  fontSize: 16, // Optional: Set font size
                ),
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      controller: provider.searchController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search...',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        provider.filterSearchResults(value);
                      },
                    )
                  : const SizedBox(),
              Expanded(
                child: HiveServiceProvider.filteredItems.isNotEmpty
                    ? ListView.builder(
                        itemCount: HiveServiceProvider.filteredItems.length,
                        itemBuilder: (context, index) {
                          if (provider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          // Animation for the item
                          Animation<Offset> slideAnimation = Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeIn,
                          ));

                          // Start the animation
                          _animationController.forward();

                          return SlideTransition(
                            position: slideAnimation,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 10.0),
                              child: Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: ListTile(
                                  isThreeLine: true,
                                  leading: const Icon(
                                    Icons.person,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  title: Text(
                                    HiveServiceProvider
                                        .filteredItems[index].name
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Age ${HiveServiceProvider.filteredItems[index].age}\nGender:  ${HiveServiceProvider.filteredItems[index].isMale ? 'Male' : 'Female'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      provider.deleteCat(HiveServiceProvider
                                          .filteredItems[index]);
                                      provider.getCats();
                                      showAnimatedSnackBar(
                                          context, 'Tenant removed, Click to');
                                      removeTenantNotification();
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    :  Center(
                        child: GestureDetector(
                          onTap: (){
                            provider.getCats();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('No Data Found'),
                              Icon(Icons.refresh)
                            ],
                          ),
                        ),
                      ),
              ),
            ]);
          }),
        ));
  }
}
