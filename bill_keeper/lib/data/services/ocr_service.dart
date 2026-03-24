import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRResult {
  final String text;
  final List<String> recommendedTags;

  OCRResult({required this.text, required this.recommendedTags});
}

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isModelDownloaded = false;

  static const List<String> _tagKeywords = [
    '身份证', '证件', '护照', '驾照', '行驶证',
    '门票', '景区', '景点', '旅游', '公园',
    '车票', '火车票', '飞机票', '登机牌',
    '发票', '增值税', '普通发票', '电子发票',
    '收据', '小票', '购物小票',
    '银行卡', '信用卡', '储蓄卡',
    '会员', '会员卡', '积分卡',
    '病历', '处方', '检查报告', '化验单',
    '快递', '物流', '运单',
    '餐饮', '餐厅', '酒店', '住宿',
    '电影', '演唱会', '话剧', '展览',
  ];

  Future<bool> isModelReady() async {
    return _isModelDownloaded;
  }

  Future<OCRResult> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      final text = recognizedText.text;
      final recommendedTags = _generateRecommendedTags(text);

      _isModelDownloaded = true;

      return OCRResult(
        text: text,
        recommendedTags: recommendedTags,
      );
    } catch (e) {
      return OCRResult(
        text: '',
        recommendedTags: [],
      );
    }
  }

  List<String> _generateRecommendedTags(String text) {
    final Set<String> tags = {};
    
    for (final keyword in _tagKeywords) {
      if (text.contains(keyword)) {
        if (keyword == '身份证' || keyword == '护照' || keyword == '驾照' || keyword == '行驶证') {
          tags.add('证件');
        } else if (keyword == '门票' || keyword == '景区' || keyword == '景点' || keyword == '旅游' || keyword == '公园') {
          tags.add('景点');
        } else if (keyword == '车票' || keyword == '火车票' || keyword == '飞机票' || keyword == '登机牌') {
          tags.add('交通');
        } else if (keyword == '发票' || keyword == '增值税' || keyword == '普通发票' || keyword == '电子发票') {
          tags.add('发票');
        } else if (keyword == '收据' || keyword == '小票' || keyword == '购物小票') {
          tags.add('小票');
        } else if (keyword == '银行卡' || keyword == '信用卡' || keyword == '储蓄卡') {
          tags.add('银行卡');
        } else if (keyword == '病历' || keyword == '处方' || keyword == '检查报告' || keyword == '化验单') {
          tags.add('医疗');
        } else if (keyword == '快递' || keyword == '物流' || keyword == '运单') {
          tags.add('快递');
        } else if (keyword == '餐饮' || keyword == '餐厅') {
          tags.add('餐饮');
        } else if (keyword == '酒店' || keyword == '住宿') {
          tags.add('住宿');
        } else if (keyword == '电影' || keyword == '演唱会' || keyword == '话剧' || keyword == '展览') {
          tags.add('娱乐');
        }
      }
    }

    if (text.isNotEmpty && tags.isEmpty) {
      tags.add('其他');
    }

    return tags.take(5).toList();
  }

  void dispose() {
    _textRecognizer.close();
  }
}
