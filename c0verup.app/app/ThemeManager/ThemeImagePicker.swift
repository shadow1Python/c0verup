//
//  ThemeImagePicker.swift
//  Odyssey
//
//  Created by Amy While on 05/09/2020.
//  Copyright © 2020 coolstar. All rights reserved.
//

import UIKit

public protocol ThemeImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}

class ThemeImagePicker: NSObject, UINavigationControllerDelegate {
    public let pickerController: UIImagePickerController
    public weak var presentationController: ViewController!
    private weak var delegate: ThemeImagePickerDelegate?

    init(presentationController: ViewController, delegate: ThemeImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = false
        self.pickerController.mediaTypes = ["public.image"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.presentationController.resetPopTimer()
        }))

        if UIDevice.current.userInterfaceIdiom == .pad {
            let rect = self.presentationController.view.convert(sourceView.bounds, from: sourceView)
            alertController.popoverPresentationController?.sourceView = self.presentationController.view
            alertController.popoverPresentationController?.sourceRect = rect
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController.present(alertController, animated: true)
        self.presentationController.cancelPopTimer()
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(image: image)
    }
}

extension ThemeImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}
