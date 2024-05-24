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

import UIKit

import UIKit

protocol VerticalSliderDelegate {
    func thumbReachedDestination()
    func thumbCurrentPosition(_ position:CGFloat)
}

@IBDesignable
class VerticalSlider: UIView  {

    var delegate: VerticalSliderDelegate?

    @IBOutlet weak fileprivate var sliderPath: UIView!
    @IBOutlet weak fileprivate var thumb: UIView!
    @IBOutlet weak fileprivate var destination: UIView!
    @IBOutlet weak fileprivate var thumbTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var panGesture: UIPanGestureRecognizer!

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }


    var contentView: UIView?
    var initialTopConstraint: CGFloat = 0.0

    var isDestinationReached: Bool {
        get {
            let distanceFromDestination: CGFloat = self.destination.center.y - self.thumb.center.y
            return distanceFromDestination < 1
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        arrangeView()
    }

    func arrangeView() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
        contentView = view
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: VerticalSlider.self), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    override func didMoveToWindow() {
        //ensure thumb always start from top
        self.thumbTopConstraint.constant = 0
        self.initialTopConstraint = self.thumbTopConstraint.constant;
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        arrangeView()
        contentView?.prepareForInterfaceBuilder()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        arrangeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //pan action defined in xib
    @IBAction func panAction() {
        if panGesture.state == .changed {
            slideThumb()
            delegate?.thumbCurrentPosition(self.thumb.center.y)
        }
        else if panGesture.state == .ended {
            if isDestinationReached {
                delegate?.thumbReachedDestination()
            }
            else {
                returnInitialLocationAnimated(true)
            }
        }
    }
    
    func slideThumb() {
        
        let minY = CGFloat(0)
        let maxY = sliderPath.bounds.size.height - thumb.bounds.size.height
        
        var translation =  panGesture.translation(in: sliderPath)
        var draggedDistance = thumbTopConstraint.constant + translation.y

        // to prevent going up from path bounds
        if draggedDistance < 0 {
            draggedDistance = minY
            translation.y += thumbTopConstraint.constant - minY
        }
        // to prevent going down from path bounds
        else if draggedDistance > maxY {
            draggedDistance = maxY
            translation.y += thumbTopConstraint.constant - maxY
        }
        else {
            translation.y = 0
        }
        
        self.thumbTopConstraint.constant = draggedDistance
        self.panGesture.setTranslation(translation, in: sliderPath)
        
        UIView.animate( withDuration: 0.05, delay: 0, options: .beginFromCurrentState, animations: {
                self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func returnInitialLocationAnimated(_ animated: Bool) {
        thumbTopConstraint.constant = initialTopConstraint
        
        if (animated) {
            UIView.animate( withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                    self.layoutIfNeeded()
                    self.delegate?.thumbCurrentPosition(self.thumb.center.y)
            }, completion: nil)
        }
    }
}
