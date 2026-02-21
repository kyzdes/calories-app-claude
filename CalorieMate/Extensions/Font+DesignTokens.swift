import SwiftUI

extension Font {

    // MARK: - Headlines

    /// SF Pro Rounded 48pt Bold — число калорий в круговом прогрессе
    static let cmHero: Font = .system(size: 48, weight: .bold, design: .rounded)

    /// 28pt Bold — заголовки экранов
    static let cmH1: Font = .system(size: 28, weight: .bold)

    /// 22pt Semibold — заголовки секций
    static let cmH2: Font = .system(size: 22, weight: .semibold)

    /// 18pt Semibold — заголовки карточек
    static let cmH3: Font = .system(size: 18, weight: .semibold)

    // MARK: - Body

    /// 16pt Regular — основной текст
    static let cmBody: Font = .system(size: 16, weight: .regular)

    /// 16pt Semibold — акцентный текст
    static let cmBodyBold: Font = .system(size: 16, weight: .semibold)

    /// 15pt Regular — подписи, вторичная информация
    static let cmCallout: Font = .system(size: 15, weight: .regular)

    // MARK: - Captions

    /// 13pt Regular — мелкие подписи, timestamps
    static let cmCaption: Font = .system(size: 13, weight: .regular)

    /// 11pt Regular — третичная информация
    static let cmCaption2: Font = .system(size: 11, weight: .regular)

    // MARK: - Numbers

    /// SF Pro Rounded 32pt Bold — крупные числа (БЖУ суммы)
    static let cmNumberLg: Font = .system(size: 32, weight: .bold, design: .rounded)

    /// SF Pro Rounded 20pt Semibold — числа в карточках продуктов
    static let cmNumberMd: Font = .system(size: 20, weight: .semibold, design: .rounded)

    /// 14pt Medium — граммовки, мелкие цифры
    static let cmNumberSm: Font = .system(size: 14, weight: .medium)
}
