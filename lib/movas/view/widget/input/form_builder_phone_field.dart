import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_form_builder/src/always_disabled_focus_node.dart';
import 'package:sms_verification/movas/view/page/sms_verification/user_phone_number.dart';

class CustomFormBuilderPhoneField extends StatefulWidget {
  final String attribute;
  final List<FormFieldValidator> validators;
  final String initialValue;
  final bool readOnly;
  final InputDecoration decoration;
  final ValueChanged onChanged;
  final ValueTransformer valueTransformer;

  final AutovalidateMode autovalidateMode;
  final int maxLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextStyle style;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final StrutStyle strutStyle;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final bool autofocus;
  final bool autocorrect;
  final bool maxLengthEnforced;
  final int maxLength;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onFieldSubmitted;
  final List<TextInputFormatter> inputFormatters;
  final bool enabled;
  final double cursorWidth;
  final Radius cursorRadius;
  final Color cursorColor;
  final Brightness keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final InputCounterWidgetBuilder buildCounter;
  final bool expands;
  final int minLines;
  final bool showCursor;
  final FormFieldSetter onSaved;
  final VoidCallback onTap;
  final Function(UserPhoneNumber) onCodeUpdated;
  final bool validateOnChange;

  // For country dialog
  final String searchText;
  final EdgeInsets titlePadding;
  final bool isSearchable;
  final Text dialogTitle;
  final String defaultSelectedCountryIsoCode;
  final List<String> priorityListByIsoCode;
  final List<String> countryFilterByIsoCode;
  final TextStyle dialogTextStyle;
  final bool isCupertinoPicker;
  final double cupertinoPickerSheetHeight;

  CustomFormBuilderPhoneField({
    Key key,
    @required this.attribute,
    this.initialValue,
    this.validators = const [],
    this.readOnly = false,
    this.decoration,
    this.autovalidateMode,
    this.maxLines,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enabled = true,
    this.enableInteractiveSelection = true,
    this.maxLengthEnforced = true,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.autocorrect = true,
    this.cursorWidth = 2.0,
    this.keyboardType = TextInputType.phone,
    this.style,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.strutStyle,
    this.textDirection,
    this.maxLength,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.buildCounter,
    this.onChanged,
    this.valueTransformer,
    this.expands = false,
    this.minLines,
    this.showCursor,
    this.onSaved,
    this.onTap,
    this.searchText,
    this.titlePadding,
    this.dialogTitle,
    this.isSearchable,
    this.defaultSelectedCountryIsoCode = 'US',
    this.priorityListByIsoCode,
    this.countryFilterByIsoCode,
    this.dialogTextStyle,
    this.isCupertinoPicker = false,
    this.cupertinoPickerSheetHeight,
    this.onCodeUpdated,
    this.validateOnChange,
  })  : assert(initialValue == null ||
            controller == null ||
            defaultSelectedCountryIsoCode != null),
        super(key: key);

  @override
  CustomFormBuilderPhoneFieldState createState() =>
      CustomFormBuilderPhoneFieldState();
}

class CustomFormBuilderPhoneFieldState
    extends State<CustomFormBuilderPhoneField> {
  bool _readOnly = false;
  TextEditingController _effectiveController;
  FormBuilderState _formState;
  final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();
  String _initialValue;
  Country _selectedDialogCountry;
  bool phoneNumberValid = true;

  var effectiveDecoration = InputDecoration(
      errorText: null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.5), width: 2)),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.5), width: 2)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.5), width: 2)),
      labelStyle: TextStyle(color: Colors.grey),
      hintStyle: TextStyle(color: Colors.grey),
      labelText: "Phone number",
      hintText: "Enter phone number");

  String get fullNumber {
    final phoneText = _effectiveController.text;
    return phoneText.isNotEmpty
        ? '+${_selectedDialogCountry.phoneCode}$phoneText'
        : phoneText;
  }

  UserPhoneNumber get userPhoneNumber {
    return UserPhoneNumber(
        fullPhoneNumber: fullNumber,
        normalizedPhoneNumber: _effectiveController.text,
        countryAreaCode: _selectedDialogCountry.phoneCode,
        countryIsoCode: _selectedDialogCountry.isoCode);
  }

  _updateSelectedDialogCountry(String isoCode) {
    setState(() {
      _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode(isoCode);
    });
  }

  updateNumber(UserPhoneNumber phoneNumber) {
    _effectiveController.text = phoneNumber.normalizedPhoneNumber;
    _updateSelectedDialogCountry(phoneNumber.countryIsoCode);
  }

  @override
  void initState() {
    super.initState();
    _formState = FormBuilder.of(context);
    _formState?.registerFieldKey(widget.attribute, _fieldKey);
    _initialValue = widget.initialValue ??
        ((_formState?.initialValue?.containsKey(widget.attribute) ?? false)
            ? _formState.initialValue[widget.attribute]
            : null);
    _effectiveController = widget.controller ?? TextEditingController();
    _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode(
        widget.defaultSelectedCountryIsoCode);
    // _validatePhoneNumber(_initialValue, setVal: true);
  }

  void _invokeChange(FormFieldState field) {
    // _validatePhoneNumber(fullNumber);
    if (_effectiveController.text.contains(new RegExp(r'[A-Za-z]'))) {
      _effectiveController.clear();
    }
    field.didChange(fullNumber);
    widget.onChanged?.call(fullNumber);

    if (widget.validateOnChange) {
      validatePhoneNumber(fullNumber).then((value) => setState(() {
            phoneNumberValid = value;
          }));
    }

    if (widget.onCodeUpdated != null)
      widget.onCodeUpdated(UserPhoneNumber(
          fullPhoneNumber: fullNumber,
          normalizedPhoneNumber: _effectiveController.text,
          countryAreaCode: _selectedDialogCountry.phoneCode,
          countryIsoCode: _selectedDialogCountry.isoCode));
  }

  @override
  Widget build(BuildContext context) {
    _readOnly = _formState?.readOnly == true || widget.readOnly;

    return FormField(
      key: _fieldKey,
      initialValue: _initialValue,
      autovalidateMode: widget.autovalidateMode,
      validator: (val) =>
          FormBuilderValidators.validateValidators(val, widget.validators),
      onSaved: (val) {
        var transformed;
        if (widget.valueTransformer != null) {
          transformed = widget.valueTransformer(val);
          _formState?.setAttributeValue(widget.attribute, transformed);
        } else {
          _formState?.setAttributeValue(widget.attribute, val);
        }
        widget.onSaved?.call(transformed ?? val);
      },
      builder: (FormFieldState field) {
        return TextField(
          enabled: !_readOnly,
          style: widget.style,
          focusNode: _readOnly ? AlwaysDisabledFocusNode() : widget.focusNode,
          decoration: widget.decoration != null
              ? widget.decoration.copyWith(
                  enabled: !_readOnly,
                  errorText: phoneNumberValid
                      ? null
                      : "Invalid number",
                  prefix: _textFieldPrefix(field),
                  // prefixIcon: widget.decoration.prefixIcon == null ? _textFieldPrefix(field) : widget.decoration.prefixIcon,
                  // prefix: widget.decoration.prefixIcon != null ? _textFieldPrefix(field) : null,
                )
              : effectiveDecoration.copyWith(
                  enabled: !_readOnly,
                  errorText: phoneNumberValid
                      ? null
                      : "Invalid number",
                  prefix: _textFieldPrefix(field)),
          // initialValue: "${_initialValue ?? ''}",
          onChanged: (val) {
            _invokeChange(field);
          },
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          onEditingComplete: widget.onEditingComplete,
          controller: _effectiveController,
          autocorrect: widget.autocorrect,
          autofocus: widget.autofocus,
          buildCounter: widget.buildCounter,
          cursorColor: widget.cursorColor,
          cursorRadius: widget.cursorRadius,
          cursorWidth: widget.cursorWidth,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          keyboardAppearance: widget.keyboardAppearance,
          maxLengthEnforced: widget.maxLengthEnforced,
          scrollPadding: widget.scrollPadding,
          textAlign: widget.textAlign,
          textCapitalization: widget.textCapitalization,
          textDirection: widget.textDirection,
          textInputAction: widget.textInputAction,
          strutStyle: widget.strutStyle,
          readOnly: _readOnly,
          expands: widget.expands,
          minLines: widget.minLines,
          showCursor: widget.showCursor,
          onTap: widget.onTap,
        );
      },
    );
  }

  Widget _textFieldPrefix(field) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (widget.isCupertinoPicker) {
          _openCupertinoCountryPicker(field);
        } else {
          _openCountryPickerDialog(field);
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 120,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Icon(Icons.arrow_drop_down),
            CountryPickerUtils.getDefaultFlagImage(_selectedDialogCountry),
            Text(
              '+${_selectedDialogCountry.phoneCode} ',
              style: widget.style ?? Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ),
    );
  }

  void _openCupertinoCountryPicker(FormFieldState field) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CountryPickerCupertino(
          pickerSheetHeight: widget.cupertinoPickerSheetHeight ?? 300.0,
          onValuePicked: (Country country) {
            setState(() => _selectedDialogCountry = country);
            field.didChange(fullNumber);
          },
          itemFilter: widget.countryFilterByIsoCode != null
              ? (c) => widget.countryFilterByIsoCode.contains(c.isoCode)
              : null,
          priorityList: widget.priorityListByIsoCode != null
              ? List.generate(
                  widget.priorityListByIsoCode.length,
                  (index) {
                    return CountryPickerUtils.getCountryByIsoCode(
                        widget.priorityListByIsoCode[index]);
                  },
                )
              : null,
        );
      },
    );
  }

  void _openCountryPickerDialog(FormFieldState field) {
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            cursorColor: widget.cursorColor,
            primaryColor: widget.cursorColor ?? Theme.of(context).primaryColor,
          ),
          child: CountryPickerDialog(
            titlePadding: widget.titlePadding ?? const EdgeInsets.all(8.0),
            searchCursorColor:
                widget.cursorColor ?? Theme.of(context).primaryColor,
            searchInputDecoration:
                InputDecoration(hintText: widget.searchText ?? 'Search...'),
            isSearchable: widget.isSearchable ?? true,
            title: widget.dialogTitle ??
                Text(
                  'Select phone country code',
                  style: widget.dialogTextStyle ?? widget.style,
                ),
            onValuePicked: (Country country) {
              setState(() => _selectedDialogCountry = country);
              _invokeChange(field);
              widget.focusNode?.requestFocus();
            },
            itemFilter: widget.countryFilterByIsoCode != null
                ? (c) => widget.countryFilterByIsoCode.contains(c.isoCode)
                : null,
            priorityList: widget.priorityListByIsoCode != null
                ? List.generate(
                    widget.priorityListByIsoCode.length,
                    (index) {
                      return CountryPickerUtils.getCountryByIsoCode(
                          widget.priorityListByIsoCode[index]);
                    },
                  )
                : null,
            itemBuilder: _buildDialogItem,
          ),
        );
      },
    );
  }

  Widget _buildDialogItem(Country country) {
    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CountryPickerUtils.getDefaultFlagImage(country),
        title: Text(country.name),
        // visualDensity: VisualDensity.compact, //TODO: Re-enable after Flutter 1.17
        trailing: Text('+${country.phoneCode}'),
      ),
    );
  }

  @override
  void dispose() {
    _formState?.unregisterFieldKey(widget.attribute);
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }
}
