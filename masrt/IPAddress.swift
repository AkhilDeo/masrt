//==============================================================================
/*
#     Software License Agreement (BSD License)
#     Copyright (c) 2024 Akhil Deo <adeo1@jhu.edu>


#     All rights reserved.

#     Redistribution and use in source and binary forms, with or without
#     modification, are permitted provided that the following conditions
#     are met:

#     * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.

#     * Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.

#     * Neither the name of authors nor the names of its contributors may
#     be used to endorse or promote products derived from this software
#     without specific prior written permission.

#     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#     "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#     LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#     FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#     COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#     INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#     BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#     CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#     LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#     ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#     POSSIBILITY OF SUCH DAMAGE.


#     \author    <adeo1@jhu.edu>
#     \author    Akhil Deo
#     \version   1.0
# */
//==============================================================================

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
