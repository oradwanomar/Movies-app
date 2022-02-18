//
//  MovieTableViewController.swift
//  movies
//
//  Created by Omar Ahmed on 02/02/2022.
//

import UIKit
import Alamofire
import SDWebImage
import Reachability
import Cosmos
import CoreData

class MovieTableViewController: UITableViewController{

    var arrMovies:[Movie]=[]
    var arrayMovies:[MovieData]=[]
    let reachability = try! Reachability()
    var movies:[NSManagedObject]=[]
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
           do{
             try reachability.startNotifier()
           }catch{
             print("could not start reachability notifier")
           }
    }
    @objc func reachabilityChanged(note: Notification) {
     
      switch reachability.connection {
      case .wifi:
          print("----------------------------")
          print("Reachable via WiFi")
          print("----------------------------")
          getOfflineDataByCoreData()
      case .cellular:
          print("Reachable via Cellular")
      case .unavailable:
          print("----------------------------")
        print("Network not reachable")
          print("----------------------------")
          getDataByURLSession()
      case .none:
          print("")
      }
    }
    
    func getDataByURLSession(){
        // URL Session
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        
        let url = URL(string: "https://api.androidhive.info/json/movies.json")
                let req = URLRequest(url: url!)
                let session = URLSession(configuration: URLSessionConfiguration.default)
                let task = session.dataTask(with: req) { data, response, error in
                    do
                    {
                        let json = try! JSONDecoder().decode([MovieData].self, from:data!)
                        self.arrayMovies=json
                        
                        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MovieList")
                        self.movies = try! context.fetch(fetchRequest)
                        if self.movies.count==0 {
                            for i in 0..<self.arrayMovies.count {
                                let movie  = MovieList(context: context)
                                movie.title=self.arrayMovies[i].title
                                movie.releaseYear=Int64(self.arrayMovies[i].releaseYear!)
                                movie.rating=self.arrayMovies[i].rating!
                                movie.image=self.arrayMovies[i].image
                                movie.genre=self.arrayMovies[i].genre as NSObject?
                                try? context.save()
                            }
                            
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                task.resume()
        
    }
    func getDataByAlamofire(){
        // Alamofire
        guard let uRL=URL(string: "https://api.androidhive.info/json/movies.json") else {return}
        AF.request(uRL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).response{result in
            switch result.result{
            case .failure(_):
                print("Error")

            case .success(_):
                guard let data=result.data else{return}
                let json = try! JSONDecoder().decode([MovieData].self, from:data)
                self.arrayMovies=json
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getOfflineDataByCoreData(){
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let manageContext=appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MovieList")
        movies = try! manageContext.fetch(fetchRequest)
        for i in 0..<movies.count {
            arrayMovies[i].title=movies[i].value(forKey: "title") as? String
            arrayMovies[i].image=movies[i].value(forKey: "image") as? String
            arrayMovies[i].genre=movies[i].value(forKey: "genre") as? [String]
            arrayMovies[i].rating=movies[i].value(forKey: "rating") as? Double
            arrayMovies[i].releaseYear=movies[i].value(forKey: "releaseYear") as? Int
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print(movies.count)
        print(movies[0].value(forKey: "genre")!)
        print("----------------------------")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataByURLSession()
        
    }
    

    @IBAction func toAddBtn(_ sender: Any) {
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Movies"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMovies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text=arrayMovies[indexPath.row].title
//        cell.detailTextLabel?.text=String(arrayMovies[indexPath.row].rating!)
//        cell.imageView?.sd_setImage(with: URL(string: arrayMovies[indexPath.row].image!),placeholderImage:UIImage(named: "1"))
        
        (cell.viewWithTag(11) as! UILabel).text=arrayMovies[indexPath.row].title
        (cell.viewWithTag(10) as! UILabel).text=String(arrayMovies[indexPath.row].rating!)
        (cell.viewWithTag(12) as! UIImageView).sd_setImage(with: URL(string: arrayMovies[indexPath.row].image!), placeholderImage:UIImage(named: "1"))
        if let cosmos=arrayMovies[indexPath.row].rating{
            switch Int(cosmos) {
            case 10,9:
                (cell.viewWithTag(5) as! CosmosView).rating=5
                (cell.viewWithTag(5) as! CosmosView).settings.fillMode = .full

            case 8:
                (cell.viewWithTag(5) as! CosmosView).rating=4
                (cell.viewWithTag(5) as! CosmosView).settings.fillMode = .full
            case 7:
                (cell.viewWithTag(5) as! CosmosView).rating=3.5
                (cell.viewWithTag(5) as! CosmosView).settings.fillMode = .half
                break
            default:
                (cell.viewWithTag(5) as! CosmosView).rating=3
            }
        }
        cell.viewWithTag(12)?.layer.cornerRadius=22
        cell.viewWithTag(1)?.layer.borderColor=UIColor.lightGray.cgColor
        cell.viewWithTag(1)?.layer.borderWidth=0.3
        cell.viewWithTag(1)?.layer.shadowColor=UIColor.white.cgColor
        cell.viewWithTag(1)?.layer.shadowOpacity=0.4
       
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc=self.storyboard?.instantiateViewController(withIdentifier:"view") as! ViewController
        vc.object=arrayMovies[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            arrayMovies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    

}
