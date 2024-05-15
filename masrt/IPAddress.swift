import Foundation

class ValidIPAddress {
    
    func isValidIPAddress(_ ip: String) -> Bool {
        
        if(isValidIPv4(ip) || isValidIPv6(ip)){
            return true
        } else {
            return false
        }
    }
    
    private func isValidIPv4(_ ip: String) -> Bool {
        let parts = ip.components(separatedBy: ".")
        
        if(parts.count != 4) { return false }
        
        for part in parts {
            var tmp = 0
            if(part.count > 3 || part.count < 1){
                return false
            }
            
            for char in part {
                if(char < "0" || char > "9"){
                    return false
                }
                
                tmp = tmp * 10 + Int(String(char))!
            }
            
            if(tmp < 0 || tmp > 255){
                return false
            }
            
            if((tmp > 0 && part.first == "0") || (tmp == 0 && part.count > 1)){
                return false
            }
        }
        
        
        return true
    }
    
    private func isValidIPv6(_ ip: String) -> Bool {
        let parts = ip.components(separatedBy: ":")
        if(parts.count != 8){
            return false
        }
        
        for part in parts {
            if(part.count > 4 || part.count < 1){
                return false;
            }
            
            for char in part.lowercased() {
                if((char < "0" || char > "9") && (char < "a" || char > "f")){
                    return false
                }
            }
        }
        
        
        
        return true
    }
}
