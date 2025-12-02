import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/quiz_service.dart';
import '../../models/quiz_models.dart';
import 'quiz_play_screen.dart';
import 'ai_quiz_generate_screen.dart';
import 'quiz_edit_screen.dart';
import 'quiz_create_screen.dart';

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  // _quizService 사용하지 않으므로 제거
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedQuizIds = {}; // final로 변경

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  // 선택 모드 토글
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedQuizIds.clear();
      }
    });
  }

  // 퀴즈 선택 토글
  void _toggleQuizSelection(String quizId) {
    setState(() {
      if (_selectedQuizIds.contains(quizId)) {
        _selectedQuizIds.remove(quizId);
      } else {
        _selectedQuizIds.add(quizId);
      }
    });
  }

  // 선택된 퀴즈들 삭제
  Future<void> _deleteSelectedQuizzes() async {
    if (_selectedQuizIds.isEmpty) return;

    if (!mounted) return; // mounted 체크 추가

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              '퀴즈 삭제',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              '선택한 ${_selectedQuizIds.length}개의 퀴즈를 삭제하시겠습니까?',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('취소', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // 선택된 퀴즈들을 하나씩 삭제
      for (final quizId in _selectedQuizIds) {
        await userProvider.deleteQuiz(quizId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedQuizIds.length}개의 퀴즈가 삭제되었습니다')),
        );

        setState(() {
          _selectedQuizIds.clear();
          _isSelectionMode = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<UserProvider>(context, listen: false).loadQuizzes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로딩 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteQuiz(String quizId) async {
    try {
      final success = await Provider.of<UserProvider>(
        context,
        listen: false,
      ).deleteQuiz(quizId);
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('퀴즈가 삭제되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userProvider = Provider.of<UserProvider>(context);
    final quizzes = userProvider.quizzes;

    return Scaffold(
      appBar: AppBar(
        title:
            _isSelectionMode
                ? Text('${_selectedQuizIds.length}개 선택됨')
                : const Text('퀴즈'),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _toggleSelectionMode,
              tooltip: '취소',
            )
          else
            IconButton(
              icon: Icon(Icons.checklist),
              onPressed: _toggleSelectionMode,
              tooltip: '선택',
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
              : quizzes.isEmpty
              ? _buildEmptyState(colorScheme)
              : RefreshIndicator(
                onRefresh: _loadQuizzes,
                color: colorScheme.primary,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    return _buildQuizCard(quizzes[index], colorScheme);
                  },
                ),
              ),
      floatingActionButton:
          _isSelectionMode
              ? _selectedQuizIds.isNotEmpty
                  ? FloatingActionButton.extended(
                    onPressed: _deleteSelectedQuizzes,
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icon(Icons.delete),
                    label: Text('삭제 (${_selectedQuizIds.length})'),
                  )
                  : null
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 수동 추가 버튼 - 퀴즈가 1개 이상일 때만 표시
                  if (quizzes.isNotEmpty) ...[
                    SizedBox(
                      width: 130,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizCreateScreen(),
                            ),
                          ).then((_) => _loadQuizzes());
                        },
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        icon: Icon(Icons.edit, size: 18),
                        label: Text(
                          '수동 추가',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        extendedPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        heroTag: 'manual_quiz',
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                  // AI 생성 버튼 - 항상 표시
                  SizedBox(
                    width: 130,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AIQuizGenerateScreen(),
                          ),
                        ).then((_) => _loadQuizzes());
                      },
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      icon: Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        'AI 생성',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      extendedPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      heroTag: 'ai_quiz',
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: Icon(Icons.quiz_outlined, size: 35, color: Colors.grey),
          ),
          SizedBox(height: 20),
          Text(
            '아직 퀴즈가 없습니다',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '첫 퀴즈를 만들어보세요!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizCreateScreen()),
              ).then((_) => _loadQuizzes());
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(color: colorScheme.onSurface),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              minimumSize: Size(120, 40),
            ),
            icon: Icon(Icons.add, size: 18),
            label: Text('만들기', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // 수정된 _buildQuizCard 함수
  Widget _buildQuizCard(Quiz quiz, ColorScheme colorScheme) {
    final isSelected = _selectedQuizIds.contains(quiz.id);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            _toggleQuizSelection(quiz.id!);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizPlayScreen(quiz: quiz),
              ),
            ).then((_) => _loadQuizzes());
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.quiz,
                      color: colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.quizName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${quiz.questions.length} 문제',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // 선택 모드가 아닐 때만 수정 및 삭제 버튼 표시
                  if (!_isSelectionMode)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizEditScreen(quiz: quiz),
                              ),
                            ).then((_) => _loadQuizzes());
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    backgroundColor: colorScheme.surface,
                                    title: Text(
                                      '퀴즈 삭제',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    content: Text(
                                      '정말 삭제하시겠습니까?',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          '취소',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteQuiz(quiz.id!);
                                        },
                                        child: Text(
                                          '삭제',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // 선택 모드일 때 왼쪽 위에 체크박스 표시
            if (_isSelectionMode)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? colorScheme.primary : colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child:
                      isSelected
                          ? Icon(
                            Icons.check,
                            color: colorScheme.onPrimary,
                            size: 16,
                          )
                          : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
