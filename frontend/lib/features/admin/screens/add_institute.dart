import 'package:evidyalaya/core/services/email_validator.dart';
import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/widgets/auth_header.dart';
import 'package:evidyalaya/core/widgets/primary_button.dart';
import 'package:evidyalaya/core/widgets/responsive_fields.dart';
import 'package:evidyalaya/features/admin/models/institute_model.dart';
import 'package:evidyalaya/features/admin/services/admin_service.dart';
import 'package:flutter/material.dart';

class AddInstitute extends StatefulWidget {

  const AddInstitute({super.key});

  @override
  State<AddInstitute> createState() => _AddInstituteState();

}

class _AddInstituteState extends State<AddInstitute> {

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _domain = TextEditingController();
  final _address = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();

  @override
  void dispose() {

    _name.dispose();
    _code.dispose();
    _domain.dispose();
    _address.dispose();
    _email.dispose();
    _mobile.dispose();
    super.dispose();

  }

  void _submit() {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    showProgressDialog(context: context);
    AdminService.addInstitute(
      context: context,
      instituteModel: InstituteModel(
        id: 0,
        code: _code.text.trim().toUpperCase(),
        name: _name.text.trim(),
        domain: _domain.text.trim().toLowerCase(),
        address: _address.text.trim(),
        mobile: _mobile.text.trim(),
        email: _email.text.trim(),
        logo: '',
      ),
    );

  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String text) check,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    bool last = false,
  }) {

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: last ? (_) => _submit() : null,
      validator: (value) => check((value ?? '').trim()),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter $label',
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Add Institute')),
      body: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ResponsiveFields(
                children: [
                  const AuthHeader(
                    title: 'Add Institute',
                    subtitle: 'Enter Details to Add Institute',
                  ),
                  _field(
                    controller: _name,
                    label: 'Name',
                    check: (text) {

                      if (text.isEmpty) {
                        return 'Please Enter Name';
                      }
                      if (text.length < 3) {
                        return 'Name Should be of 3 Character';
                      }
                      return null;

                    },
                  ),
                  _field(
                    controller: _code,
                    label: 'Code',
                    capitalization: TextCapitalization.characters,
                    check: (text) {

                      if (!RegExp(r'^[A-Za-z0-9]{2,30}$').hasMatch(text)) {
                        return '2-30 letters or digits';
                      }
                      return null;

                    },
                  ),
                  _field(
                    controller: _domain,
                    label: 'Domain',
                    check: (text) {

                      if (!RegExp(r'^[a-z0-9]{2,30}$')
                          .hasMatch(text.toLowerCase())) {
                        return '2-30 lowercase letters or digits';
                      }
                      return null;

                    },
                  ),
                  _field(
                    controller: _address,
                    label: 'Address',
                    check: (text) {

                      if (text.isEmpty) {
                        return 'Please Enter Address';
                      }
                      if (text.length < 5) {
                        return 'Address Should be of 5 Character';
                      }
                      return null;

                    },
                  ),
                  _field(
                    controller: _email,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    check: (text) {

                      if (text.isEmpty) {
                        return 'Please Enter A Email';
                      }
                      if (!EmailValidator.validate(email: text)) {
                        return 'Please Enter A Valid Email';
                      }
                      return null;

                    },
                  ),
                  _field(
                    controller: _mobile,
                    label: 'Mobile',
                    keyboardType: TextInputType.phone,
                    last: true,
                    check: (text) {

                      if (!RegExp(r'^[0-9+\- ]{6,15}$').hasMatch(text)) {
                        return 'Enter 6-15 digits';
                      }
                      return null;

                    },
                  ),
                                    PrimaryButton(
                    onPressed: _submit,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

}
