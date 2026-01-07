# AGENTS.md - Widget Tooltip 패키지

AI 에이전트를 위한 Flutter 툴팁 패키지 가이드라인.

**저장소**: https://github.com/hongmono/widget_tooltip | **Pub.dev**: https://pub.dev/packages/widget_tooltip
**SDK**: Dart >=3.2.5 <4.0.0, Flutter >=1.17.0

## 빌드/린트/테스트 명령어

```bash
# 패키지 명령어 (프로젝트 루트)
flutter pub get              # 의존성 설치
flutter analyze              # 정적 분석 (flutter_lints)
flutter test                 # 전체 테스트 실행
flutter test test/widget_tooltip_test.dart  # 단일 테스트 파일
flutter test --name "설명"    # 이름으로 테스트 실행
flutter pub publish --dry-run # 배포 전 검증
dart format .                # 코드 포맷팅

# 예제 앱 (example/ 디렉토리에서)
cd example && flutter pub get && flutter run
flutter run -d macos         # 특정 플랫폼에서 실행
```

## 프로젝트 구조

```
lib/
├── widget_tooltip.dart          # 라이브러리 진입점
└── src/
    ├── widget_tooltip.dart      # 메인 구현체
    └── triangles/               # 삼각형 인디케이터 위젯
test/widget_tooltip_test.dart    # 위젯 테스트
example/                         # 데모 앱
.github/workflows/publish.yml    # pub.dev CI/CD
```

## Git 커밋 컨벤션

### 커밋 메시지 형식
```
<타입>: <제목>

[본문 (선택)]
```

### 타입
| 타입 | 설명 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 리팩토링 (기능 변경 없음) |
| `style` | 코드 스타일 변경 (포맷팅 등) |
| `docs` | 문서 수정 |
| `test` | 테스트 추가/수정 |
| `chore` | 빌드, 설정 파일 수정 |

### 커밋 메시지 규칙
- **한글로 작성**
- 제목은 50자 이내
- 명령형으로 작성 (예: "추가", "수정", "삭제")
- 수정한 내용만 명시적으로 작성

### 예시
```
feat: 툴팁 애니메이션 타입 추가

fix: 삼각형 위치 오프셋 계산 오류 수정

refactor: show() 메서드 단일 오버레이 삽입으로 변경

docs: README 설치 가이드 업데이트
```

## 코드 스타일

### 린팅
- `package:flutter_lints/flutter.yaml` 사용
- `flutter analyze` 경고 0개 유지

### Import 순서 (그룹 사이 빈 줄)
```dart
import 'dart:async';                    // 1. dart: 코어
import 'package:flutter/material.dart'; // 2. package:flutter/
import 'package:widget_tooltip/src/...';// 3. 내부 패키지
```

### 네이밍 컨벤션
| 타입 | 컨벤션 | 예시 |
|------|--------|------|
| 클래스 | PascalCase | `WidgetTooltip`, `TooltipController` |
| Enum | `WidgetTooltip` 접두사 | `WidgetTooltipDirection` |
| Enum 값 | camelCase | `WidgetTooltipTriggerMode.longPress` |
| Private | `_` 접두사 | `_WidgetTooltipState`, `_isShow` |

### 위젯 패턴
```dart
// StatelessWidget - super.key 사용, required 먼저, optional은 기본값과 함께
class UpperTriangle extends StatelessWidget {
  const UpperTriangle({
    super.key,
    this.backgroundColor = Colors.white,
    required this.triangleRadius,
  });
  final Color backgroundColor;
  final double triangleRadius;
  @override
  Widget build(BuildContext context) { ... }
}

// StatefulWidget - /// 로 파라미터 문서화
class WidgetTooltip extends StatefulWidget {
  const WidgetTooltip({super.key, required this.message, required this.child, ...});
  /// 툴팁에 표시할 메시지 위젯
  final Widget message;
  @override
  State<WidgetTooltip> createState() => _WidgetTooltipState();
}
```

### Dart 3+ 기능 - Switch 표현식 사용
```dart
final Widget triangle = switch (widget.axis) {
  Axis.vertical when isTop => UpperTriangle(...),
  Axis.vertical when isBottom => DownTriangle(...),
  _ => const SizedBox.shrink(),
};
```

### 애니메이션 패턴
```dart
class _WidgetTooltipState extends State<WidgetTooltip> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: widget.animationDuration);
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
```

### 타입 안전성
- `as dynamic`, `@ts-ignore`, 타입 억제 **절대 금지**
- null-safety 기능 사용 (`?.`, `??`, null 체크)
- RenderBox 사용 전 null 체크 필수

## 테스트

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_tooltip/widget_tooltip.dart';

void main() {
  testWidgets('WidgetTooltip 탭 시 표시', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: WidgetTooltip(
        message: const Text('Test'),
        triggerMode: WidgetTooltipTriggerMode.tap,
        child: const Text('Target'),
      ),
    ));
    // ... 테스트 로직
  });
}
```

## 배포

GitHub Actions로 버전 태그 시 자동 배포:
```bash
git tag v1.2.0 && git push origin v1.2.0
```

## 핵심 구현 사항

1. **오버레이 시스템**: `Overlay` + `CompositedTransformFollower`로 위치 지정
2. **스마트 포지셔닝**: 화면 가장자리 감지 후 툴팁 위치 자동 조정
3. **컨트롤러 패턴**: `TooltipController`는 `ChangeNotifier` 상속
4. **삼각형 재사용**: `DownTriangle`은 `UpperTrianglePainter`를 180도 회전

## 자주하는 작업

### 새 애니메이션 타입 추가
1. `lib/src/widget_tooltip.dart`에서 `WidgetTooltipAnimation` enum에 값 추가
2. `_buildAnimatedTooltip` switch 표현식에 케이스 추가
3. CHANGELOG.md 업데이트

### 새 프로퍼티 추가
1. `WidgetTooltip` 생성자에 기본값과 함께 파라미터 추가
2. `///` 주석으로 문서화
3. `_WidgetTooltipState`에서 필요에 따라 사용
4. example 앱에서 데모
5. CHANGELOG.md 업데이트
