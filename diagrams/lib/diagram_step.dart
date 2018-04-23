// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram/diagram.dart';

abstract class DiagramStep {
  DiagramStep(this.controller);

  final DiagramController controller;

  Future<List<File>> generateDiagrams();
}