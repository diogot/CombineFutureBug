//
//  FutureBug.swift
//  CombineFutureBug
//
//  Created by Diogo on 11/03/20.
//  Copyright © 2020 Standard. All rights reserved.
//

import Combine

enum Error: Swift.Error {
    case error
}

class Bug {

    func run() {
        crash()
//        dontCrash()
    }

    func crash() {
        let one = Future<String, Error> {
            $0(.failure(.error))
        }

        let two = Future<String, Error> {
            $0(.success("world"))
        }

        let cancelabel = Publishers.Zip(one, two).sink(receiveCompletion: {
            print($0)
        }, receiveValue: {
            print($0)
        })

        print(cancelabel)
    }

    func dontCrash() {
        let one = Single<String, Error> {
            return .failure(.error)
        }

        let two = Single<String, Error> {
            .success("world")
        }

        let cancelabel = Publishers.Zip(one, two).sink(receiveCompletion: {
            print($0)
        }, receiveValue: {
            print($0)
        })

        print(cancelabel)
    }
}
