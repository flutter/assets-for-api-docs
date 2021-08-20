@ECHO off
REM Copyright 2013 The Flutter Authors. All rights reserved.
REM Use of this source code is governed by a BSD-style license that can be
REM found in the LICENSE file.

REM ---------------------------------- NOTE ----------------------------------
REM
REM Please keep the logic in this file consistent with the logic in the
REM "sampler" script in the same directory to ensure that it continues to
REM work across platforms.
REM
REM --------------------------------------------------------------------------

SETLOCAL ENABLEDELAYEDEXPANSION

FOR %%i IN ("%~dp0..") DO SET REPO_DIR=%%~fi

cd "%REPO_DIR%/utils/sampler"
flutter pub upgrade
flutter run --release -d windows "%REPO_DIR%/utils/sampler/bin/sampler.dart" %* & exit /B !ERRORLEVEL!
