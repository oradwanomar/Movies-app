//
//  ViewController.swift
//  movies
//
//  Created by Omar Ahmed on 02/02/2022.
//

import UIKit
import Cosmos
import SDWebImage

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let genre=object?.genre{
            return genre.count
        }
        return object?.genre?.count ?? 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewGenre.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
        if let genreLabel=object?.genre{
            cell.textLabel?.text=object?.genre![indexPath.row]
        }
        return cell
    }
    

    @IBOutlet weak var imageMovie: UIImageView!
    
    @IBOutlet weak var movieName: UILabel!
    
    @IBOutlet weak var releaseYear: UILabel!
    
    @IBOutlet weak var rateMovie: UILabel!
    
    @IBOutlet weak var tableViewGenre: UITableView!
    
    @IBOutlet weak var rateView: CosmosView!
    
    
    var object:MovieData?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cosmos=object?.rating{
            switch Int(cosmos) {
            case 10,9:
                rateView.rating=5
                rateView.settings.fillMode = .full
            case 8:
                rateView.rating=4
                rateView.settings.fillMode = .full
            case 7:
                rateView.rating=3.5
                rateView.settings.fillMode = .half
                break
            default:
                rateView.rating=3
            }
        }
        if let name=object?.title{
            movieName.text=name
        }
        if let image=object?.image{
            imageMovie.sd_setImage(with: URL(string: image))
        }
        if let rate=object?.rating{
            rateMovie.text=String(rate)
        }
        if let rlYear=object?.releaseYear{
            releaseYear.text=String(rlYear)
        }
        
        
        
    }
}

