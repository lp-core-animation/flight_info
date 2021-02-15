import UIKit
import QuartzCore

// A delay function
func delay(seconds: Double, completion: @escaping ()-> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

class ViewController: UIViewController {

  @IBOutlet var bgImageView: UIImageView!
  
  @IBOutlet var summaryIcon: UIImageView!
  @IBOutlet var summary: UILabel!
  
  @IBOutlet var flightNr: UILabel!
  @IBOutlet var gateNr: UILabel!
  @IBOutlet var departingFrom: UILabel!
  @IBOutlet var arrivingTo: UILabel!
  @IBOutlet var planeImage: UIImageView!
  
  @IBOutlet var flightStatus: UILabel!
  @IBOutlet var statusBanner: UIImageView!
  
  var snowView: SnowView!

  enum AnimationDirection: Int {
    case positive = 1
    case negative = -1
  }
  
  //MARK: view controller methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //adjust ui
    summary.addSubview(summaryIcon)
    summaryIcon.center.y = summary.frame.size.height/2
    
    //add the snow effect layer
    snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
    let snowClipView = UIView(frame: view.frame.offsetBy(dx: 0, dy: 50))
    snowClipView.clipsToBounds = true
    snowClipView.addSubview(snowView)
    view.addSubview(snowClipView)
    
    //start rotating the flights
    changeFlight(to: londonToParis)
  }
  
  //MARK: custom methods

  func cubeTransition(label: UILabel, text: String, direction: AnimationDirection) {
    let auxLabel = UILabel(frame: label.frame)
    auxLabel.text = text
    auxLabel.font = label.font
    auxLabel.textAlignment = label.textAlignment
    auxLabel.textColor = label.textColor
    auxLabel.backgroundColor = label.backgroundColor

    let auxLabelOffset = CGFloat(direction.rawValue) * label.frame.size.height / 2
    auxLabel.transform = CGAffineTransform(translationX: 0.0, y: auxLabelOffset)
      .scaledBy(x: 1.0, y: 0.1)

    label.superview?.addSubview(auxLabel)

    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      auxLabel.transform = .identity
      label.transform = CGAffineTransform(translationX: 0.0, y: -auxLabelOffset)
        .scaledBy(x: 1.0, y: 0.1)
    }, completion: { _ in
      label.text = auxLabel.text
      label.transform = .identity
      auxLabel.removeFromSuperview()
    })
  }
  
  func changeFlight(to data: FlightData, animated: Bool = false) {
    
    // populate the UI with the next flight's data
    summary.text = data.summary
    flightStatus.text = data.flightStatus
    if animated {
      fade(imageView: bgImageView,
        toImage: UIImage(named: data.weatherImageName)!,
        showEffects: data.showWeatherEffects)

      let direction: AnimationDirection = data.isTakingOff ? .positive : .negative
      cubeTransition(label: flightNr, text: data.flightNr, direction: direction)
    } else {
      bgImageView.image = UIImage(named: data.weatherImageName)
      snowView.isHidden = !data.showWeatherEffects
      flightNr.text = data.flightNr
      gateNr.text = data.gateNr
      departingFrom.text = data.departingFrom
      arrivingTo.text = data.arrivingTo
    }
    
    // schedule next flight
    delay(seconds: 3.0) {
      self.changeFlight(to: data.isTakingOff ? parisToRome : londonToParis, animated: true)
    }
  }

  func fade(imageView: UIImageView, toImage: UIImage,
            showEffects: Bool) {
    UIView.transition(with: imageView, duration: 1.0,
      options: .transitionCrossDissolve,
      animations: {
        imageView.image = toImage
      },
      completion: nil
    )
    UIView.animate(withDuration: 1.0, delay: 0.0,
      options: .curveEaseOut,
      animations: {
        self.snowView.alpha = showEffects ? 1.0 : 0.0
      },
      completion: nil
    )
  }

}
