import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/services/change_screen.dart';
import 'package:evidyalaya/core/widgets/user_avatar.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/auth/screens/login.dart';
import 'package:evidyalaya/features/auth/screens/side_drawer/about_us.dart';
import 'package:evidyalaya/features/auth/screens/side_drawer/contact_us.dart';
import 'package:evidyalaya/features/auth/screens/side_drawer/privacy_policy.dart';
import 'package:evidyalaya/features/auth/screens/side_drawer/terms_and_conditions.dart';
import 'package:evidyalaya/features/auth/screens/side_drawer/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SideDrawer extends StatelessWidget {

  const SideDrawer({super.key});

  void _open({
    required BuildContext context,
    required int index,
  }) {

    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.isDrawerOpen ?? false) {
      scaffold!.closeDrawer();
    }

    switch (index) {
      case 0:
        changeScreen(
          context: context,
          screen: const UserProfile(),
        );
      case 1:
        changeScreen(
          context: context,
          screen: const AboutUs(),
        );
      case 2:
        changeScreen(
          context: context,
          screen: const ContactUs(),
        );
      case 3:
        changeScreen(
          context: context,
          screen: const PrivacyPolicy(),
        );
      case 4:
        changeScreen(
          context: context,
          screen: const TermsAndConditions(),
        );
      case 5:
        context.read<AuthCubit>().logout();
        changeScreenReplacement(
          context: context,
          screen: const Login(),
        );
    }

  }

  @override
  Widget build(BuildContext context) {

    final UserModel user = context.read<AuthCubit>().userModel!;
    final text = Theme.of(context).textTheme;

    return NavigationDrawer(
      selectedIndex: null,
      onDestinationSelected: (index) => _open(
        context: context,
        index: index,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            28,
            24,
            16,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                name: user.name,
                url: user.profilePicture,
                radius: 40,
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: text.titleMedium,
              ),
              Text(
                user.designation,
                style: text.bodyMedium,
              ),
              Text(
                user.phone,
                style: text.bodySmall,
              ),
              Text(
                user.email,
                style: text.bodySmall,
              ),
            ],
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people_outline),
          label: Text('Profile'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.info_outline),
          label: Text('About Us'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.contact_mail_outlined),
          label: Text('Contact Us'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.security_outlined),
          label: Text('Privacy'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.policy_outlined),
          label: Text('Terms'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(
            28,
            8,
            28,
            8,
          ),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.logout),
          label: Text('Logout'),
        ),
      ],
    );

  }

}
