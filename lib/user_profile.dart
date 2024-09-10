// import 'package:flutter/material.dart';

// class UserProfileScreen extends StatelessWidget {
//   final String userId;
//   final String userName;
//   final String email;

//   const UserProfileScreen({
//     required this.userId,
//     required this.userName,
//     required this.email,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$userName\'s Profile'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'User ID:',
//               style: Theme.of(context).textTheme.subtitle1,
//             ),
//             Text(
//               userId,
//               style: Theme.of(context).textTheme.bodyText1,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Name:',
//               style: Theme.of(context).textTheme.subtitle1,
//             ),
//             Text(
//               userName,
//               style: Theme.of(context).textTheme.bodyText1,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Email:',
//               style: Theme.of(context).textTheme.subtitle1,
//             ),
//             Text(
//               email,
//               style: Theme.of(context).textTheme.bodyText1,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
