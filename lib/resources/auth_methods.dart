import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creative_corner/models/user.dart' as model;
import 'package:creative_corner/resources/storage_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  //signup user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      if (!email.contains(RegExp("[a-zA-Z]+@+[a-zA-Z]+.ajce.in"))) {
        res = "You are not from AJCE";
        return res;
      }

      if (email.isNotEmpty ||
              password.isNotEmpty ||
              username.isNotEmpty ||
              bio.isNotEmpty
          //file != null
          ) {
        //registerr user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        //add user to DATABASE
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          photoUrl: photoUrl,
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());

        var snap =
            await _firestore.collection('users').doc(cred.user!.uid).get();

        // await _firestore.collection('users').add({
        // 'username': username,
        // 'uid': cred.user!.uid,
        // 'email': email,
        // 'bio': bio,
        // 'followers': [],
        // 'following': [],
        // })

        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted.';
      } else if (err.code == 'weak=password') {
        res = 'Password should be at least 6 characters.';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'Success';
      } else {
        res = 'Please enter all the fields';
      }
    }
    // for custom errors
    // on FirebaseAuthException catch(e) {
    //   if(e.code  == 'user-not-found') {

    //   }
    // }

    catch (err) {
      res = err.toString();
    }
    return res;
  }
}
