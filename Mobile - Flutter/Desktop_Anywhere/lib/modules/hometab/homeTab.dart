
import 'package:desktop_anywhere/shared/component/EmptyPage.dart';
import 'package:desktop_anywhere/shared/component/ErrorPage.dart';
import 'package:desktop_anywhere/shared/component/LoadingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/component/ActiveDevicesCard.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../contactus/ContactUs.dart';
import '../paringpage/ParingPage.dart';

class HomeTab extends StatelessWidget {
  HomeTab({super.key});

  getData() async {
    if(cubit!.laoding){
      print("loading.... \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
      await cubit?.autoConnection();
      // cubit?.laoding = false;
      // cubit?.stopLoading();
    }

    return [];
  }

  AppCubit? cubit;

  @override
  Widget build(BuildContext context) {

    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) {
              return BlocConsumer<AppCubit, States>(
                listener: (context, state) {},
                builder: (context, state) {
                  cubit = AppCubit.get(context);
                  var desktops = AppCubit.get(context).desktops;

                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      leading: const Icon(
                        Icons.desktop_windows_outlined,
                        size: 28,
                        color: Colors.white,
                      ),
                      leadingWidth: 58,
                      title: const Text(
                        'The Available Devices',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      centerTitle: true,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ContactUs()),
                              );
                            },
                            icon: const Icon(
                              Icons.info_outlined,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    body: FutureBuilder(
                        future: getData(),
                        builder: (context, snapshot) {
                          if(cubit!.laoding){
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return LoadingPage(
                                backgroundColor: Colors.white,
                                circleColor: Colors.black,
                              );
                            }
                            if (snapshot.hasError) {
                              return const ErrorPage();
                            }
                          }


                          return RefreshIndicator(
                            color: Colors.black,
                            onRefresh: () async{
                              print("onRefresh.... \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
                              // await cubit?.delay(sec: 2);
                              await cubit?.autoConnection();
                            },

                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: desktops.isEmpty? const EmptyPage() :
                                  ListView.builder(
                                    itemCount: desktops.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: ActiveDevicesCard(
                                          index: index,
                                          desktopData: desktops[index],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: FloatingActionButton(
                                      backgroundColor: Colors.white,
                                      child: const Icon(
                                        Icons.add_sharp,
                                        color: Colors.black,
                                        size: 35,
                                      ),
                                      onPressed: () {
                                        cubit?.updateSocketWaitingState();
                                        cubit?.updateInputData(ip: "", name: "", password: "");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ParingPage()),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  );
                },
              );
            });
      },
    );
  }
}
