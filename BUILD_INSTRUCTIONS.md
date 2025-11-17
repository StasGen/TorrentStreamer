# Build Instructions for TorrentStreamer

## Решение проблемы с libarclite

Если вы получаете ошибку:
```
SDK does not contain 'libarclite' at the path '/Applications/Xcode-16.4.0.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/arc/libarclite_iphonesimulator.a'; try increasing the minimum deployment target
```

Эта проблема возникает при использовании новых версий Xcode (16.x) со старыми CocoaPods зависимостями.

## Исправления, которые были применены:

### 1. Обновлен Podfile
- Добавлен минимальный deployment target: `platform :ios, '12.0'`
- Добавлен post_install скрипт для принудительного обновления deployment target всех подов
- Исключена архитектура arm64 для симулятора

### 2. Post-install скрипт
```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        end
    end
end
```

## Инструкции по сборке:

1. Убедитесь, что у вас установлен CocoaPods:
   ```bash
   gem install cocoapods
   ```

2. Установите зависимости:
   ```bash
   pod install
   ```

3. Откройте проект в Xcode используя **workspace файл**:
   ```bash
   open grabber.xcworkspace
   ```
   
   ⚠️ **Важно**: Используйте `.xcworkspace`, а не `.xcodeproj`!

4. Выберите целевое устройство или симулятор

5. Нажмите Cmd+B для сборки или Cmd+R для запуска

## Установленные зависимости:

- **PopcornTorrent** (1.3.15) - для работы с торрентами
- **MobileVLCKit** (3.3.17) - медиаплеер
- **Kanna** (5.2.7) - HTML парсер
- **GCDWebServer** (3.5.4) - веб-сервер (зависимость PopcornTorrent)

## Требования:

- iOS 12.0+
- Xcode 12.0+
- Swift 5.0+

## Возможные проблемы:

1. **Ошибка libarclite**: Решена обновлением deployment target
2. **Проблемы с симулятором на M1 Mac**: Исключена архитектура arm64 для симулятора
3. **Старые версии подов**: Принудительно обновлен deployment target через post_install

Если у вас все еще возникают проблемы, попробуйте:
```bash
pod deintegrate
pod install
```