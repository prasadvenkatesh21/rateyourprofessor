//
//  DetailViewController.swift


import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource{
    
    var passedValue = 0
    let id = 0
    var jsonDictionary2:Dictionary<String, AnyObject> = [:]
    var commentArray:Array<String> = []
    
    
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var officeLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var averageRatingLabel: UILabel!
    @IBOutlet var totalRatingLabel: UILabel!
    @IBOutlet var ratingText: UITextField!
    @IBOutlet var commentsText: UITextField!
    
    @IBOutlet var commentTable: UITableView!
    
    @IBAction func submitPressed(_ sender: Any)
    
    {
        
        if ratingText != nil && ratingText.text?.characters.count != 0
        {
        if Int(ratingText.text!)! >= 1 && Int(ratingText.text!)! <= 5
        {
            print(ratingText.text!)
            let urlRating = "http://bismarck.sdsu.edu/rateme/rating/"+String(self.passedValue+1)+"/"+ratingText.text!
            var request = URLRequest(url: URL(string: urlRating)!)
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else
                {
                    print("Error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
                {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
            }
            task.resume()
        }
        }
        if commentsText != nil
        {
            let urlComments = "http://bismarck.sdsu.edu/rateme/comment/"+String(self.passedValue+1)
            print(urlComments)
            var request = URLRequest(url: URL(string: urlComments)!)
            request.httpMethod = "POST"
            let postString = commentsText.text
            request.httpBody = postString?.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
                {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
            }
            task.resume()
        }

        commentsText.text = ""
        ratingText.text = ""
        dismissKeyboard()
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let id = String(passedValue + 1)
        let urlStr = "http://bismarck.sdsu.edu/rateme/instructor/"+id
        if let url = URL(string: urlStr) {
            let session1 = URLSession.shared
            let task1 = session1.dataTask(with: url, completionHandler: fetchPage)
            task1.resume()
        }
        else
        {
            print("Error")
        }
        
        let urlStr1 = "http://bismarck.sdsu.edu/rateme/comments/"+id
        if let url1 = URL(string: urlStr1) {
            let session2 = URLSession.shared
            let task2 = session2.dataTask(with: url1, completionHandler: fetchPage1)
            task2.resume()
        }
        else
        {
            print("Error")
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        commentTable.dataSource = self
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
   

    

    
    func fetchPage(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        if error != nil
        {
            print("Error: \(error!.localizedDescription)")
            return
        }
        if data != nil
        {
            if let json = String(data: data!, encoding: String.Encoding.utf8)
            {
                let jsonData:Data? = json.data(using: String.Encoding.utf8)
                do
                {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData!)
                    jsonDictionary2 = (jsonResult as! NSDictionary) as! Dictionary<String, AnyObject>
                    DispatchQueue.main.async{
                    self.firstNameLabel.text = self.jsonDictionary2["firstName"] as? String
                    self.lastNameLabel.text = self.jsonDictionary2["lastName"] as? String
                    self.officeLabel.text = self.jsonDictionary2["office"] as? String
                    self.phoneLabel.text = self.jsonDictionary2["phone"] as? String
                    self.emailLabel.text = self.jsonDictionary2["email"] as? String
                    if let rating = self.jsonDictionary2["rating"] as? Dictionary<String, AnyObject>
                    {
                        self.averageRatingLabel.text = "\(rating["average"]!)"
                        self.totalRatingLabel.text = "\(rating["totalRatings"]!)"
                        }
                    }
                    }
                    
                catch
                {
                    print("Error is fetching JSON data")
                }
            }
            else
            {
                print("Error in convertion JSON data to text")
            }
        }
    }
    
    
    func fetchPage1 (data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        if error != nil
        {
            print("Error: \(error!.localizedDescription)")
            return
        }
        if data != nil
        {
            if let json1 = String(data: data!, encoding: String.Encoding.utf8)
            {
                let jsonData1:Data? = json1.data(using: String.Encoding.utf8)
                do
                {
                    let jsonResult1 = try JSONSerialization.jsonObject(with: jsonData1!)
                    for each in jsonResult1 as! [Dictionary<String, AnyObject>]
                    {

                        let comments = each["text"] as! String
                        commentArray.append(comments)
                        
                    }
                    commentTable.reloadData()
                    
                }
                    
                catch
                {
                    print("Error is fetching JSON data")
                }
            }
            else
            {
                print("Error in convertion JSON data to text")
            }
        }
    }

    
    
    
    
    
    func moveViewText(textField: UITextField, moveDistance: Int, up:Bool)
    {
        let timegap = 0.5
        let movement:CGFloat = CGFloat(up ? moveDistance: -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(timegap)
        self.view.frame = self.view.frame.offsetBy(dx: 0 , dy: movement)
        UIView.commitAnimations()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        moveViewText(textField: ratingText, moveDistance: -100, up: true)
        moveViewText(textField: commentsText, moveDistance: -100, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        moveViewText(textField: ratingText, moveDistance: -100, up: false)
        moveViewText(textField: commentsText, moveDistance: -100, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    
     func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return commentArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.textLabel?.text = commentArray[indexPath.row]
        return cell
    }

}


