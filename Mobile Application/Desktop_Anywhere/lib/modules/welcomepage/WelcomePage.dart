import 'package:desktop_anywhere/modules/homepage/HomePage.dart';
import 'package:desktop_anywhere/shared/cubit/cubit.dart';
import 'package:desktop_anywhere/shared/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';


class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});

  var formKey= GlobalKey<FormState>();
  var nameController = TextEditingController();
  double scaleFactor=0;

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    scaleFactor = screenWidth / 400;

    return BlocConsumer<AppCubit,States>(
        listener: (context,state){},
        builder: (context,state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            body: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Image(
                        image: AssetImage('assets/images/logo-no-background.png'),
                      ),
                    ),
                    cubit.deviceName.isEmpty? Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: Form(
                        key: formKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Welcome,  ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: min(20 * scaleFactor, 20),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                  controller: nameController,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: min(20 * scaleFactor, 20),
                                  ),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'First Name',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: min(20 * scaleFactor, 20),
                                    ),
                                  ),
                                  validator: (value) {
                                    if(value!.isEmpty)
                                    {
                                      return 'please enter name';
                                    }
                                    return null;
                                  }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) : const SizedBox(),
                  ],
                )
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: (nameController.text.isNotEmpty || cubit.deviceName.isNotEmpty)? cubit.startApp? FloatingActionButton(
              backgroundColor: Colors.black,
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () async {

                if (cubit.deviceName.isEmpty && formKey.currentState!.validate()){
                  await cubit.updateDeviceName(nameController.text);
                }

                if(cubit.deviceName.isNotEmpty){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }

              },
            ): const CircularProgressIndicator(
              color: Colors.white,
            ): const SizedBox(),
          );
        },
    );
  }
}
