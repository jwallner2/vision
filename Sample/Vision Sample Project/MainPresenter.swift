//
//  MainPresenter.swift
//  Vision Sample Project
//
//  Created by Jean Wallner on 04/11/2022.
//

import Foundation
import UIKit
import CoreML
import Vision

protocol MainPresenterHandler: AnyObject {
    func onViewDidLoad()
    func onCompareButtonTap()
    func selectImageA(image: ImageDataViewModel)
    func selectImageB(image: ImageDataViewModel)
    func selectRevision(_ value: Int)
}

class MainPresenter {
    weak var mainView: MainViewInterface?

    private let images = [
        "cat.jpg", "catRotate.jpg", "catFilter.jpg", "cat-zoom.jpg", "cat-resized-one-third.jpg",
        "black.jpeg", "white.jpg", "noise.jpg",
        "cat1.jpg", "cat2.jpg", "cat3.jpg", "cat4.jpg", "cat5.jpg", "cat6.jpg", "cat7.jpg", "cat8.jpg", "cat9.jpg", "cat10.jpg",
        "d1.jpg", "n3.jpg"
    ]

    private lazy var listA = makeImageViewModel()

    private lazy var listB = makeImageViewModel()

    private var revision: Int

    private let durationFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private func makeImageViewModel() -> [ImageDataViewModel] {
        images.enumerated().map { index, name in
            ImageDataViewModel(id: index, image: UIImage(named: name)!)
        }
    }

    init() {
        if #available(iOS 17.0, *) {
            self.revision = VNGenerateImageFeaturePrintRequestRevision2
        } else {
            self.revision = VNGenerateImageFeaturePrintRequestRevision1
        }
    }

    private func updateView() {
        mainView!.updateImages(listA: self.listA, listB: self.listB)
    }

    func featurePrintForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(
            cgImage: image.cgImage!,
            options: [:]
        )
        do {
            let request = VNGenerateImageFeaturePrintRequest()
            request.revision = self.revision
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            return nil
        }
    }

    private func updateRevision() {
        mainView?.updateRevision(value: "Revision #\(self.revision)")
    }
}

private extension UIImage {
    var sizeDescInPix: String {
        "\(Int(size.width * scale))x\(Int(size.height * scale))"
    }
}

private extension Array where Array.Element == Float {

    func distance(_ rhs: Self) -> Float {
        assert(self.count == rhs.count)
        let d2 = self.enumerated().reduce(0) { res, cur in
            res + (cur.1 - rhs[cur.0]) * (cur.1 - rhs[cur.0])
        }
        return sqrt(d2)
    }

    var norm: Double {
        sqrt(reduce(Double(0)) { $0 + Double($1 * $1) })
    }
}

extension MainPresenter: MainPresenterHandler {

    func onCompareButtonTap() {
        guard let imageA = listA.first(where: { $0.selected }), let imageB = listB.first(where: { $0.selected }) else {
            self.mainView?.updateResult(value: "N/A")
            self.mainView?.updateRenderDetails("Please select two images")
            return
        }

        let featurePrintStart = Date()
        let sourceImageFeaturePrint = featurePrintForImage(image: imageA.image)
        let modelImageFeaturePrint = featurePrintForImage(image: imageB.image)

        let featurePrintEnd = Date()
        do{
            if let sourceObservation = sourceImageFeaturePrint, let modelObservation = modelImageFeaturePrint {

                var distance = Float(0)
                try modelObservation.computeDistance(&distance, to: sourceObservation)
                let endDate = Date()

                // Debug info
                let arrayA = sourceObservation.data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
                let arrayB = modelObservation.data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
                let distanceCheck = arrayA.distance(arrayB)
                print("Vector norms: \(arrayA.norm) and \(arrayB.norm)")
                print("Vision distance: \(distance) - recomputed distance: \(distanceCheck)")

                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }

                    self.mainView?.updateResult(value: String(ceil(distance * 100) / 100.0))

                    let featurePrintDuration = featurePrintEnd.timeIntervalSince(featurePrintStart) * 1000.0
                    let distanceDuration = endDate.timeIntervalSince(featurePrintEnd) * 1_000_000.0
                    let details = """
                    Feature print took: \(durationFormatter.string(from: featurePrintDuration as NSNumber)!) ms.
                    Distance computation took: \(durationFormatter.string(from: distanceDuration as NSNumber)!) µs.
                    Image sizes: \(imageA.image.sizeDescInPix) & \(imageB.image.sizeDescInPix)
                    """
                    self.mainView?.updateRenderDetails(details)
                }

            }
        } catch {
            self.mainView?.updateResult(value: "Error")
        }
    }

    func selectImageA(image: ImageDataViewModel) {
        listA = listA.map { image in
            var updatedImage = image
            updatedImage.selected = false
            return updatedImage
        }
        let index = listA.firstIndex { $0.id == image.id }!
        listA[index].selected = true
        updateView()
    }

    func selectImageB(image: ImageDataViewModel) {
        listB = listB.map { image in
            var updatedImage = image
            updatedImage.selected = false
            return updatedImage
        }
        let index = listB.firstIndex { $0.id == image.id }!
        listB[index].selected = true
        updateView()
    }

    func selectRevision(_ value: Int) {
        self.revision = value
        updateRevision()
        onCompareButtonTap()
    }

    func onViewDidLoad() {
        updateView()
        updateRevision()
    }
}

struct ImageDataViewModel {
    let id: Int
    let image: UIImage
    var selected: Bool = false
}
