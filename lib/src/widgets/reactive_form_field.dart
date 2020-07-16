// Copyright 2020 Joan Pablo Jiménez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Signature for building the widget representing the form field.
///
/// Used by [FormField.builder].
typedef ReactiveFormFieldBuilder<T> = Widget Function(
    ReactiveFormFieldState<T> field);

class ReactiveFormField<T> extends StatefulWidget {
  /// Function that returns the widget representing this form field. It is
  /// passed the form field state as input, containing the current value and
  /// validation state of this field.
  final ReactiveFormFieldBuilder<T> _builder;
  final String formControlName;
  final Map<String, String> validationMessages;

  const ReactiveFormField({
    Key key,
    @required this.formControlName,
    @required ReactiveFormFieldBuilder<T> builder,
    Map<String, String> validationMessages,
  })  : assert(formControlName != null),
        assert(builder != null),
        _builder = builder,
        validationMessages = validationMessages ?? const {},
        super(key: key);

  @override
  ReactiveFormFieldState<T> createState() => ReactiveFormFieldState<T>();
}

class ReactiveFormFieldState<T> extends State<ReactiveFormField<T>> {
  FormControl control;

  /// The current value of the [FormControl].
  T get value => this.control.value;

  String get errorText {
    if (this.control.invalid && this.control.touched) {
      return widget.validationMessages
              .containsKey(this.control.errors.keys.first)
          ? widget.validationMessages[this.control.errors.keys.first]
          : this.control.errors.keys.first;
    }

    return null;
  }

  @override
  void initState() {
    this.control = _getFormControl();
    this.subscribeFormControl();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final newControl = _getFormControl();
    if (this.control != newControl) {
      this.unsubscribeFormControl();
      this.control = newControl;
      subscribeFormControl();
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this.unsubscribeFormControl();
    super.dispose();
  }

  @protected
  void subscribeFormControl() {
    this.control.onStatusChanged.addListener(_onFormControlStatusChanged);
    this.control.onValueChanged.addListener(_onFormControlValueChanged);
  }

  @protected
  void unsubscribeFormControl() {
    this.control.onStatusChanged.removeListener(_onFormControlStatusChanged);
    this.control.onValueChanged.removeListener(_onFormControlValueChanged);
  }

  FormControl _getFormControl() {
    final form =
        ReactiveForm.of(context, listen: false) as FormControlCollection;
    if (form == null) {
      throw FormControlParentNotFoundException(widget);
    }

    return form.formControl(widget.formControlName);
  }

  void _onFormControlValueChanged() {
    this.updateValueFromControl();
  }

  @protected
  void updateValueFromControl() {
    this.touch();
  }

  void _onFormControlStatusChanged() {
    setState(() {});
  }

  void didChange(T value) {
    this.control.value = value;
    if (this.control.touched) {
      setState(() {});
    }
  }

  void touch() {
    setState(() {
      this.control.touched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget._builder(this);
  }
}
