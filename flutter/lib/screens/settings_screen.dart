// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import 'auth_screen.dart';
import './privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 다크모드 스위치
          SwitchListTile(
            title: Text('다크 모드'),
            subtitle: Text('어두운 테마를 사용합니다'),
            secondary: Icon(Icons.dark_mode),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),

          Divider(),

          // 개인정보 보호 정책
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('개인정보 보호 정책'),
            subtitle: Text('개인정보 처리 방침을 확인하세요'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          Divider(),

          // 로그아웃
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('로그아웃'),
            onTap: () async {
              // 로그아웃 확인 다이얼로그 추가
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: colorScheme.surface,
                  title: Text('로그아웃', style: TextStyle(color: colorScheme.onSurface)),
                  content: Text(
                    '정말 로그아웃 하시겠습니까?',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('취소', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('로그아웃', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await userProvider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),

          Divider(),

          // 계정 삭제 (빨간색 유지)
          ListTile(
            leading: Icon(Icons.delete_forever, color: colorScheme.error),
            title: Text('계정 삭제', style: TextStyle(color: colorScheme.error)),
            subtitle: Text(
              '계정을 영구적으로 삭제합니다',
              style: TextStyle(
                color: colorScheme.error.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            onTap: () async {
              // 확인 다이얼로그 표시
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) {
                  final dialogColorScheme = Theme.of(context).colorScheme;
                  return AlertDialog(
                    backgroundColor: dialogColorScheme.surface,
                    title: Text(
                      '계정 삭제',
                      style: TextStyle(color: dialogColorScheme.onSurface),
                    ),
                    content: Text(
                      '정말 계정을 삭제하시겠습니까?\n모든 데이터가 영구적으로 삭제됩니다.',
                      style: TextStyle(color: dialogColorScheme.onSurface),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('아니요'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: dialogColorScheme.error,
                        ),
                        child: Text('예'),
                      ),
                    ],
                  );
                },
              );

              // 사용자가 '예'를 누른 경우에만 삭제 처리
              if (shouldDelete == true) {
                final success = await userProvider.deleteAccount();
                if (context.mounted) {
                  if (success) {
                    // 삭제 성공 시 로그인 화면으로 이동
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  } else {
                    // 삭제 실패 시 에러 메시지 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('계정 삭제에 실패했습니다. 다시 시도해주세요.'),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                }
              }
            },
          ),

          SizedBox(height: 20),

          // 앱 정보
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  'Pludy',
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: colorScheme.secondary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
