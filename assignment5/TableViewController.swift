//
//  TableViewController.swift


import UIKit

class TableViewController: UITableViewController {
    
    
    var dispList: Array<String> = []
    var passList: Array<String> = []
    var name:String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let url = URL(string: "http://bismarck.sdsu.edu/rateme/list")
        {
            let session1 = URLSession.shared
            let task1 = session1.dataTask(with: url, completionHandler: fetchData)
            task1.resume()
        }
        else
        {
            print("Error")
        }
    }
    
    
    
    func fetchData(data:Data?, response:URLResponse?, error:Error?) -> Void {
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
                    for each in jsonResult as! [Dictionary<String, AnyObject>]
                    {
                        name = ""
                        let firstName = each["firstName"] as! String
                        let lastName = each["lastName"] as! String
                        name = firstName + " " + lastName
                        dispList.append(String(name))
                    }
                    self.tableView.reloadData()
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
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dispList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.textLabel?.text = dispList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "segueid", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let passingValue = segue.destination as! DetailViewController
        passingValue.passedValue = sender as! Int
    }
}
