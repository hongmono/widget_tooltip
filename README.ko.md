# Widget Tooltip

> [English](README.md) | **한국어**

Flutter 애플리케이션을 위한 고도로 커스터마이징 가능한 툴팁 위젯입니다. 다양한 트리거 모드, 닫기 동작, 스타일링 옵션을 제공합니다.

[![pub package](https://img.shields.io/pub/v/widget_tooltip.svg)](https://pub.dev/packages/widget_tooltip)
[![likes](https://img.shields.io/pub/likes/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)
[![popularity](https://img.shields.io/pub/popularity/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)
[![pub points](https://img.shields.io/pub/points/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)

![Widget Tooltip 데모](assets/demo.gif)

## ✨ 주요 기능

### 🎯 다양한 트리거 모드
- **탭(Tap)**: 한 번 탭하면 툴팁 표시
- **롱 프레스(Long Press)**: 길게 눌러서 툴팁 표시
- **더블 탭(Double Tap)**: 두 번 탭하면 툴팁 표시
- **수동 제어(Manual)**: 컨트롤러를 통한 프로그래밍 방식 제어

### 🎨 완전한 커스터마이징
- ✅ 자유로운 색상 설정
- ✅ 크기 조절 가능
- ✅ 유연한 스타일링
- ✅ 커스텀 데코레이션
- ✅ 위젯을 메시지로 사용 가능
- ✅ 삼각형 포인터 커스터마이징

### 📍 스마트 포지셔닝
- 🔄 자동 엣지 감지 및 위치 조정
- 🧭 4방향 지원 (위, 아래, 왼쪽, 오른쪽)
- 📏 패딩 및 오프셋 조절 가능
- 🎚️ 축(Axis) 제어 (세로/가로)
- 🖥️ 화면 경계 자동 인식

### 🎮 유연한 제어
- 🎛️ 내장 컨트롤러 지원
- 📣 표시/숨김 콜백
- 🚪 커스텀 닫기 동작
  - 툴팁 바깥 탭
  - 툴팁 안쪽 탭
  - 아무 곳이나 탭
  - 수동 제어
- 🔔 이벤트 핸들링

## 📦 설치

`pubspec.yaml`에 다음을 추가하세요:

```yaml
dependencies:
  widget_tooltip: ^1.1.4
```

또는 다음 명령어를 실행하세요:

```bash
flutter pub add widget_tooltip
```

## 🚀 사용법

### 기본 사용

```dart
import 'package:widget_tooltip/widget_tooltip.dart';

WidgetTooltip(
  message: Text('안녕하세요!'),
  child: Icon(Icons.info),
)
```

### 커스터마이징된 툴팁

```dart
WidgetTooltip(
  message: Text(
    '스타일이 적용된 툴팁',
    style: TextStyle(color: Colors.white, fontSize: 16),
  ),
  child: ElevatedButton(
    onPressed: () {},
    child: Text('버튼'),
  ),
  // 트리거 설정
  triggerMode: WidgetTooltipTriggerMode.tap,

  // 방향 설정
  direction: WidgetTooltipDirection.top,

  // 스타일링
  triangleColor: Colors.blue,
  messageDecoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  messagePadding: EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  ),

  // 삼각형 포인터 설정
  triangleSize: Size(12, 12),
  triangleRadius: 2,
  targetPadding: 8,
)
```

### 컨트롤러를 사용한 수동 제어

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TooltipController _controller = TooltipController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WidgetTooltip(
          message: Text('컨트롤러로 제어되는 툴팁'),
          controller: _controller,
          dismissMode: WidgetTooltipDismissMode.manual,
          child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Text('타겟 위젯'),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _controller.show,
              child: Text('표시'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _controller.dismiss,
              child: Text('숨기기'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _controller.toggle,
              child: Text('토글'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 콜백 사용

```dart
WidgetTooltip(
  message: Text('콜백이 있는 툴팁'),
  child: Icon(Icons.help),
  onShow: () {
    print('툴팁이 표시되었습니다');
  },
  onDismiss: () {
    print('툴팁이 닫혔습니다');
  },
)
```

### 긴 텍스트 처리

```dart
WidgetTooltip(
  message: Text(
    '매우 긴 텍스트도 자동으로 화면 크기에 맞춰 조정됩니다. '
    'Widget Tooltip은 스마트 엣지 감지 기능으로 항상 화면 안에 '
    '툴팁이 표시되도록 합니다.',
    style: TextStyle(color: Colors.white),
  ),
  child: Icon(Icons.article),
  messageDecoration: BoxDecoration(
    color: Colors.black87,
    borderRadius: BorderRadius.circular(8),
  ),
  messagePadding: EdgeInsets.all(16),
)
```

## 🎯 주요 속성

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `message` | `Widget` | **필수** | 툴팁에 표시할 위젯 |
| `child` | `Widget` | **필수** | 타겟 위젯 |
| `triggerMode` | `WidgetTooltipTriggerMode?` | `longPress` | 툴팁 트리거 모드 |
| `dismissMode` | `WidgetTooltipDismissMode?` | `tapAnyWhere` | 툴팁 닫기 모드 |
| `direction` | `WidgetTooltipDirection?` | `null` (자동) | 툴팁 표시 방향 |
| `axis` | `Axis` | `vertical` | 배치 축 |
| `controller` | `TooltipController?` | `null` | 수동 제어용 컨트롤러 |
| `triangleColor` | `Color` | `Colors.black` | 삼각형 포인터 색상 |
| `triangleSize` | `Size` | `Size(10, 10)` | 삼각형 포인터 크기 |
| `triangleRadius` | `double` | `2` | 삼각형 포인터 모서리 반경 |
| `targetPadding` | `double` | `4` | 타겟과 툴팁 사이 간격 |
| `messageDecoration` | `BoxDecoration` | 검은색 배경, 둥근 모서리 | 메시지 박스 데코레이션 |
| `messagePadding` | `EdgeInsetsGeometry` | `EdgeInsets.symmetric(vertical: 8, horizontal: 16)` | 메시지 박스 내부 패딩 |
| `messageStyle` | `TextStyle?` | 흰색 글자, 14px | 메시지 텍스트 스타일 |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(16)` | 화면 가장자리로부터의 여백 |
| `offsetIgnore` | `bool` | `false` | 오프셋 무시 여부 |
| `onShow` | `VoidCallback?` | `null` | 툴팁 표시 시 콜백 |
| `onDismiss` | `VoidCallback?` | `null` | 툴팁 닫힐 때 콜백 |

## 📱 플랫폼 지원

| 플랫폼 | 지원 여부 |
|--------|-----------|
| ✅ Android | 지원 |
| ✅ iOS | 지원 |
| ✅ Web | 지원 |
| ✅ Windows | 지원 |
| ✅ macOS | 지원 |
| ✅ Linux | 지원 |

## 🔧 요구사항

- **Flutter SDK**: >=1.17.0
- **Dart SDK**: >=3.2.5 <4.0.0

## 💡 왜 Widget Tooltip을 사용해야 할까요?

Flutter의 내장 `Tooltip` 위젯은 간단한 사용 사례에는 좋지만, 툴팁의 외관과 동작에 대한 더 많은 제어가 필요할 때 Widget Tooltip은 다음을 제공합니다:

| 기능 | Flutter 기본 Tooltip | Widget Tooltip |
|------|----------------------|----------------|
| 커스텀 위젯 메시지 | ❌ (텍스트만) | ✅ 모든 위젯 |
| 트리거 모드 선택 | ❌ | ✅ 4가지 모드 |
| 닫기 동작 제어 | ❌ | ✅ 4가지 옵션 |
| 프로그래밍 방식 제어 | 제한적 | ✅ 완전한 제어 |
| 삼각형 포인터 | ❌ | ✅ 커스터마이징 가능 |
| 엣지 감지 | 기본적 | ✅ 스마트 감지 |
| 콜백 지원 | ❌ | ✅ onShow, onDismiss |

## 📚 추가 문서

더 자세한 문서와 예제는 [공식 문서 사이트](https://hongmono.github.io/widget_tooltip)를 방문하세요.

### 문서 섹션
- 📖 [설치 가이드](https://hongmono.github.io/widget_tooltip/installation)
- 🎓 [기본 사용법](https://hongmono.github.io/widget_tooltip/basic-usage)
- 🚀 [고급 사용법](https://hongmono.github.io/widget_tooltip/advanced-usage)
- 🎨 [스타일링 예제](https://hongmono.github.io/widget_tooltip/examples/styling)
- 🎯 [트리거 모드](https://hongmono.github.io/widget_tooltip/examples/trigger-modes)
- 🚪 [닫기 모드](https://hongmono.github.io/widget_tooltip/examples/dismiss-modes)
- 📍 [포지셔닝](https://hongmono.github.io/widget_tooltip/examples/positioning)

## 🤝 기여하기

기여는 언제나 환영합니다! Pull Request를 제출하거나 이슈를 보고해 주세요.

1. 이 저장소를 포크하세요
2. 새로운 브랜치를 생성하세요 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성하세요

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 👨‍💻 개발자

**hongmono**
- GitHub: [@hongmono](https://github.com/hongmono)
- Package: [pub.dev/publishers/hongmono.com](https://pub.dev/publishers/hongmono.com/packages)

## 🌟 별을 눌러주세요!

이 프로젝트가 도움이 되었다면 ⭐️를 눌러주세요!

---

**Version**: 1.1.4
**Last Updated**: 2025
