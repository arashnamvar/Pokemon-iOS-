
import UIKit
import MobileCoreServices
import AVFoundation
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate,
UINavigationControllerDelegate, AVAudioPlayerDelegate, UIImagePickerControllerDelegate {
    
    var session = AVAudioSession.sharedInstance()
    let socket = SocketIOClient(socketURL: "192.168.15.15:8000")

//    var player = [""]
//    var player_id = 1
    var beenHereBefore = false
    var controller: UIImagePickerController?
    var name = ""
    var song_intro = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("129-victory-vs-gym-leader-", ofType: "mp3")!)
    var song = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("107-battle-vs-wild-pokemon-", ofType: "mp3")!)
    var songAudio = AVAudioPlayer()
    var songAudio2 = AVAudioPlayer()
    var data: [String]?
    var id: String?
    var movement: String?
    
    @IBOutlet weak var snapShot: UIImageView!
    @IBOutlet weak var enterNameText: UITextField!
    @IBOutlet weak var txtTest: UITextField! = nil
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBAction func enterName(sender: UIButton) {
        data = []
        id = String(arc4random_uniform(30000));
        data!.append(id!)
        data!.append("USERNAME")
        socket.emit("usercreated", data!)
        nameLabel.text = "Name: \(enterNameText.text)"
        sender.hidden = true
        enterNameText.hidden = true
       txtTest.delegate=self
        name = enterNameText.text
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
     override func viewDidLoad() {
        socket.connect()
        songAudio = AVAudioPlayer(contentsOfURL: song, error: nil)
        songAudio2 = AVAudioPlayer(contentsOfURL: song_intro, error: nil)
        songAudio.prepareToPlay()
        songAudio2.prepareToPlay()
        var error: NSError?
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord,
            error: &error)
        session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: nil)
        songAudio2.numberOfLoops = -1
        songAudio2.play()
        super.viewDidLoad()
        
    }
    
    @IBAction func movement(sender: UIButton) {
        println(sender.tag)
        
        if sender.tag == 1 {
            movement = "up"
            data = nil
            data = []
            data!.append(movement!)
            data!.append(id!)
            socket.emit("movement", data!)
        }
        if sender.tag == 2 {
            movement = "right"
            data = nil
            data = []
            data!.append(movement!)
            data!.append(id!)
            socket.emit("movement", data!)
        }
        if sender.tag == 3 {
            movement = "down"
            data = nil
            data = []
            data!.append(movement!)
            data!.append(id!)
            socket.emit("movement", data!)
        }
        if sender.tag == 4 {
            movement = "left"
            data = nil
            data = []
            data!.append(movement!)
            data!.append(id!)
            socket.emit("movement", data!)
        }

        socket.on("duel") { response, ack in
            println("\(response)")
            if response != nil {
                self.songAudio2.stop()
                self.songAudio.play()
                println(response)
                if let stringArray = response as? [String]? {
                    println("STRING ARRAY")
                }
                if let INTarray = response as? [Int] {
                    println("Int ARRAY")
                }
            }
        }
    }
    
    @IBAction func playPressed(sender: UIButton) {
        
        
    }
    
  func imagePickerController(picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
      let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
      
      if let type:AnyObject = mediaType{
        
        if type is String{
          let stringType = type as! String
          
          if stringType == kUTTypeMovie as! String{
            let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
            if let url = urlOfVideo{
              println("Video URL = \(url)")
            }
          }
            
          else if stringType == kUTTypeImage as! String{
            let metadata = info[UIImagePickerControllerMediaMetadata]
              as? NSDictionary
            if let theMetaData = metadata{
              let image = info[UIImagePickerControllerOriginalImage]
                as? UIImage
              if let theImage = image{
                var imageData = UIImagePNGRepresentation(theImage)
                var base64String = imageData.base64EncodedStringWithOptions(.allZeros)
                snapShot.image = theImage
                socket.emit("photo", base64String)
                socket.on("connect") { data, ack in
                    println("iOS::WE ARE USING SOCKETS!")
                }
              }
            }
          }
          
        }
      }
      
      picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
    @IBAction func sendPhoto(sender: UIButton) {

    }
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    println("Picker was cancelled")
    picker.dismissViewControllerAnimated(true, completion: nil)
  }

  func isCameraAvailable() -> Bool{
    return UIImagePickerController.isSourceTypeAvailable(.Camera)
  }
  
  func cameraSupportsMedia(mediaType: String,
    sourceType: UIImagePickerControllerSourceType) -> Bool{
      
      let availableMediaTypes =
      UIImagePickerController.availableMediaTypesForSourceType(sourceType) as!
        [String]?
      
      if let types = availableMediaTypes{
        for type in types{
          if type == mediaType{
            return true
          }
        }
      }
      return false
  }

  func doesCameraSupportTakingPhotos() -> Bool{
    return cameraSupportsMedia(kUTTypeImage as! String, sourceType: .Camera)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if beenHereBefore{
      return;
    } else {
      beenHereBefore = true
    }
    
    if isCameraAvailable() && doesCameraSupportTakingPhotos(){
      controller = UIImagePickerController()
      if let theController = controller{
        theController.sourceType = .Camera
        theController.mediaTypes = [kUTTypeImage as! String]
        theController.allowsEditing = true
        theController.delegate = self
        
        presentViewController(theController, animated: true, completion: nil)
      }
      
    } else {
      println("Camera is not available")
    }
    
  }
  
}

