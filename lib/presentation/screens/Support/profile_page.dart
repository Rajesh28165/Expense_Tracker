// ignore_for_file: use_build_context_synchronously

import 'package:go_router/go_router.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/app_constants.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../router/route_name.dart';
import '../../../util/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  bool get _isEmailUser => FirebaseAuth.instance.currentUser
    ?.providerData
    .any((p) => p.providerId == 'password') ?? false;


  Widget _buildCardWrapper(
    BuildContext context, {
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: WidgetColors.surface,
        borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
        boxShadow: [
          BoxShadow(
            color: WidgetColors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final initials = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final isEmailUser = _isEmailUser;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.goTo(RouteName.login);
        }
      },
      child: Scaffold(
        backgroundColor: WidgetColors.page,
        appBar: context.customAppBar(title: 'Profile'),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            vertical: context.getPercentHeight(3.5),
            horizontal: context.getPercentWidth(4.5)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── User card ─────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.getPercentWidth(5)),
                decoration: BoxDecoration(
                  color: WidgetColors.darkCard,
                  borderRadius: BorderRadius.circular(context.getPercentWidth(6)),
                  boxShadow: [
                    BoxShadow(
                      color: WidgetColors.darkCard.withOpacity(0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar circle
                    Container(
                      width: context.getPercentWidth(14),
                      height: context.getPercentWidth(14),
                      decoration: BoxDecoration(
                        color: WidgetColors.indigo500.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WidgetColors.indigo400.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.sora(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: WidgetColors.indigo400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.getPercentWidth(4)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Account',
                            style: GoogleFonts.sora(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: WidgetColors.white.withOpacity(0.45),
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: context.getPercentHeight(0.5)),
                          Text(
                            email,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: WidgetColors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.getPercentHeight(3)),

              // ── Section title ─────────────────────────
              if (isEmailUser) ...[
                Text(
                  'Account Settings',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: WidgetColors.ink2,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: context.getPercentHeight(1.2)),

                // ── Settings card ─────────────────────────
                _buildCardWrapper(
                  context,
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.lock_outline_rounded,
                        iconColor: WidgetColors.indigo500,
                        iconBg: WidgetColors.indigoBg,
                        title: 'Change / Update Password',
                        subtitle: 'Update your login password',
                        showDivider: true,
                        onTap: () => context.pushTo(
                          RouteName.verifyPassword,
                          extra: {
                            'purpose': AppConstants.purposeUpdatePassword,
                            'count': 1,
                          }
                        )
                      ),
                      _buildSettingsTile(
                        context,
                        icon: Icons.shield_outlined,
                        iconColor: WidgetColors.green,
                        iconBg: WidgetColors.greenBg,
                        title: 'Change / Update Security Question',
                        subtitle: 'Manage your recovery question',
                        showDivider: false,
                        onTap: () => context.pushTo(
                          RouteName.verifySecurityQuestion,
                          extra: {
                            'purpose': AppConstants.purposeUpdateSecurityQA,
                            'count': 1,
                          }
                        )
                      )
                    ]
                  )
                )
              ],

              SizedBox(height: context.getPercentHeight(3)),

              _buildCardWrapper(
                context,
                child: _buildSettingsTile(
                  context,
                  icon: Icons.mail_outline_rounded,
                  iconColor: WidgetColors.indigo500,
                  iconBg: WidgetColors.indigoBg,
                  title: 'Support',
                  subtitle: 'Contact us via email',
                  showDivider: false,
                  onTap: () => context.pushTo(RouteName.support),
                ),
              ),

              SizedBox(height: context.getPercentHeight(3)),

              // ── Sign out card ─────────────────────────
              _buildCardWrapper(
                context,
                child: _buildSettingsTile(
                  context,
                  icon: Icons.logout_rounded,
                  iconColor: WidgetColors.red,
                  iconBg: WidgetColors.redBg,
                  title: 'Sign Out',
                  subtitle: 'Log out of your account',
                  showDivider: false,
                  titleColor: WidgetColors.red,
                  onTap: () => CommonMethods.showActionDialog(
                    context, 
                    purpose: 'Sign Out',
                    confirmationText: AppConstants.signOutConfirmation,
                    action: () async {
                      Navigator.of(context).pop();
                      await context.read<AuthCubit>().logout();
                      context.goTo(RouteName.login);
                    }
                  ),
                ),
              ),

              SizedBox(height: context.getPercentHeight(3)),

              _buildCardWrapper(
                context,
                child: _buildSettingsTile(
                  context,
                  icon: Icons.delete_outline_rounded,
                  iconColor: WidgetColors.red,
                  iconBg: WidgetColors.redBg,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  showDivider: false,
                  titleColor: WidgetColors.red,
                  onTap: () {
                    final user = FirebaseAuth.instance.currentUser;

                    final isGoogleUser = user?.providerData
                        .any((p) => p.providerId == 'google.com') ?? false;

                    CommonMethods.showActionDialog(
                      context,
                      confirmationText: AppConstants.deleteAccountConfirmation,
                      purpose: 'Delete',
                      action: () async {
                        context.pop();

                        if (isGoogleUser) {
                          context.showLoader(text: 'Deleting your account');
                          final result = await context.read<AuthCubit>().deleteAccount();
                          context.hideLoader(context);

                          if (result == null) {
                            await context.showCustomDialog(description: 'Account deleted successfully');
                            context.goTo(RouteName.login);
                          } else {
                            context.showCustomDialog(description: result);
                          }

                        } else {
                          context.pushTo(
                            RouteName.verifyPassword,
                            extra: {
                              'purpose': AppConstants.purposeDeleteAccount,
                              'count': 2,
                            }
                          );
                        }
                      },
                    );
                  }
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
    Color? titleColor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.getPercentWidth(5)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.getPercentWidth(4),
              vertical: context.getPercentHeight(1.8),
            ),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: context.getPercentWidth(11),
                  height: context.getPercentHeight(5),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(context.getPercentWidth(3)),
                  ),
                  child: Icon(
                    icon, 
                    color: iconColor,
                    size: context.getPercentWidth(5.5)
                  ),
                ),
                SizedBox(width: context.getPercentWidth(3.5)),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor ?? WidgetColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: WidgetColors.ink3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: WidgetColors.ink3,
                  size: context.getPercentWidth(5.5),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: context.getPercentWidth(18),
            endIndent: context.getPercentWidth(4),
            color: WidgetColors.page,
          ),
      ],
    );
  }
}