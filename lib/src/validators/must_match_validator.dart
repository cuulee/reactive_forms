// Copyright 2020 Joan Pablo Jiménez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:reactive_forms/reactive_forms.dart';

class MustMatchValidator extends Validator {
  final String controlName;
  final String matchingControlName;

  MustMatchValidator(this.controlName, this.matchingControlName)
      : assert(controlName != null),
        assert(matchingControlName != null);

  Map<String, dynamic> validate(AbstractControl control) {
    final error = {ValidationMessage.mustMatch: true};

    final form = control as FormGroup;
    if (form == null) {
      return error;
    }

    final formControl = form.control(controlName);
    final matchingFormControl = form.control(matchingControlName);

    if (formControl.value != matchingFormControl.value) {
      matchingFormControl.setErrors(error);
      matchingFormControl.markAsTouched();
    } else {
      matchingFormControl.setErrors({});
    }

    return null;
  }
}
