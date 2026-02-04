[English](README.md) | [한국어](README_ko.md)

# Widget Tooltip

Flutter 앱을 위한 고도로 커스터마이징 가능한 툴팁 위젯. 스마트 포지셔닝, 다양한 트리거 모드, 풍부한 스타일링 옵션을 제공합니다.

[![pub package](https://img.shields.io/pub/v/widget_tooltip.svg)](https://pub.dev/packages/widget_tooltip)
[![likes](https://img.shields.io/pub/likes/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)
[![popularity](https://img.shields.io/pub/popularity/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)
[![pub points](https://img.shields.io/pub/points/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)

**[라이브 데모](https://hongmono.github.io/flutter-packages/)**

## 기능

### 트리거 모드

툴팁을 표시하는 다양한 방법을 지원합니다:

| 모드 | 설명 |
|------|------|
| `tap` | 탭하면 표시 |
| `longPress` | 길게 누르면 표시 |
| `doubleTap` | 더블 탭하면 표시 |
| `hover` | 마우스 호버 시 표시 (Desktop/Web) |
| `manual` | 프로그래밍 방식으로 제어 |

### 스마트 포지셔닝

툴팁이 화면 위치에 따라 자동으로 배치됩니다:
- 타겟이 **화면 상단**에 있으면 → 툴팁이 **아래**에 표시
- 타겟이 **화면 하단**에 있으면 → 툴팁이 **위**에 표시

`autoFlip: false`와 `direction`을 사용하면 위치를 고정할 수 있습니다.

### 방향 설정

`direction`과 `axis`로 툴팁 위치를 제어합니다.

### 닫기 모드

| 모드 | 설명 |
|------|------|
| `tapAnywhere` | 아무 곳이나 탭하면 닫힘 (기본값) |
| `tapOutside` | 툴팁 바깥을 탭해야 닫힘 |
| `tapInside` | 툴팁을 탭해야 닫힘 |
| `manual` | 컨트롤러로만 닫힘 |

### 커스텀 스타일링

`messageDecoration`, `triangleColor`, `messagePadding` 등으로 외관을 완전히 제어할 수 있습니다.

## 설치

```yaml
dependencies:
  widget_tooltip: ^1.2.2
```

```bash
flutter pub add widget_tooltip
```

## 빠른 시작

### 기본 사용법

```dart
import 'package:widget_tooltip/widget_tooltip.dart';

WidgetTooltip(
  message: Text('안녕하세요!'),
  child: Icon(Icons.info),
)
```

### 트리거 모드

```dart
// 탭하면 표시
WidgetTooltip(
  message: Text('탭으로 트리거됨'),
  triggerMode: WidgetTooltipTriggerMode.tap,
  child: Icon(Icons.touch_app),
)

// 호버 (Desktop/Web)
WidgetTooltip(
  message: Text('호버로 트리거됨'),
  triggerMode: WidgetTooltipTriggerMode.hover,
  child: Icon(Icons.mouse),
)
```

### 수동 제어

```dart
final controller = TooltipController();

WidgetTooltip(
  message: Text('제어되는 툴팁'),
  controller: controller,
  triggerMode: WidgetTooltipTriggerMode.manual,
  dismissMode: WidgetTooltipDismissMode.manual,
  child: Icon(Icons.info),
)

// 프로그래밍 방식으로 표시/숨기기
controller.show();
controller.dismiss();
controller.toggle();
```

### 방향 고정

```dart
// 항상 타겟 위에 표시
WidgetTooltip(
  message: Text('항상 위에'),
  direction: WidgetTooltipDirection.top,
  autoFlip: false,  // 자동 포지셔닝 비활성화
  child: Icon(Icons.arrow_upward),
)

// 가로 방향 툴팁
WidgetTooltip(
  message: Text('오른쪽에'),
  direction: WidgetTooltipDirection.right,
  axis: Axis.horizontal,
  autoFlip: false,
  child: Icon(Icons.arrow_forward),
)
```

### 커스텀 스타일링

```dart
WidgetTooltip(
  message: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check, color: Colors.white),
      SizedBox(width: 8),
      Text('성공!'),
    ],
  ),
  triggerMode: WidgetTooltipTriggerMode.tap,
  messageDecoration: BoxDecoration(
    color: Colors.green,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.green.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  triangleColor: Colors.green,
  messagePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  child: Icon(Icons.info),
)
```

### 자동 닫기

```dart
WidgetTooltip(
  message: Text('2초 후 사라집니다'),
  triggerMode: WidgetTooltipTriggerMode.tap,
  autoDismissDuration: Duration(seconds: 2),
  child: Icon(Icons.timer),
)
```

### 애니메이션

```dart
WidgetTooltip(
  message: Text('스케일 애니메이션'),
  animation: WidgetTooltipAnimation.scale,
  animationDuration: Duration(milliseconds: 200),
  child: Icon(Icons.animation),
)
```

사용 가능한 애니메이션: `fade` (기본값), `scale`, `scaleAndFade`, `none`

## API 레퍼런스

### WidgetTooltip

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `message` | `Widget` | 필수 | 툴팁에 표시되는 내용 |
| `child` | `Widget` | 필수 | 툴팁을 트리거하는 타겟 위젯 |
| `triggerMode` | `WidgetTooltipTriggerMode?` | `longPress` | 툴팁 트리거 방식 |
| `dismissMode` | `WidgetTooltipDismissMode?` | `tapAnywhere` | 툴팁 닫기 방식 |
| `direction` | `WidgetTooltipDirection?` | 자동 | 툴팁 방향 (top/bottom/left/right) |
| `axis` | `Axis` | `vertical` | 툴팁 축 |
| `autoFlip` | `bool` | `true` | 화면 중심 기준 자동 배치 |
| `controller` | `TooltipController?` | null | 수동 제어용 컨트롤러 |
| `animation` | `WidgetTooltipAnimation` | `fade` | 애니메이션 타입 |
| `animationDuration` | `Duration` | 300ms | 애니메이션 시간 |
| `autoDismissDuration` | `Duration?` | null | 자동 닫기 시간 |
| `messageDecoration` | `BoxDecoration` | 검은색 둥근 모서리 | 툴팁 박스 데코레이션 |
| `messagePadding` | `EdgeInsetsGeometry` | 8x16 | 툴팁 내부 패딩 |
| `triangleColor` | `Color` | 검정 | 삼각형 인디케이터 색상 |
| `triangleSize` | `Size` | 10x10 | 삼각형 인디케이터 크기 |
| `triangleRadius` | `double` | 2 | 삼각형 모서리 반경 |
| `targetPadding` | `double` | 4 | 타겟과 툴팁 사이 간격 |
| `padding` | `EdgeInsetsGeometry` | 16 | 화면 가장자리 패딩 |
| `onShow` | `VoidCallback?` | null | 툴팁 표시 시 콜백 |
| `onDismiss` | `VoidCallback?` | null | 툴팁 숨김 시 콜백 |

### TooltipController

| 메서드 | 설명 |
|--------|------|
| `show()` | 툴팁 표시 |
| `dismiss()` | 툴팁 숨기기 |
| `toggle()` | 표시/숨기기 전환 |
| `isShow` | 현재 표시 상태 |

## 플랫폼 지원

| 플랫폼 | 지원 |
|--------|------|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |

## 요구사항

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.2.5

## 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.
