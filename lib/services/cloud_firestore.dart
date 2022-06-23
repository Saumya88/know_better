import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/auth_services.dart';

class FirestoreDatabase {
  // final String uid;

  // FirebaseDatabase({required this.uid});

  final CollectionReference userDataCollection =
      FirebaseFirestore.instance.collection('Users');
  final CollectionReference roomDataCollection =
      FirebaseFirestore.instance.collection('Rooms');
//   final CollectionReference CustomerCollection =
//       FirebaseFirestore.instance.collection('Customers');
//   final CollectionReference ClientCollection =
//       FirebaseFirestore.instance.collection('Clients');
//   final CollectionReference supportInfoCollection =
//       FirebaseFirestore.instance.collection('Support Details');
//   final CollectionReference collection =
//       FirebaseFirestore.instance.collection('User Data');
//   final CollectionReference invoiceCollection =
//       FirebaseFirestore.instance.collection('Invoices');

  Future createUser(UserData userData) {
    return userDataCollection.doc(userData.id).set(userData.toJson());
    // add(userData.toJson());
  }

  Future<DocumentSnapshot> getUser() async {
    final uid = await AuthServices().getCurrentUID();
    // print(uid);
    return userDataCollection.doc(uid).get();
  }
//   Future createInvoice(Invoice invoice) async {
//     return invoiceCollection.add(invoice.toJson());
//   }

//   Future updateInvoice(Invoice invoice, String docId) async {
//     return invoiceCollection.add(invoice.toJson());
//   }

//   Future deleteInvoice(String docId) async {
//     return invoiceCollection.doc(docId).delete();
//   }

//   Future setUserData(UserDB userData) async {
//     return userDataCollection.doc(uid).set({
//       'Name': userData.fullName,
//       'Email': userData.email,
//       'Address': userData.address,
//       'Account Holder Name': userData.accountHolderName,
//       'Account Number': userData.accountNumber,
//       'Bank IFSC Code': userData.bankIFSCCode,
//     });
//   }

//   Future setCustomerData(Customer customer) async {
//     return await CustomerCollection.doc(uid).set({
//       'Name': customer.fullName,
//       'Email': customer.email,
//       'Address': customer.address,
//       'Account Holder Name': customer.accountHolderName,
//       'Account Number': customer.accountNumber,
//       'Bank IFSC Code': customer.bankIFSCCode,
//       'AdminUID': customer.adminUID
//     });
//   }

//   Future addSupportQueries(SupportQueries supportQueries) {
//     return supportInfoCollection.add({
//       'uid': supportQueries.uid,
//       'subject': supportQueries.subject,
//       'topic': supportQueries.topic,
//       'message': supportQueries.message,
//       'screenshotUrl': supportQueries.screenshotUrl
//     });
//   }

//   Future<void> updateData(String collection, String field, String value) {
//     return FirebaseFirestore.instance
//         .collection(collection)
//         .doc(uid)
//         .update({field: value})
//         .then((value) => print("User Updated"))
//         .catchError((error) => print("Failed to update user: $error"));
//   }

}
