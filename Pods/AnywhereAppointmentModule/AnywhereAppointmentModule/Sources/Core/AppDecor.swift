//
//  AppDecor.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 07.08.2021.
//

import UIKit

enum AppDecor {
    enum MainColors {
        static let anytimeSolidBlue = UIColor.appColor(.anytimeSolidBlue)
        static let anytimeLightBlue = UIColor.appColor(.anytimeLightBlue)
        static let anytimeWhite = UIColor.appColor(.anytimeWhite)
        static let anytimeOrange = UIColor.appColor(.anytimeOrange)
        static let anytimeBrown = UIColor.appColor(.anytimeBrown)
    }
    
    struct BorderColors {
        static let whiteBorder = UIColor.appColor(.whiteBorder)
        static let blueBorder = UIColor.appColor(.blueBorder)
    }
    
    struct NavBarIcons {
        static let hamburgerMenu = UIImage(named: "Hamburger menu")
        static let downArrow = UIImage(named: "DownArrow")
        static let currentDate = UIImage(named: "Current date")
        static let addNew = UIImage(named: "Add new")
        static let upArrow = UIImage(named: "UpArrow")
//        static let backArrow = UIImage(named: "common_back_arrow")
        static let backArrow = UIImage(named: "common_back_arrow",from: .init(for: EventViewSDK.self))
    }
    
    enum Icons {
//        static let selectedCell = UIImage(named: "SelectedCell")
//        static let unselectedCell = UIImage(named: "UnselectedCell")
        static let selectedCell = UIImage(named: "SelectedCell", from: .init(for: EventViewSDK.self))
        static let unselectedCell = UIImage(named: "UnselectedCell", from: .init(for: EventViewSDK.self))
        
        static let searchIcon = UIImage(named: "Search")
        static let grayRightArrow = UIImage(named: "rightArrow")
        static let textFieldIcon = UIImage(named: "EventNameIcon")
        static let startTime = UIImage(named: "StartTimeIcon")
        static let endTime = UIImage(named: "EndTimeIcon")

        static let accepted = UIImage(named: "accepted")
        static let declined = UIImage(named: "cancelled")
        static let pending = UIImage(named: "pending")
        static let locationIcon = UIImage(named: "LocationIcon")
        
        static let addNotifications_inactive = UIImage(named: "AddNotificationsIcon-Inactive")
        static let repeatIcon = UIImage(named: "RepeatIcon")
        static let timezone = UIImage(named: "TimeZoneIcon")
        static let dateTime = UIImage(named: "DateTimeIcon")
        static let addGuests_active = UIImage(named: "AddGuests-Active")
        static let tickCircle = UIImage(named: "tickCircle")
        static let crossCircle = UIImage(named: "close")
        static let setmoreEvent = UIImage(named: "event_setmore")
        static let inviteNewPerson = UIImage(named: "InviteNewPerson")
        
        struct Login {
            static let google = UIImage(named: "google_icon")
            static let microsoft = UIImage(named: "office_365_icon")
        }
    }
    
    struct CardColors {
        static let lightCeruleanBlue = UIColor.appColor(.lightCeruleanBlue)
        static let lightSeaGreen = UIColor.appColor(.lightSeaGreen)
        static let lightSlateBlue = UIColor.appColor(.lightSlateBlue)
        static let ceruleanBlue = UIColor.appColor(.ceruleanBlue)
        static let burntSienna = UIColor.appColor(.burntSienna)
        static let cornFlower = UIColor.appColor(.cornFlower)
        static let steelBlue = UIColor.appColor(.steelBlue)
        static let tapestry = UIColor.appColor(.tapestry)
        static let sun = UIColor.appColor(.sun)
        static let fern = UIColor.appColor(.fern)
        static let puce = UIColor.appColor(.puce)
        static let mandy = UIColor.appColor(.mandy)
        static let bronco = UIColor.appColor(.bronco)
        static let scampi = UIColor.appColor(.scampi)
        static let sinbad = UIColor.appColor(.sinbad)
        static let concord = UIColor.appColor(.concord)
        static let negroni = UIColor.appColor(.negroni)
        static let saffron = UIColor.appColor(.saffron)
        static let seagull = UIColor.appColor(.seagull)
        static let flamingo = UIColor.appColor(.flamingo)
    }
    
    struct Fonts {

        static let semiBold: UIFont = {
            guard let semiBoldFont = UIFont.Metropolis(.semibold, size: 13) else {
//                assertionFailure("Missing SemiBold font asset")
                return UIFont.boldSystemFont(ofSize: 13)
            }
            return semiBoldFont
        }()

        static let medium: UIFont = {
            guard let mediumFont = UIFont.Metropolis(.medium, size: 15) else {
//                assertionFailure("Missing Medium font asset")
                return UIFont.systemFont(ofSize: 13)
            }
            return mediumFont
        }()

        static let bold: UIFont = {
            guard let boldFont = UIFont.Metropolis(.bold, size: 15) else {
//                assertionFailure("Missing Bold font asset")
                return UIFont.systemFont(ofSize: 13)
            }
            return boldFont
        }()

        static let regular: UIFont = {
            guard let regular = UIFont.Metropolis(.regular, size: 15) else {
//                assertionFailure("Missing Regular font asset")
                return UIFont.systemFont(ofSize: 13)
            }
            return regular
        }()

        static let H1: UIFont = Fonts.semiBold.withSize(36)

        static let H2: UIFont = Fonts.semiBold.withSize(22)

        static let H3: UIFont = Fonts.semiBold.withSize(17)

        static let body = Fonts.medium.withSize(15)
        static let small = Fonts.medium.withSize(13)
        static let verySmall = Fonts.medium.withSize(11)
    }
}

struct AnytimeNibs {
    
    static var eventBaseNavigation: EventBaseNavigationController {
        let storyboard = UIStoryboard(name: "Events", bundle: .init(for: EventViewSDK.self))
        guard let vc = storyboard.instantiateViewController(withIdentifier: "EventBaseNavigationController") as? EventBaseNavigationController else {
            fatalError("AnytimeNibs does not have eventBaseNavigation")
        }
        return vc
    }
    
    static var eventBaseTableView: EventBaseTableViewController {
        let storyboard = UIStoryboard(name: "Events", bundle: .init(for: EventViewSDK.self))
        guard let vc = storyboard.instantiateViewController(withIdentifier: "EventBaseTableViewController") as? EventBaseTableViewController else {
            fatalError("AnytimeNibs does not have EventBaseTableViewController")
        }
        return vc
    }
    
    static var eventDateCell: EventDateCell {
        let cell = EventDateCell.loadFromNib()
        return cell
    }

    static var eventTitleCell: EventTitleDescriptionCell {
        let cell = EventTitleDescriptionCell.loadFromNib()
        return cell
    }
    
    static var textViewCell: TextViewCell {
        let cell = TextViewCell.loadFromNib()
        return cell
    }
    static var textFieldWithImage: TextFieldWithImageCell {
        let cell = TextFieldWithImageCell.loadFromNib()
        return cell
    }
    static var eventLinkCell: EventLinkCell {
        let cell = EventLinkCell.loadFromNib()
        return cell
    }
    static var guestCell: UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    static var hostButtonView: HostButtonView {
        let view = HostButtonView.loadFromNib()
        return view
    }
    
    static var nonHostButtonView: NonHostButtonView {
        let view = NonHostButtonView.loadFromNib()
        return view
    }
    
    static var frequencySelectionCell: FrequencySelectionCell {
        let cell = FrequencySelectionCell.loadFromNib()
        return cell
    }
    
    static var iconIndicatorTableViewCell: IconIndicatorTableViewCell {
        let cell = IconIndicatorTableViewCell.loadFromNib()
        return cell
    }
    
    static var yearControl: YearlyControl {
        let yearlyControl = YearlyControl.loadFromNib()
        return yearlyControl
    }
    
    static var weekControl: WeekControl {
        let weekControl = WeekControl()
        return weekControl
    }
    
    static var monthlyControl: MonthlyControl {
        let control = MonthlyControl.loadFromNib()
        return control
    }
    
    static var customRepeatCell: CustomRepeatRecurrencyCell {
        let cell = CustomRepeatRecurrencyCell.loadFromNib()
        return cell
    }
    
    static var titleSubtitleIndicatorCell: TitleSubtitleIndicatorCell {
        let cell = TitleSubtitleIndicatorCell.loadFromNib()
        return cell
    }
}

extension AppDecor {
    
    static var getRandomColor: UIColor? {
        let setOfColours: Set<UIColor?> = [MainColors.anytimeLightBlue, CardColors.fern, CardColors.bronco]
        return setOfColours.randomElement() ?? UIColor.white
    }
    
    static func getColor(forCharacter char: Character) -> UIColor {
        
        var colorId: Int = 10
        if char.isLetter {
            if let lowerCaseIndex = [
                "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
                ].firstIndex(of: char) {
                colorId = lowerCaseIndex
            } else if let upperCaseIndex = [
                "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
                ].firstIndex(of: char) {
                colorId = upperCaseIndex
            }
        } else if char.isNumber, let number = Int(char.lowercased()) {
            colorId = number
        } else if char.isSymbol {
            colorId = 5
        }
        return AppDecor.getCardColor(forCode: colorId) ?? UIColor.green
    }
    
    static func getCardColor(forCode code: Int) -> UIColor? {
        switch code % 20 {
        case 0: return AppDecor.CardColors.steelBlue
        case 1: return AppDecor.CardColors.fern
        case 2: return AppDecor.CardColors.concord
        case 3: return AppDecor.CardColors.cornFlower
        case 4: return AppDecor.CardColors.tapestry
        case 5: return AppDecor.CardColors.scampi
        case 6: return AppDecor.CardColors.sinbad
        case 7: return AppDecor.CardColors.ceruleanBlue
        case 8: return AppDecor.CardColors.burntSienna
        case 9: return AppDecor.CardColors.seagull
        case 10: return AppDecor.CardColors.negroni
        case 11: return AppDecor.CardColors.lightCeruleanBlue
        case 12: return AppDecor.CardColors.bronco
        case 13: return AppDecor.CardColors.saffron
        case 14: return AppDecor.CardColors.flamingo
        case 15: return AppDecor.CardColors.puce
        case 16: return AppDecor.CardColors.lightSeaGreen
        case 17: return AppDecor.CardColors.sun
        case 18: return AppDecor.CardColors.lightSlateBlue
        case 19: return AppDecor.CardColors.mandy
        default: return AppDecor.MainColors.anytimeLightBlue
        }
    }
}

extension UIImage {
    convenience init?(named: String, from bundle: Bundle) {
        let bundleURL = bundle.resourceURL?.appendingPathComponent("AnywhereAppointmentModule.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        self.init(named: named, in: resourceBundle, compatibleWith: nil)
    }
}

public class CustomFonts: NSObject {

  // Lazy var instead of method so it's only ever called once per app session.
  public static var loadFonts: () -> Void = {
    let fontNames = UIFont.MetropolisType.allCases.map { $0.metropolisName() }
    for fontName in fontNames {
      loadFont(withName: fontName)
    }
    return {}
  }()

  private static func loadFont(withName fontName: String) {
    let bundle = Bundle(for: EventViewSDK.self)
    guard let fontURL = bundle.url(forResource: fontName, withExtension: "otf"),
          let fontData = try? Data(contentsOf: fontURL) as CFData,
          let provider = CGDataProvider(data: fontData),
          let font = CGFont(provider) else {
        Logger.info("Fonts are not loaded")
        return
    }
    CTFontManagerRegisterGraphicsFont(font, nil)
  }
}
