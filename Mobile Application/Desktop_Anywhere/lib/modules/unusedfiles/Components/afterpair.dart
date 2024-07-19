// import 'package:flutter/material.dart';
//
// class AfterPair extends StatelessWidget {
//   const AfterPair(BuildContext context, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Center(
//         child: Text(
//           'Congratulations !',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
//         ),
//       ),
//       content: const Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             "You have Successfully paired to this device.",
//             style: TextStyle(fontWeight: FontWeight.w400, fontSize: 19),
//           ),
//         ],
//       ),
//       actions: [
//         MaterialButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: const Text(
//             'Close',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//               fontSize: 18,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
