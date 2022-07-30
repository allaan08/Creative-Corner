import 'package:creative_corner/screens/add_post_screen.dart';
import 'package:creative_corner/screens/feed_screen.dart';
import 'package:creative_corner/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const webScreenSize = 600;
List<Widget> homeScreenItems = [
  const FeedScreen(),
  const AddPostScreen(),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
];
