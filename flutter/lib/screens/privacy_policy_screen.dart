// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '개인정보 보호 정책',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated
            Text(
              '최종 업데이트: 2025년 5월 12일',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 32),

            // Introduction
            _buildSectionTitle('소개', colorScheme),
            SizedBox(height: 12),
            _buildParagraph(
              '퀴즈 앱("우리", "당사")은 귀하의 개인정보 보호를 중요하게 생각합니다. '
              '본 개인정보 보호 정책은 귀하가 당사의 모바일 애플리케이션(이하 "앱")을 사용할 때 '
              '당사가 수집, 사용, 공개 및 보호하는 정보에 대해 설명합니다.',
              colorScheme,
            ),
            SizedBox(height: 16),
            _buildParagraph(
              '본 개인정보 보호 정책을 주의 깊게 읽어주시기 바랍니다. 앱에 접근하거나 사용함으로써 '
              '귀하는 본 개인정보 보호 정책에 설명된 대로 귀하의 정보를 수집, 사용 및 공개하는 것에 '
              '동의하는 것으로 간주됩니다. 당사의 정책 및 관행에 동의하지 않으시면 앱을 사용하지 마십시오.',
              colorScheme,
            ),
            SizedBox(height: 32),

            // Information We Collect
            _buildSectionTitle('수집하는 정보', colorScheme),
            SizedBox(height: 12),
            _buildParagraph('당사는 앱 사용자로부터 다음과 같은 정보를 수집합니다:', colorScheme),
            SizedBox(height: 16),

            // Personal Information
            _buildBulletPoint(
              '계정 정보',
              '회원가입 시 이메일 주소, 사용자 이름(닉네임), 비밀번호를 수집합니다.',
              colorScheme,
            ),
            SizedBox(height: 12),

            // Quiz Data
            _buildBulletPoint(
              '퀴즈 데이터',
              '귀하가 생성한 퀴즈의 제목, 질문, 답변, 퀴즈 설정 등을 수집합니다. '
                  'AI 퀴즈 생성 기능을 사용할 경우, 입력한 주제 및 생성된 퀴즈 내용이 저장됩니다.',
              colorScheme,
            ),
            SizedBox(height: 12),

            // Usage Data
            _buildBulletPoint(
              '사용 데이터',
              '퀴즈 플레이 기록, 점수, 완료 시간, 앱 사용 패턴 등 앱과의 상호작용 정보를 자동으로 수집합니다.',
              colorScheme,
            ),
            SizedBox(height: 12),

            // Preferences
            _buildBulletPoint(
              '환경 설정',
              '다크 모드 설정 등 귀하의 앱 사용 환경 설정 정보를 저장합니다.',
              colorScheme,
            ),
            SizedBox(height: 32),

            // How We Use Your Information
            _buildSectionTitle('정보 사용 목적', colorScheme),
            SizedBox(height: 12),
            _buildParagraph('당사는 수집한 정보를 다음과 같은 목적으로 사용합니다:', colorScheme),
            SizedBox(height: 12),
            _buildSimpleBullet('앱의 제공, 운영 및 유지 관리', colorScheme),
            _buildSimpleBullet('사용자 계정 관리 및 인증', colorScheme),
            _buildSimpleBullet('퀴즈 생성, 저장 및 관리 기능 제공', colorScheme),
            _buildSimpleBullet('AI 퀴즈 생성 서비스 제공', colorScheme),
            _buildSimpleBullet('사용자 경험 개선 및 맞춤화', colorScheme),
            _buildSimpleBullet('앱 사용 분석 및 새로운 기능 개발', colorScheme),
            _buildSimpleBullet('고객 지원 및 문의 응답', colorScheme),
            SizedBox(height: 32),

            // AI Quiz Generation
            _buildSectionTitle('AI 퀴즈 생성 기능', colorScheme),
            SizedBox(height: 12),
            _buildParagraph('AI 퀴즈 생성 기능을 사용할 때:', colorScheme),
            SizedBox(height: 12),
            _buildSimpleBullet(
              '입력한 주제와 요구사항은 AI 모델에 전송되어 퀴즈를 생성합니다',
              colorScheme,
            ),
            _buildSimpleBullet(
              '생성된 퀴즈는 귀하의 계정에 저장되며, 언제든지 수정하거나 삭제할 수 있습니다',
              colorScheme,
            ),
            _buildSimpleBullet(
              'AI 생성 퀴즈의 품질 향상을 위해 익명화된 데이터를 사용할 수 있습니다',
              colorScheme,
            ),
            SizedBox(height: 32),

            // Data Storage
            _buildSectionTitle('데이터 저장 및 보안', colorScheme),
            SizedBox(height: 12),
            _buildParagraph(
              '당사는 귀하의 개인정보를 보호하기 위해 적절한 보안 조치를 취하고 있습니다:',
              colorScheme,
            ),
            SizedBox(height: 12),
            _buildSimpleBullet('모든 데이터는 안전한 서버에 암호화되어 저장됩니다', colorScheme),
            _buildSimpleBullet(
              '비밀번호는 해시 처리되어 저장되며, 직원도 확인할 수 없습니다',
              colorScheme,
            ),
            _buildSimpleBullet('정기적인 보안 점검을 실시합니다', colorScheme),
            SizedBox(height: 16),
            _buildParagraph(
              '다만, 인터넷을 통한 전송이나 전자 저장 방법은 100% 안전하지 않으므로 절대적인 보안을 보장할 수는 없습니다.',
              colorScheme,
            ),
            SizedBox(height: 32),

            // Data Sharing
            _buildSectionTitle('정보 공유 및 공개', colorScheme),
            SizedBox(height: 12),
            _buildParagraph(
              '당사는 귀하의 개인정보를 판매하지 않습니다. 다음의 경우에만 정보를 공유할 수 있습니다:',
              colorScheme,
            ),
            SizedBox(height: 12),
            _buildSimpleBullet('법률에 의해 요구되는 경우', colorScheme),
            _buildSimpleBullet('당사의 권리와 안전을 보호하기 위해 필요한 경우', colorScheme),
            _buildSimpleBullet('귀하의 동의를 받은 경우', colorScheme),
            _buildSimpleBullet(
              '앱 운영에 필요한 서비스 제공업체와의 공유 (단, 개인정보 보호 의무를 준수하는 경우에 한함)',
              colorScheme,
            ),
            SizedBox(height: 32),

            // Data Retention
            _buildSectionTitle('데이터 보관 기간', colorScheme),
            SizedBox(height: 12),
            _buildParagraph(
              '당사는 본 개인정보 보호 정책에 명시된 목적을 달성하는 데 필요한 기간 동안만 귀하의 개인정보를 보관합니다:',
              colorScheme,
            ),
            SizedBox(height: 12),
            _buildSimpleBullet('계정 정보: 계정 삭제 시까지', colorScheme),
            _buildSimpleBullet('퀴즈 데이터: 사용자가 삭제하거나 계정 삭제 시까지', colorScheme),
            _buildSimpleBullet('사용 기록: 최대 1년간 보관 후 자동 삭제', colorScheme),
            SizedBox(height: 16),
            _buildParagraph(
              '계정을 삭제하시면 30일 이내에 모든 개인정보가 완전히 삭제됩니다.',
              colorScheme,
            ),
            SizedBox(height: 32),

            // Your Rights
            _buildSectionTitle('귀하의 권리', colorScheme),
            SizedBox(height: 12),
            _buildParagraph('귀하는 다음과 같은 권리를 가지고 있습니다:', colorScheme),
            SizedBox(height: 12),
            _buildSimpleBullet(
              '개인정보 열람: 당사가 보유한 귀하의 정보를 확인할 수 있습니다',
              colorScheme,
            ),
            _buildSimpleBullet('개인정보 수정: 부정확한 정보를 수정할 수 있습니다', colorScheme),
            _buildSimpleBullet(
              '개인정보 삭제: 계정 삭제를 통해 모든 정보를 삭제할 수 있습니다',
              colorScheme,
            ),
            _buildSimpleBullet('데이터 이동: 귀하의 데이터를 다운로드할 수 있습니다', colorScheme),
            _buildSimpleBullet('처리 거부: 특정 데이터 처리에 반대할 수 있습니다', colorScheme),
            SizedBox(height: 16),
            _buildParagraph('이러한 권리를 행사하려면 아래 연락처로 문의해 주십시오.', colorScheme),
            SizedBox(height: 32),

            // Children's Privacy
            _buildSectionTitle('아동의 개인정보 보호', colorScheme),
            SizedBox(height: 12),
            _buildParagraph(
              '본 앱은 만 13세 미만의 아동을 대상으로 하지 않습니다. 당사는 만 13세 미만의 아동으로부터 '
              '의도적으로 개인정보를 수집하지 않습니다. 만 13세 미만의 아동이 개인정보를 제공한 것으로 '
              '판단되는 경우 즉시 당사에 연락해 주십시오.',
              colorScheme,
            ),
            SizedBox(height: 32),

            // Changes to This Policy
            _buildSectionTitle('개인정보 보호 정책 변경', colorScheme),
            SizedBox(height: 12),
            _buildParagraph(
              '당사는 때때로 개인정보 보호 정책을 업데이트할 수 있습니다. 변경사항이 있을 경우 '
              '본 페이지에 새로운 개인정보 보호 정책을 게시하고 "최종 업데이트" 날짜를 갱신합니다. '
              '변경사항을 확인하기 위해 주기적으로 본 정책을 검토하시기 바랍니다.',
              colorScheme,
            ),
            SizedBox(height: 32),

            // Contact Us
            _buildSectionTitle('문의하기', colorScheme),
            SizedBox(height: 12),
            _buildParagraph(
              '본 개인정보 보호 정책에 대한 질문이 있으시면 아래로 연락해 주십시오:',
              colorScheme,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '이메일',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'support@quizapp.com',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '운영사',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '퀴즈 앱',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Footer Note
            Center(
              child: Text(
                '퀴즈 앱을 이용해 주셔서 감사합니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildParagraph(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        height: 1.6,
        color: colorScheme.onSurface.withOpacity(0.85),
      ),
    );
  }

  Widget _buildBulletPoint(
    String title,
    String description,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: colorScheme.onSurface,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.6,
                  ),
                ),
                TextSpan(
                  text: description,
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurface.withOpacity(0.85),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleBullet(String text, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
