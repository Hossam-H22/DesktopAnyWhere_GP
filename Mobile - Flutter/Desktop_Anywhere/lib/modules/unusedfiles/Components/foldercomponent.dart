// import 'package:flutter/material.dart';
//
// class FolderComponent extends StatefulWidget {
//   final String folderName;
//
//   const FolderComponent({
//     Key? key,
//     required this.folderName,
//   }) : super(key: key);
//
//   @override
//   State<FolderComponent> createState() => _FolderComponentState();
// }
//
// class _FolderComponentState extends State<FolderComponent> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.black87,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 2,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.folder, color: Colors.white, size: 35),
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Text(
//                         widget.folderName,
//                         style: const TextStyle(
//                           fontSize: 25,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () {
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //     //builder: (context) => const ,
//                   //   ),
//                   //);
//                 },
//                 icon: const Icon(
//                   Icons.arrow_circle_right_outlined,
//                   size: 35,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
