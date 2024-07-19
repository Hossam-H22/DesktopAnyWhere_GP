import 'package:desktop_anywhere/shared/cubit/cubit.dart';
import 'package:desktop_anywhere/shared/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class Keyboard extends StatelessWidget {
  final String ip;

  const Keyboard({
    super.key,
    required this.ip
  });


  @override
  Widget build(BuildContext context) {
    AppCubit cubit = AppCubit.get(context);

    Widget _buildButton(String text, {VoidCallback? onPressed}) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60.0),
            color: Colors.grey[200],
          ),
          child: TextButton(
            onPressed: onPressed ?? () {
              if (!cubit.isArabic) {
                cubit.emitSocketEvent(
                    ip: ip,
                    event: "keyboard",
                    msg: text,
                    skipWaiting: true,
                );
              }
              else {
                cubit.emitSocketEvent(
                  ip: ip,
                  event: "keyboard",
                  msg: (cubit.isUppercase && cubit.isArabic)?text.toUpperCase():text.toLowerCase(),
                  skipWaiting: true,
                );
              }
            },
            child: Text(
              cubit.isUppercase ? text.toUpperCase() : text.toLowerCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    Widget spaceButton(){
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60.0),
            color: Colors.grey[200],
          ),
          child: TextButton(
            onPressed: () {
              // cubit.sendMessageKeyboard(' ', ip, 8888);
              cubit.emitSocketEvent(
                  ip: ip,
                  event: "keyboard",
                  msg: ' ',
                skipWaiting: true,
              );
            },
            child: const Icon(
              Icons.space_bar,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    Widget removeButton(){
      return Container(
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60.0),
          color: Colors.grey[200],
        ),
        child: TextButton(
          onPressed: (){
            // cubit.sendMessageKeyboard('backspace', ip, 8888);
            cubit.emitSocketEvent(
                ip: ip,
                event: "keyboard",
                msg: 'backspace',
              skipWaiting: true,
            );
          },
          child: const Icon(
            Icons.dangerous,
            color: Colors.black,
          ),
        ),
      );
    }
    Widget newLineButton(){
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60.0),
          color: Colors.grey[200],
        ),
        child: TextButton(
          onPressed: () {
            // cubit.sendMessageKeyboard('\n', ip, 8888);
            cubit.emitSocketEvent(
                ip: ip,
                event: "keyboard",
                msg: '\n',
              skipWaiting: true,
            );
          },
          child: const Icon(
            Icons.keyboard_return,
            color: Colors.black,
          ),
        ),
      );
    }
    Widget enterButton(){
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60.0),
          color: Colors.grey[200],
        ),
        child: TextButton(
          onPressed: () {
            // cubit.sendMessageKeyboard('enter', ip, 8888);
            cubit.emitSocketEvent(
                ip: ip,
                event: "keyboard",
                msg: 'enter',
              skipWaiting: true,
            );
          },
          child: const Icon(
            Icons.done_outline_rounded,
            color: Colors.black,
          ),
        ),
      );
    }
    Widget dotButton(){
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60.0),
          color: Colors.grey[200],
        ),
        child: TextButton(
          onPressed: () {
            // cubit.sendMessageKeyboard('.', ip, 8888);
            cubit.emitSocketEvent(
                ip: ip,
                event: "keyboard",
                msg: '.',
              skipWaiting: true,
            );
          },
          child: const Text(
            '.',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),

          ),
        ),
      );
    }
    Widget languageButton(){
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60.0),
          color: Colors.grey[200],
        ),
        child: TextButton(
          onPressed: () {
            cubit.toggleArabic();
          },
          child: const Icon(
            Icons.language,
            color: Colors.black,
          ),
        ),
      );
    }
    Widget toggleButton({text, function}){
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60.0),
          color: Colors.grey[200],
        ),
        child: TextButton(
          onPressed: function,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }


    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, Object? state) {},
      builder: (BuildContext context, state) {
        return Column(
          children: [
            // Keyboard Section
            cubit.isNum && !cubit.isNum2? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('0'),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('@'),
                    _buildButton('#'),
                    _buildButton('\$'),
                    _buildButton('%'),
                    _buildButton('&'),
                    _buildButton('-'),
                    _buildButton('+'),
                    _buildButton('('),
                    _buildButton(')'),
                    _buildButton('='),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('*'),
                    _buildButton('"'),
                    _buildButton('\''),
                    _buildButton(':'),
                    _buildButton(';'),
                    _buildButton('!'),
                    _buildButton('?'),
                    removeButton(),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          toggleButton(
                              text: cubit.isArabic?'ABC':'اب',
                              function: (){cubit.toggleNum();}
                          ),
                          toggleButton(
                              text: '</>',
                              function: (){cubit.toggleNum2();}
                          ),
                          spaceButton(),
                          dotButton(),
                          enterButton(),
                          newLineButton(),
                        ],
                      ),
                    ),
                  ],
                ),

              ],
            ) :
            cubit.isNum2 && cubit.isNum ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _buildButton('<'),
                    _buildButton('>'),
                    _buildButton('{'),
                    _buildButton('}'),
                    _buildButton('|'),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('~'),
                    _buildButton('['),
                    _buildButton(']'),
                    _buildButton('/'),
                    _buildButton('\\'),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          toggleButton(
                              text: '123',
                              function: (){
                                cubit.isNum = true;
                                cubit.toggleNum2();
                              }
                          ),
                          spaceButton(),
                          dotButton(),
                          enterButton(),
                          newLineButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ) :
            cubit.isArabic?
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _buildButton('Q'),
                    _buildButton('W'),
                    _buildButton('E'),
                    _buildButton('R'),
                    _buildButton('T'),
                    _buildButton('Y'),
                    _buildButton('U'),
                    _buildButton('I'),
                    _buildButton('O'),
                    _buildButton('P'),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('A'),
                    _buildButton('S'),
                    _buildButton('D'),
                    _buildButton('F'),
                    _buildButton('G'),
                    _buildButton('H'),
                    _buildButton('J'),
                    _buildButton('K'),
                    _buildButton('L'),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60.0),
                        color: Colors.grey[200],
                      ),
                      child: TextButton(
                        onPressed: (){cubit.toggleUppercase();},
                        child: Icon(
                          cubit.isUppercase
                              ? Icons.keyboard_double_arrow_up_rounded
                              : Icons.keyboard_capslock,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _buildButton('Z'),
                    _buildButton('X'),
                    _buildButton('C'),
                    _buildButton('V'),
                    _buildButton('B'),
                    _buildButton('N'),
                    _buildButton('M'),
                    _buildButton(','),
                    removeButton(),
                  ],
                ),
                Row(
                  children: [
                    toggleButton(
                        text: '123',
                        function: (){cubit.toggleNum();}
                    ),
                    languageButton(),
                    spaceButton(),
                    enterButton(),
                    newLineButton(),
                  ],
                ),
              ],
            ) :
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _buildButton('ض'),
                    _buildButton('ص'),
                    _buildButton('ث'),
                    _buildButton('ق'),
                    _buildButton('ف'),
                    _buildButton('غ'),
                    _buildButton('ع'),
                    _buildButton('ه'),
                    _buildButton('خ'),
                    _buildButton('ح'),
                    _buildButton('ج'),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('ش'),
                    _buildButton('س'),
                    _buildButton('ي'),
                    _buildButton('ب'),
                    _buildButton('ل'),
                    _buildButton('ا'),
                    _buildButton('ت'),
                    _buildButton('ن'),
                    _buildButton('م'),
                    _buildButton('ك'),
                    _buildButton('ط'),

                  ],
                ),
                Row(
                  children: [
                    _buildButton('ذ'),
                    _buildButton('ء'),
                    _buildButton('ؤ'),
                    _buildButton('ر'),
                    _buildButton('ى'),
                    _buildButton('ة'),
                    _buildButton('و'),
                    _buildButton('ز'),
                    _buildButton('ظ'),
                    _buildButton('د'),
                    removeButton(),
                  ],
                ),
                Row(
                  children: [
                    toggleButton(
                        text: '123',
                        function: (){cubit.toggleNum();}
                    ),
                    languageButton(),
                    spaceButton(),
                    enterButton(),
                    newLineButton(),
                  ],
                )
              ],
            )
          ],
        );
      },
    );
  }
}