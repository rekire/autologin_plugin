import 'package:flutter/material.dart';

class LoginFields extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final ValueChanged<String> onSubmit;

  const LoginFields({
    required this.usernameController,
    required this.passwordController,
    required this.onSubmit,
    super.key,
  });

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.usernameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
          onFieldSubmitted: widget.onSubmit,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.passwordController,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.send,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => obscurePassword = !obscurePassword);
              },
              tooltip: obscurePassword ? 'Show password' : 'Hide password',
            ),
          ),
          onFieldSubmitted: widget.onSubmit,
        ),
      ],
    );
  }
}
