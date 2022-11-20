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

    private var images = [ImageDataViewModel(id: 0, image: UIImage(named: "cat1.JPG")!),
                          ImageDataViewModel(id: 1, image: UIImage(named: "cat2.JPG")!),
                          ImageDataViewModel(id: 2, image: UIImage(named: "cat3.jpg")!),
                          ImageDataViewModel(id: 3, image: UIImage(named: "cat4.jpg")!),
                          ImageDataViewModel(id: 4, image: UIImage(named: "cat5.jpg")!),
                          ImageDataViewModel(id: 5, image: UIImage(named: "cat6.jpg")!),
                          ImageDataViewModel(id: 6, image: UIImage(named: "cat7.jpg")!),
                          ImageDataViewModel(id: 7, image: UIImage(named: "cat8.jpg")!),
                          ImageDataViewModel(id: 8, image: UIImage(named: "cat9.jpg")!),
                          ImageDataViewModel(id: 9, image: UIImage(named: "cat10.jpg")!)]

    private var listA: [ImageDataViewModel]!

    private var listB: [ImageDataViewModel]!

    private func updateView() {
        self.listA = self.images
        self.listB = self.images
        mainView!.updateImages(listA: self.listA, listB: self.listB)
    }

    private func featurePrintForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        request.usesCPUOnly = true
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

        do{
            var distance = Float(0)
            if let sourceObservation = sourceImageFeaturePrint {
                try modelImageFeaturePrint?.computeDistance(&distance, to: sourceObservation)
                self.mainView?.updateResult(value: String(distance))
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
