import Foundation
import Combine

struct Single<Output, Failure>: Publisher where Failure: Swift.Error {

    let result: Result<Output, Failure>

    init(_ block: () -> Result<Output, Failure>) {
        result = block()
    }

    init(result: Result<Output, Failure>) {
        self.result = result
    }

    func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
        subscriber.receive(subscription: CustomSubscription(result: result, downstream: subscriber))
    }

    class CustomSubscription<Downstream: Subscriber>: Subscription where Output == Downstream.Input, Failure == Downstream.Failure {

        private(set) var downstream: Downstream?
        let result: Result<Output, Failure>

        init(result: Result<Output, Failure>, downstream: Downstream) {
            self.downstream = downstream
            self.result = result
        }

        func request(_ demand: Subscribers.Demand) {
            guard let downstream = self.downstream else {
                return
            }

            self.downstream = nil

            switch result {
            case .failure(let error):
                downstream.receive(completion: .failure(error))
            case .success(let value):
                if demand != .none {
                    _ = downstream.receive(value)
                }
                downstream.receive(completion: .finished)
            }
        }

        func cancel() {
            downstream = nil
        }
    }
}
