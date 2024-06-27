import 'package:desktop_anywhere/modules/desktopdata/DesktopData.dart';
import 'package:desktop_anywhere/shared/component/ActiveDevicesCard.dart';
import 'package:desktop_anywhere/modules/contactus/ContactUs.dart';
import 'package:desktop_anywhere/modules/paringpage/ParingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../hometab/homeTab.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, Object? state) {
        if (state is InsertDatabaseState) {
          // Navigator.pop(context);
        }
      },
      builder: (BuildContext context, state) {
        AppCubit cubit = AppCubit.get(context);

        var desktops = AppCubit.get(context).desktops;
        var active_desktops = AppCubit.get(context).active_desktops;

        return DefaultTabController(
          length: active_desktops.length,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.black,
              title: TabBar(
                indicatorColor: Colors.grey[800],
                tabs: [
                  for(var i=0; i<active_desktops.length; i++)
                    Tab(child: Text(active_desktops[i]['name']!),),
                ],
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                HomeTab(),
                for(var i=1; i<active_desktops.length; i++)
                  Tab(
                    child: DesktopData(
                      index: i,
                      ip: active_desktops[i]["ip"],
                      listofpartitions: active_desktops[i]["listofpartitions"],
                      contextTabs: context,
                    ),
                    // child: DesktopLayout(active_desktop_data: active_desktops[i],),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

