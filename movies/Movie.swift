//
//  Movie.swift
//  movies
//
//  Created by Omar Ahmed on 02/02/2022.
//

import Foundation
class Movie{
    var title:String
    var image:String
    var rating:Float
    var releaseYear:Int
    var genre:[String]
    init(_title:String,_image:String,_rating:Float,_releaseYear:Int,_genre:[String])
    {
        title=_title
        image=_image
        rating=_rating
        releaseYear=_releaseYear
        genre=_genre
    }
    
    
    
    
}
