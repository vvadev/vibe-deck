<a id="readme-top"></a>

**Язык:** [English](README.md) | [Русский](README.ru.md)

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![License][license-shield]][license-url]
[![GitHub][github-shield]][github-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/vvadev/vibe-deck">
    <img src="mobile_app/assets/vibe-deck-logo.png" alt="Логотип Vibe Deck" width="120" height="120">
  </a>

  <h3 align="center">Vibe Deck</h3>

  <p align="center">
    Виртуальный Stream Deck для vibe-coding: мобильное приложение превращает телефон в программируемую панель, десктопное приложение принимает и выполняет действия.
    <br />
    <br />
    <a href="https://github.com/vvadev/vibe-deck">Открыть репозиторий</a>
    &middot;
    <a href="https://github.com/vvadev/vibe-deck/issues/new?labels=bug">Сообщить о баге</a>
    &middot;
    <a href="https://github.com/vvadev/vibe-deck/issues/new?labels=enhancement">Предложить улучшение</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Содержание</summary>
  <ol>
    <li>
      <a href="#about-the-project">О проекте</a>
      <ul>
        <li><a href="#built-with">Технологии</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Быстрый старт</a>
      <ul>
        <li><a href="#prerequisites">Требования</a></li>
        <li><a href="#installation">Установка</a></li>
      </ul>
    </li>
    <li><a href="#usage">Использование</a></li>
    <li><a href="#roadmap">Планы</a></li>
    <li><a href="#contributing">Вклад</a></li>
    <li><a href="#license">Лицензия</a></li>
    <li><a href="#contact">Контакты</a></li>
    <li><a href="#acknowledgments">Благодарности</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]][screenshots-url] -->

Vibe Deck состоит из двух Flutter-приложений для управления действиями на компьютере с телефона в локальной сети:

* `mobile_app` (iOS/Android) сканирует хосты в LAN, выполняет pairing с десктопом по одноразовому коду, отображает настраиваемую деку (до 24 кнопок) и отправляет триггеры кнопок.
* `desktop_app` (macOS/Windows/Linux) поднимает WebSocket API (`ws://<host>:4040/ws`), валидирует pairing/сессии и выполняет разрешенные действия (`insert_text`, `hotkey`, `run_action`).
* Профиль деки нормализуется и синхронизируется с десктопа на мобильный через `deck_state`; обязательная заблокированная кнопка `Enter` присутствует всегда.

Ссылка на логотип PNG: [mobile_app/assets/vibe-deck-logo.png](https://github.com/vvadev/vibe-deck/blob/main/mobile_app/assets/vibe-deck-logo.png)

Плейсхолдеры под скриншоты:
* `docs/screenshots/overview.png` (общий вид интерфейса)
* `docs/screenshots/mobile-deck.png` (вкладка Deck на телефоне)
* `docs/screenshots/desktop-actions.png` (вкладка действий на десктопе)

Этот README описывает запуск и использование обеих частей проекта.

<p align="right">(<a href="#readme-top">наверх</a>)</p>

### Built With

* [![Flutter][Flutter.dev]][Flutter-url]
* [![Dart][Dart.dev]][Dart-url]
* [![Provider][Provider.dev]][Provider-url]
* [![WebSocket][WebSocket.dev]][WebSocket-url]
* [![Material][Material.dev]][Material-url]

<p align="right">(<a href="#readme-top">наверх</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

Ниже минимальные шаги для локального запуска desktop host и mobile controller.

### Prerequisites

* Flutter SDK с Dart `^3.9.2` (stable)
  ```sh
  flutter --version
  ```
* Установленные toolchain под целевые платформы:
  * Xcode для iOS/macOS
  * Android SDK для Android
  * Visual Studio (Desktop C++) для Windows
  * CMake + GTK для Linux desktop Flutter

### Installation

1. Клонируйте репозиторий
   ```sh
   git clone https://github.com/vvadev/vibe-deck.git
   cd vibe-deck
   ```
2. Установите зависимости desktop app
   ```sh
   cd desktop_app
   flutter pub get
   ```
3. Установите зависимости mobile app
   ```sh
   cd ../mobile_app
   flutter pub get
   ```
4. (Опционально) Проверьте окружение
   ```sh
   flutter doctor
   ```
5. Проверьте `origin`:
   ```sh
   git remote -v
   ```

<p align="right">(<a href="#readme-top">наверх</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

1. Запустите desktop host:
   ```sh
   cd desktop_app
   flutter run -d macos
   ```
   Для других платформ используйте `-d windows` или `-d linux`.

2. Запустите mobile controller:
   ```sh
   cd mobile_app
   flutter run -d ios
   ```
   Для Android используйте `-d android`.

3. Pairing flow:
   * Откройте desktop app и скопируйте pair code.
   * В mobile app откройте вкладку Connect, найдите хост или введите host/IP вручную.
   * Введите pair code и подключитесь.
   * Откройте вкладку Deck и нажимайте кнопки.

4. Безопасность и поведение:
   * Перед pairing обязателен `hello` handshake с challenge.
   * Для `trigger` и `health_ping` требуется валидный session token.
   * Попытки pairing ограничиваются rate limit и могут временно блокироваться.
   * `run_action` выполняет только allowlist-действия на десктопе; shell-режим по умолчанию выключен.

Полезные файлы:
* `/desktop_app/lib/src/app_state.dart`
* `/desktop_app/lib/src/executor.dart`
* `/mobile_app/lib/src/data/ws_client.dart`
* `/mobile_app/lib/src/data/discovery_service.dart`

<p align="right">(<a href="#readme-top">наверх</a>)</p>

<!-- ROADMAP -->
## Roadmap

- [x] LAN discovery и pairing
- [x] Синхронизация состояния деки между desktop и mobile
- [x] Allowlist действий на desktop
- [x] Runtime-логи и permission toggles
- [ ] Добавить `wss://` и обработку сертификатов
- [ ] Улучшить нативные адаптеры hotkey/text input для платформ
- [ ] Добавить более подробный onboarding и troubleshooting UI

Список задач: [open issues](https://github.com/vvadev/vibe-deck/issues).

<p align="right">(<a href="#readme-top">наверх</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Вклад в проект приветствуется.

1. Fork репозитория
2. Создайте ветку (`git checkout -b feature/AmazingFeature`)
3. Закоммитьте изменения (`git commit -m 'Add some AmazingFeature'`)
4. Запушьте ветку (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

### Top contributors:

<a href="https://github.com/vvadev/vibe-deck/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=vvadev/vibe-deck" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">наверх</a>)</p>

<!-- LICENSE -->
## License

В репозитории пока нет явного файла лицензии. Добавьте `LICENSE`, чтобы зафиксировать условия распространения.

<p align="right">(<a href="#readme-top">наверх</a>)</p>

<!-- CONTACT -->
## Contact

Vladimir Versinin - [@vvadev](https://github.com/vvadev)

Ссылка на проект: [https://github.com/vvadev/vibe-deck](https://github.com/vvadev/vibe-deck)

<p align="right">(<a href="#readme-top">наверх</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Flutter documentation](https://docs.flutter.dev/)
* [Dart language documentation](https://dart.dev/guides)
* [Material Design](https://m3.material.io/)
* [Shields.io](https://shields.io)
* [Best README Template](https://github.com/othneildrew/Best-README-Template)

<p align="right">(<a href="#readme-top">наверх</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/vvadev/vibe-deck.svg?style=for-the-badge
[contributors-url]: https://github.com/vvadev/vibe-deck/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/vvadev/vibe-deck.svg?style=for-the-badge
[forks-url]: https://github.com/vvadev/vibe-deck/network/members
[stars-shield]: https://img.shields.io/github/stars/vvadev/vibe-deck.svg?style=for-the-badge
[stars-url]: https://github.com/vvadev/vibe-deck/stargazers
[issues-shield]: https://img.shields.io/github/issues/vvadev/vibe-deck.svg?style=for-the-badge
[issues-url]: https://github.com/vvadev/vibe-deck/issues
[license-shield]: https://img.shields.io/github/license/vvadev/vibe-deck.svg?style=for-the-badge
[license-url]: https://github.com/vvadev/vibe-deck/blob/main/LICENSE
[github-shield]: https://img.shields.io/badge/GitHub-vvadev-181717?style=for-the-badge&logo=github
[github-url]: https://github.com/vvadev
[product-screenshot]: docs/screenshots/overview.png
[screenshots-url]: https://github.com/vvadev/vibe-deck/tree/main/docs/screenshots
[Flutter.dev]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[Flutter-url]: https://flutter.dev
[Dart.dev]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[Dart-url]: https://dart.dev
[Provider.dev]: https://img.shields.io/badge/Provider-42A5F5?style=for-the-badge
[Provider-url]: https://pub.dev/packages/provider
[WebSocket.dev]: https://img.shields.io/badge/WebSocket-Protocol-0A0A0A?style=for-the-badge
[WebSocket-url]: https://datatracker.ietf.org/doc/html/rfc6455
[Material.dev]: https://img.shields.io/badge/Material%203-757575?style=for-the-badge
[Material-url]: https://m3.material.io
