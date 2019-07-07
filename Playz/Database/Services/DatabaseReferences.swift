//
//  DatabaseReferences.swift
//  Playz
//
//  Created by Johan on 27-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import Firebase

// DEVSCORCH: Variables

//Database reference

var DB_BASE = Database.database().reference()
var STORAGE_BASE = Storage.storage().reference()

class DatabaseReferences {
    
    static let ds = DatabaseReferences()
    
    // DatabaseChild References
    
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_FEED = DB_BASE.child("feed")
    private var _REF_NEWS = DB_BASE.child("news")
    private var _REF_FOLLOW = DB_BASE.child("following")
    private var _REF_FOLLOWERS = DB_BASE.child("followers")
    private var _REF_MY_POSTS = DB_BASE.child("my_posts")
    private var _REF_HASHTAG = DB_BASE.child("hash_tag")
    private var _REF_NOTIFICATION = DB_BASE.child("notification")
    private var _REF_COMMENTS = DB_BASE.child("comments")
    private var _REF_POST_COMMENTS = DB_BASE.child("post_comment")
    private var _REF_STORAGE_ROOT = "gs://challengeapp-da41c.appspot.com"
    private var _REF_CATEGORIES = DB_BASE.child("categories")
    private var _REF_VIEWS_COUNT = DB_BASE.child("views")
    
    // Database Child references for Child references
    
    // Action game database references

    private var _REF_SHOOTER_CATEGORY = DB_BASE.child("categories").child("shooter")
    private var _REF_PLATFORM_CATEGORY = DB_BASE.child("categories").child("platform")
    private var _REF_FIGHTING_CATEGORY = DB_BASE.child("categories").child("fighting")
    private var _REF_BEATMUP_CATEGORY = DB_BASE.child("categories").child("beatmup")
    private var _REF_STEALTH_CATEGORY = DB_BASE.child("categories").child("stealth")
    private var _REF_SURVIVAL_CATEGORY = DB_BASE.child("categories").child("survival")
    private var _REF_RHYTM_CATEGORY = DB_BASE.child("categories").child("rhytm")

    // Action adventure game database references
    
    private var _REF_SURVIVAL_HORROR_CATEGORY = DB_BASE.child("categories").child("survivial_horror")
    private var _REF_METROIDVANIA_CATEGORY = DB_BASE.child("categories").child("metroidvania")
    
    // Adventure game database reference
    
    private var _REF_TEXT_ADVENTURE_CATEGORY = DB_BASE.child("categories").child("text_adventure")
    private var _REF_GRAPHIC_ADVENTURE_CATEGORY = DB_BASE.child("categories").child("graphic_adventure")
    private var _REF_VISUAL_NOVEL_CATEGORY = DB_BASE.child("categories").child("visual_novel")
    private var _REF_INTERACTIVE_NOVEL_CATEGORY = DB_BASE.child("categories").child("interactive_movie")
    private var _REF_REAL_TIME_ADVENTURE_CATEGORY = DB_BASE.child("categories").child("realtime_adventure")
    
    // Role playing games database references
    
    private var _REF_MMORPG_CATEGORY = DB_BASE.child("categories").child("mmorpg")
    private var _REF_ACTIONRPG_CATEGORY = DB_BASE.child("categories").child("actionrpg")
    private var _REF_ROGUE_LIKE_CATEGORY = DB_BASE.child("categories").child("rogue_like")
    private var _REF_RPG_CATEGORY = DB_BASE.child("categories").child("rpg")
    private var _REF_TACTICAL_RPG = DB_BASE.child("categories").child("tacticalrpg")
    
    // STrategy games database reference
    
    private var _REF_RTS_CATEGORY = DB_BASE.child("categories").child("rts")
    private var _REF_STRATEGY_CATEGORY = DB_BASE.child("categories").child("strategy")
    private var _REF_BATTLEROYAL_CATEGORY = DB_BASE.child("categories").child("battleroyal")
    private var _REF_SANDBOX_RPG = DB_BASE.child("categories").child("sandbox_game")
    
    // Sport games database reference
    
    private var _REF_RACING_CATEGORY = DB_BASE.child("categories").child("racing")
    private var _REF_FOOTBALL_CATEGORY = DB_BASE.child("categories").child("football")
    
    // Secure DataReference setup
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_FEED: DatabaseReference {
        return _REF_FEED
    }
    
    var REF_FOLLOW: DatabaseReference {
        return _REF_FOLLOW
    }
    
    var REF_FOLLOWERS: DatabaseReference {
        return _REF_FOLLOWERS
    }
    
    var REF_NEWS: DatabaseReference {
        return _REF_NEWS
    }
    
    var REF_MY_POSTS: DatabaseReference {
        return _REF_MY_POSTS
    }
    
    var REF_HASHTAG: DatabaseReference {
        return _REF_HASHTAG
    }
    
    var REF_NOTIFICATIONS: DatabaseReference {
        return _REF_NOTIFICATION
    }
    
    var REF_COMMENTS: DatabaseReference {
        return _REF_COMMENTS
    }
    
    var REF_POST_COMMENTS: DatabaseReference {
        return _REF_POST_COMMENTS
    }
    
    var REF_STORAGE_ROOT: String {
        return _REF_STORAGE_ROOT
    }
    
    var REF_CATEGORIES: DatabaseReference {
        return _REF_CATEGORIES
    }
    
    var REF_VIEWS: DatabaseReference {
        return _REF_VIEWS_COUNT
    }
    
    // Database child references child Setups
    
    // Action game Setup
    
    var REF_SHOOTER_CATEGORY: DatabaseReference {
        return _REF_SHOOTER_CATEGORY
    }
    
    var REF_PLATFORM_CATEGORY: DatabaseReference {
        return _REF_PLATFORM_CATEGORY
    }
    
    var REF_FIGHTING_CATEGORY: DatabaseReference {
        return _REF_FIGHTING_CATEGORY
    }
    
    var REF_BEATMUP_CATEGORY: DatabaseReference {
        return _REF_BEATMUP_CATEGORY
    }
    
    var REF_STEALTH_CATEGORY: DatabaseReference {
        return _REF_STEALTH_CATEGORY
    }
    
    var REF_SURVIVAL_CATEGORY: DatabaseReference {
        return _REF_SURVIVAL_CATEGORY
    }
    
    var REF_RHYTM_CATEGORY: DatabaseReference {
        return _REF_RHYTM_CATEGORY
    }
    
    // Action Adventure game Setup
    
    var REF_SURVIVAL_HORROR_CATEGORY: DatabaseReference {
        return _REF_SURVIVAL_HORROR_CATEGORY
    }
    
    var REF_METROIDVANIA_CATEGORY: DatabaseReference {
        return _REF_METROIDVANIA_CATEGORY
    }
    
    // Adventure game Setup
    
    var REF_TEXT_ADVENTURE_CATEGORY: DatabaseReference {
        return _REF_TEXT_ADVENTURE_CATEGORY
    }
    
    var REF_GRAPHIC_ADVENTURE_CATEGORY: DatabaseReference {
        return _REF_GRAPHIC_ADVENTURE_CATEGORY
    }
    
    var REF_VISUAL_NOVEL_CATEGORY: DatabaseReference {
        return _REF_VISUAL_NOVEL_CATEGORY
    }
    
    var REF_INTERACTIVE_NOVEL_CATEGORY: DatabaseReference {
        return _REF_INTERACTIVE_NOVEL_CATEGORY
    }
    
    var REF_REAL_TIME_ADVENTURE_CATEGORY: DatabaseReference {
        return _REF_REAL_TIME_ADVENTURE_CATEGORY
    }
    
    // Role Playing Game Setup
    
    var REF_MMORPG_CATEGORY: DatabaseReference {
        return _REF_MMORPG_CATEGORY
    }
    
    var REF_ACTIONRPG_CATEGORY: DatabaseReference {
        return _REF_ACTIONRPG_CATEGORY
    }
    
    var REF_ROGUE_CATEGORY: DatabaseReference {
        return _REF_ROGUE_LIKE_CATEGORY
    }
    
    var REF_RPG_CATEGORY: DatabaseReference {
        return _REF_RPG_CATEGORY
    }
    
    var REF_TACTICAL_RPG_CATEGORY: DatabaseReference {
        return _REF_TACTICAL_RPG
    }
    
    // Strategy Games setup
    
    var REF_RTS_CATEGORY: DatabaseReference {
        return _REF_RTS_CATEGORY
    }
    
    var REF_STRATEGY_CATEGORY: DatabaseReference {
        return _REF_STRATEGY_CATEGORY
    }
    var REF_BATTLEROYAL_CATEGORY: DatabaseReference {
        return _REF_BATTLEROYAL_CATEGORY
    }
    
    var REF_SANDBOX_RPG_CATEGORY: DatabaseReference {
        return _REF_SANDBOX_RPG
    }
    
    // Sport games Setup
    
    var REF_RACING_CATEGORY: DatabaseReference {
        return _REF_RACING_CATEGORY
    }
    
    var REF_FOOTBALL_CATEGORY: DatabaseReference {
        return _REF_FOOTBALL_CATEGORY
    }
}
