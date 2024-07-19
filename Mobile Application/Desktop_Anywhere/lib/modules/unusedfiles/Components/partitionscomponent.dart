// import 'package:flutter/material.dart';
//
// class PartitionComponent extends StatefulWidget {
//   final String partitonName;
//
//   const PartitionComponent({
//     Key? key,
//     required this.partitonName,
//   }) : super(key: key);
//
//   @override
//   State<PartitionComponent> createState() => _PartitionComponentState();
// }
//
// class _PartitionComponentState extends State<PartitionComponent> {
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
//           Stack(
//             alignment: AlignmentDirectional.topStart,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 2,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.account_tree_outlined,
//                             color: Colors.white, size: 35),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             widget.partitonName,
//                             style: const TextStyle(
//                               fontSize: 25,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
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
