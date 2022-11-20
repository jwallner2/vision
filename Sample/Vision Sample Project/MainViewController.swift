//
//  MainViewController.swift
//  Vision Sample Project
//
//  Created by Jean Wallner on 04/11/2022.
//

import Foundation
import UIKit

protocol MainViewInterface: UIViewController {
    func updateImages(listA: [ImageDataViewModel], listB: [ImageDataViewModel])
    func updateResult(value: String)
}

class MainViewController: UIViewController {
    private let presenter: MainPresenterHandler
    private var resultLabel: UILabel
    private var topCollectionView: UICollectionView
    private var bottomCollectionView: UICollectionView
    private var compareButton: UIButton
    private let reuseIdentifier = "cell"
    private var listA: [ImageDataViewModel]
    private var listB: [ImageDataViewModel]

    init(presenter: MainPresenterHandler) {
        self.presenter = presenter

        self.resultLabel = UILabel()
        self.resultLabel.translatesAutoresizingMaskIntoConstraints = false
        self.resultLabel.text = "Select two images"
        self.resultLabel.textColor = UIColor(named: "gray")
        self.resultLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)

        self.compareButton = UIButton()
        self.compareButton.translatesAutoresizingMaskIntoConstraints = false
        self.compareButton.setTitle("Compare", for: .normal)
        self.compareButton.backgroundColor = UIColor(named: "pink")
        self.compareButton.layer.cornerRadius = 10
        self.compareButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        self.compareButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        self.topCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.topCollectionView.register(CollectionCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        self.topCollectionView.backgroundColor = UIColor(named: "gray")
        self.topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.topCollectionView.showsHorizontalScrollIndicator = false

        self.bottomCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.bottomCollectionView.register(CollectionCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        self.bottomCollectionView.backgroundColor = UIColor(named: "gray")
        self.bottomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomCollectionView.showsHorizontalScrollIndicator = false

        self.listA = []
        self.listB = []

        super.init(nibName: nil, bundle: nil)

        topCollectionView.delegate = self
        bottomCollectionView.delegate = self

        topCollectionView.dataSource = self
        bottomCollectionView.dataSource = self

        compareButton.addTarget(self, action: #selector(compareButtonTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        presenter.onViewDidLoad()
        self.setupViewHierarchy()
        self.setupConstraints()
    }

    private func setupViewHierarchy() {
        self.view.addSubview(resultLabel)
        self.view.addSubview(topCollectionView)
        self.view.addSubview(bottomCollectionView)
        self.view.addSubview(compareButton)
    }

    private func setupConstraints() {
        resultLabel.topAnchor.constraint(equalTo: bottomCollectionView.bottomAnchor).isActive = true
        resultLabel.bottomAnchor.constraint(equalTo: compareButton.topAnchor).isActive = true
        resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        topCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48).isActive = true
        topCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topCollectionView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        bottomCollectionView.topAnchor.constraint(equalTo: topCollectionView.bottomAnchor, constant: -10).isActive = true
        bottomCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomCollectionView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        compareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        compareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48).isActive = true
    }

    @objc func compareButtonTap() {
        self.presenter.onCompareButtonTap()
    }
}

extension MainViewController: MainViewInterface {
    func updateImages(listA: [ImageDataViewModel], listB: [ImageDataViewModel]) {
        self.listA = listA
        self.listB = listB
        self.topCollectionView.reloadData()
        self.bottomCollectionView.reloadData()
    }

    func updateResult(value: String) {
        self.resultLabel.text = String(value)
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        if collectionView == self.topCollectionView {
            self.presenter.selectImageA(image: self.listA[indexPath.row])
            self.topCollectionView.reloadData()
        } else {
            self.presenter.selectImageB(image: self.listB[indexPath.row])
            self.bottomCollectionView.reloadData()
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.topCollectionView {
            return self.listA.count
        } else {
            return self.listB.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionCell
        if collectionView == self.topCollectionView {
            cell.setup(imageData: self.listA[indexPath.row])
            return cell
        } else {
            cell.setup(imageData: self.listB[indexPath.row])
            return cell
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 107, bottom: 0, right: 110)
    }
}

class CollectionCell: UICollectionViewCell {

    let imageView: UIImageView

    override init(frame: CGRect) {
        self.imageView = UIImageView()
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.borderColor = UIColor.clear.cgColor
        self.imageView.layer.borderWidth = 4

        super.init(frame: frame)

        self.clipsToBounds = true

        setupView()
        setupViewHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.backgroundColor = .white
    }

    private func setupViewHierarchy() {
        contentView.addSubview(imageView)
    }

    private func setupConstraints() {
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
    }

    func setup(imageData: ImageDataViewModel) {
        self.layer.cornerRadius = 10
        imageView.layer.cornerRadius = 10
        imageView.image = imageData.image
        self.imageView.layer.borderColor = imageData.selected ? UIColor(named: "pink")!.cgColor : UIColor.clear.cgColor
    }

}
