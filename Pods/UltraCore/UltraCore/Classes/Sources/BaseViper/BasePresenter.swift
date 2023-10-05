//
//  BasePresenter.swift
//  _NIODataStructures
//
//  Created by Slam on 4/25/23.
//

import RxSwift

class BasePresenter {
    
    lazy var disposeBag = DisposeBag()
    
    deinit {
        PP.info("Deinit \(String.init(describing: self))")
    }
}
