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

    private func makeImageViewModel() -> [ImageDataViewModel] {
        images.enumerated().map { index, name in
            ImageDataViewModel(id: index, image: UIImage(named: name)!)
        }
    }

    private func updateView() {
        mainView!.updateImages(listA: self.listA, listB: self.listB)
    }

    private func featurePrintForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
}

extension MainPresenter: MainPresenterHandler {

    func onCompareButtonTap() {
        guard let imageA = listA.first(where: { $0.selected }), let imageB = listB.first(where: { $0.selected }) else {
            self.mainView?.updateResult(value: "Please select two images")
            return
        }

        let sourceImageFeaturePrint = featurePrintForImage(image: imageA.image)

        let modelImageFeaturePrint = featurePrintForImage(image: imageB.image)
        let renderStart = Date()
        do{
            var distance = Float(0)
            if let sourceObservation = sourceImageFeaturePrint {
                try modelImageFeaturePrint?.computeDistance(&distance, to: sourceObservation)
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }

                    self.mainView?.updateResult(value: String(ceil(distance * 100) / 100.0))
                    self.mainView?.updateRenderDuration(duration: ceil((Date().timeIntervalSince(renderStart) * 1000) * 1000) / 1000.0)
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

    func onViewDidLoad() {
        updateView()
    }
}

struct ImageDataViewModel {
    let id: Int
    let image: UIImage
    var selected: Bool = false
}
