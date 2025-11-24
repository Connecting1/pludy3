// lib/screens/fileview_screens/fileview_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../models/learning_models.dart';
import 'pdf_viewer_screen.dart';

class FileViewScreen extends StatefulWidget {
  const FileViewScreen({super.key});

  @override
  FileViewScreenState createState() => FileViewScreenState();
}

class FileViewScreenState extends State<FileViewScreen> with WidgetsBindingObserver {
  List<Folder> _folders = [];
  List<PDFFile> _pdfs = [];
  String? _currentFolderId; // null이면 루트
  bool _isLoading = false;
  String _currentFolderName = '내 파일';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 다시 포그라운드로 돌아올 때 새로고침
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  // 외부에서 호출 가능한 새로고침 메서드
  void refresh() {
    _loadData();
  }

  // 데이터 로드
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // 폴더 목록 로드
      final folders = await ApiService.getFolders();
      
      // PDF 목록 로드 (현재 폴더)
      final pdfs = await ApiService.getPDFList(folderId: _currentFolderId);
      
      setState(() {
        _folders = folders;
        _pdfs = pdfs;
        _isLoading = false;
      });
      
      print('✅ 데이터 로드 완료: ${folders.length}개 폴더, ${pdfs.length}개 PDF');
    } catch (e) {
      print('❌ 데이터 로드 오류: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 불러오는데 실패했습니다')),
        );
      }
    }
  }

  // 폴더 생성 다이얼로그
  void _showCreateFolderDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('새 폴더'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '폴더 이름',
            hintText: '예: 수학 강의',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('폴더 이름을 입력하세요')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                await ApiService.createFolder(controller.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('폴더가 생성되었습니다')),
                );
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('폴더 생성 실패: $e')),
                );
              }
            },
            child: Text('생성'),
          ),
        ],
      ),
    );
  }

  // PDF 업로드
  Future<void> _uploadPDF() async {
    try {
      // 파일 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      setState(() => _isLoading = true);

      final filePath = result.files.single.path!;
      
      // PDF 업로드
      final uploadedPDF = await ApiService.uploadPDFFile(
        filePath,
        folderId: _currentFolderId,
      );

      if (uploadedPDF != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF가 업로드되었습니다')),
        );
        _loadData();
      } else {
        throw Exception('업로드 실패');
      }
    } catch (e) {
      print('❌ PDF 업로드 오류: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF 업로드 실패: $e')),
      );
    }
  }

  // 폴더 삭제 확인
  void _confirmDeleteFolder(Folder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('폴더 삭제'),
        content: Text('${folder.name} 폴더를 삭제하시겠습니까?\n(폴더 내 파일은 루트로 이동됩니다)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await ApiService.deleteFolder(folder.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('폴더가 삭제되었습니다')),
                );
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('폴더 삭제 실패: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }

  // PDF 삭제 확인
  Future<void> _confirmDeletePDF(PDFFile pdf) async {
    // 먼저 사용 중인 채팅방 수 확인
    final usage = await ApiService.checkPDFUsage(pdf.id);
    final linkedRoomsCount = usage?['linked_rooms_count'] ?? 0;

    if (!mounted) return;

    // 경고 메시지 구성
    String warningMessage = '${pdf.originalFilename}을(를) 삭제하시겠습니까?';
    if (linkedRoomsCount > 0) {
      warningMessage += '\n\n⚠️ 주의: 이 PDF는 현재 $linkedRoomsCount개의 채팅방에서 사용 중입니다.\n삭제하면 해당 채팅방들에서 PDF 기반 학습이 불가능해집니다.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('파일 삭제'),
        content: Text(warningMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final result = await ApiService.deletePDF(pdf.id);
                if (result != null) {
                  final unlinkedCount = result['linked_rooms_count'] ?? 0;
                  String message = '파일이 삭제되었습니다';
                  if (unlinkedCount > 0) {
                    message += ' ($unlinkedCount개 채팅방 연결 해제됨)';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                  _loadData();
                } else {
                  throw Exception('삭제 실패');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('파일 삭제 실패: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }

  // 폴더 진입
  void _enterFolder(Folder folder) {
    setState(() {
      _currentFolderId = folder.id;
      _currentFolderName = folder.name;
    });
    _loadData();
  }

  // 루트로 돌아가기
  void _goToRoot() {
    setState(() {
      _currentFolderId = null;
      _currentFolderName = '내 파일';
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_currentFolderId != null)
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _goToRoot,
              ),
            Text(_currentFolderName),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder),
            onPressed: _showCreateFolderDialog,
            tooltip: '폴더 생성',
          ),
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _uploadPDF,
            tooltip: 'PDF 업로드',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _folders.isEmpty && _pdfs.isEmpty
                  ? _buildEmptyState()
                  : _buildFileList(),
            ),
    );
  }

  // 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '파일이 없습니다',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '상단의 버튼으로 폴더를 만들거나\nPDF를 업로드하세요',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 파일 목록 UI
  Widget _buildFileList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // 폴더 섹션 (루트에서만 표시)
        if (_currentFolderId == null && _folders.isNotEmpty) ...[
          Text(
            '폴더',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12),
          ..._folders.map((folder) => _buildFolderCard(folder)),
          SizedBox(height: 24),
        ],
        
        // PDF 섹션
        if (_pdfs.isNotEmpty) ...[
          Text(
            'PDF 파일',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12),
          ..._pdfs.map((pdf) => _buildPDFCard(pdf)),
        ],
      ],
    );
  }

  // 폴더 카드
  Widget _buildFolderCard(Folder folder) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _enterFolder(folder),
        onLongPress: () => _confirmDeleteFolder(folder),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.folder, size: 40, color: Colors.amber),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '생성일: ${_formatDate(folder.createdAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // PDF 카드
  Widget _buildPDFCard(PDFFile pdf) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerScreen(pdfFile: pdf),
            ),
          );
        },
        onLongPress: () => _confirmDeletePDF(pdf),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pdf.originalFilename,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (pdf.pageCount != null) ...[
                          Icon(Icons.description, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '${pdf.pageCount}페이지',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(width: 12),
                        ],
                        Icon(Icons.storage, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          pdf.fileSizeReadable,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      '업로드: ${_formatDate(pdf.uploadedAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}