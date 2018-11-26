//
//  RaceViewController.swift
//  AnimationTask2
//
//  Created by vitali on 11/20/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class RaceViewController: UIViewController {
    
    //MARK: - Views
    
    @IBOutlet weak var raceView: RaceView!
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        raceView.delegate = self
    }
    
    //MARK: - Other
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        raceView.isEdited = editing
        
    }
    
}

//MARK: - RaceViewDelegate
extension RaceViewController: RaceViewDelegate {
    
    var alertControllerContext: UIViewController {
        get {
            return self
        }
    }
}

