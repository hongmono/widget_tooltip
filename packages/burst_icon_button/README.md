# BurstIconButton

BurstIconButton은 버튼에 즐거운 폭발 애니메이션 효과를 추가하는 커스터마이즈 가능한 Flutter 위젯입니다. 버튼을 누르거나 길게 누르면 아이콘이 터지는 효과가 생겨, 사용자 인터페이스에 재미있고 매력적인 요소를 추가합니다.


## 특징

- 일반, 누름, 폭발 상태에 대해 커스터마이즈 가능한 아이콘
- 조절 가능한 애니메이션 지속 시간 및 길게 누르기 쓰로틀
- 수평 아이콘 이동을 위한 설정 가능한 교차 진폭
- 탭과 길게 누르기 상호작용 모두 지원
- 폭발 아이콘의 부드러운 페이드 아웃 및 위쪽 이동


## 설치

패키지의 `pubspec.yaml` 파일에 다음을 추가하세요:

```yaml
dependencies:
  burst_icon_button: ^1.0.0
```


## 사용법

다음은 BurstIconButton을 사용하는 간단한 예시입니다:

```dart
import 'package:flutter/material.dart';
import 'package:burst_icon_button/burst_icon_button.dart';

BurstIconButton(
  icon: Icon(Icons.favorite, color: Colors.grey),
  pressedIcon: Icon(Icons.favorite, color: Colors.red),
  burstIcon: Icon(Icons.favorite, color: Colors.pink),
  onPressed: () {
    print('버튼이 눌렸습니다!');
  },
)
```


## 커스터마이징

BurstIconButton은 여러 가지 커스터마이징 옵션을 제공합니다:
	•	icon: 기본적으로 표시되는 아이콘 (필수)
	•	pressedIcon: 버튼이 눌렸을 때 표시되는 아이콘 (선택)
	•	burstIcon: 폭발 효과에 사용되는 아이콘 (선택, 기본값은 icon)
	•	duration: 폭발 애니메이션의 지속 시간 (기본값: 1200ms)
	•	throttleDuration: 길게 누를 때 폭발 생성 간 간격 (기본값: 100ms)
	•	onPressed: 버튼이 눌렸을 때 호출되는 콜백 함수
	•	crossAmplitude: 폭발 아이콘의 수평 이동 진폭 (기본값: 10.0)


## 예시

```dart
BurstIconButton(
  icon: Icon(Icons.star, color: Colors.grey),
  pressedIcon: Icon(Icons.star, color: Colors.yellow),
  burstIcon: Icon(Icons.star, color: Colors.orange),
  duration: Duration(milliseconds: 1500),
  throttleDuration: Duration(milliseconds: 150),
  crossAmplitude: 15.0,
  onPressed: () {
    print('별 버튼이 눌렸습니다!');
  },
)
```


## 기여

기여는 언제나 환영합니다! 문제가 발생하거나 개선 제안이 있으시면 GitHub 저장소에 이슈를 등록해 주세요.


## 라이선스

이 패키지는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 LICENSE 파일을 참조하세요.
