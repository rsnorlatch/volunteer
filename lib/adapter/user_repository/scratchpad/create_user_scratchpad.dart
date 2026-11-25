import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volunteer/adapter/user_repository/supabase_user_repository.dart';
import 'package:volunteer/entities/authentication_user.dart';

class CreateUserScratchpad extends StatefulWidget {
  const CreateUserScratchpad({super.key});

  @override
  State<CreateUserScratchpad> createState() => _CreateUserScratchpadState();
}

class _CreateUserScratchpadState extends State<CreateUserScratchpad> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
