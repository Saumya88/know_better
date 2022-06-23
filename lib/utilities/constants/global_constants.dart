// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

const Color kGreenButtonColor = Color.fromRGBO(68, 204, 136, 1);
const Color kPurpleColor = Color(0xFF7816F7);
const GOOGLE_API_KEY = 'AIzaSyCmpU3BAtUjNSNf3kn3ElEMhZgMcXQJkFE';

List<Color?> colorPallette = [
  Colors.red,
  Colors.pinkAccent,
  Colors.yellowAccent,
  Colors.purple,
  Colors.green[900],
  Colors.greenAccent,
  const Color.fromRGBO(68, 204, 136, 1),
];

enum RoomType { Virtual, Physical }

enum ActivityType { Criticality, TeamBuildUp, CommunicationMatrix }

enum Gender { Male, Female, Other }

enum Criticality { HaevilyImpacted, SomeImpact, NoImpact, RemovesFriction }

enum TeamBuildUp { Negative, NotMatch, TeamMember, CoFounder }

enum CommunicationMatrix {
  Distraction,
  NotNeeded,
  Necessary,
  CriticallyDependant
}

final fixedSoftSkills = [
  'Comfortable with uncertainty',
  'Experimental',
  'Achiever',
  'Ambitious',
  'Determined',
  'Courageous',
  'Manages Conflict',
  'Manages underperformance',
  'Improves Processes',
  'Manages Ideas',
  'Problem Solver',
  'detail-orientated',
  'Adaptable',
  'Self-Aware',
  'Detail-orientated',
  'Manages Time',
  'Plans Work',
  'Balances personal life and work',
  'Manages Negotiations',
  'Modest',
  'Patient',
  'Approachable',
  'Empathetic',
  'Listens well',
  'Collaborative',
  'Ethical',
  'Recognizes Talent and Potential',
  'Knowledgeable & Market Aware',
  'Develops Self',
  'Technically Competent',
  'Customer-centric',
  'Trustworthy',
  'Creative',
  'Open Minded',
  'Focused on Priorities',
  'Conceptual',
  'Global Thinker',
  'Strategic',
  'Confident',
  'Diplomatic',
  'Composed',
  'Politically Astute',
  'Demonstrates good judgment',
  'Fair',
  'Takes Accountability',
  'Decisive',
  'Directs People',
  'Empowers People',
  'Monitors Work',
  'Develops People',
  'Inspires a Future',
  'Motivates People',
  'Unifies People',
  'Takes Initiative',
  'Networked',
  'Open',
  'Responds well to authority',
  'Communicates well (Verbal)',
  'Communicates well (Written)',
  'Informs Others',
];
