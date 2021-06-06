//
//  ViewController.swift
//  Editing Tool
//
//  Created by Rajan Arora on 06/06/21.
//

import UIKit
import PhotoEditorSDK

class HomeViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet var btnGallery: UIButton!
    @IBOutlet var btnCamera: UIButton!
    
    // MARK: Members
    var imagePicker: ImagePicker!
    private var weatherProvider: OpenWeatherProvider = {
        var unit = TemperatureFormat.celsius
        if #available(iOS 10.0, *) {
            unit = .locale
        }
        let weatherProvider = OpenWeatherProvider(apiKey: nil, unit: unit)
        weatherProvider.locationAccessRequestClosure = { locationManager in
            locationManager.requestWhenInUseAuthorization()
        }
        return weatherProvider
    }()
    
    let helper = Helper()
    
    // MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Set the ImagePicker
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    // MARK: Helper Methods
    func setupUI() {
        helper.setGradientColoursAndRoundView(view: btnGallery)
        
        helper.setGradientColoursAndRoundView(view: btnCamera)
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            helper.showAlert(viewController: self, title: "Error", message: error.localizedDescription , style: .alert)
        } else {
            
            helper.showAlert(viewController: self, title: "Alert", message: "Your image has bees saved to your photos app.", style: .alert)
        }
    }
    
    // MARK: Actions
    @IBAction func openGallery(_ sender: Any) {
        self.imagePicker.present(from: sender as! UIView)
    }
    
    @IBAction func openCamera(_ sender: Any) {
        self.createCameraViewController()
    }
    
    
    // MARK: PhotoEditing Methods
    
    private func createPhotoEditViewController(with photo: Photo, and photoEditModel: PhotoEditModel = PhotoEditModel()) -> PhotoEditViewController {
        let configuration = buildConfiguration()
        
        // Create a photo edit view controller
        let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration, photoEditModel: photoEditModel)
        photoEditViewController.modalPresentationStyle = .fullScreen
        photoEditViewController.view.tintColor = .white
        photoEditViewController.toolbar.backgroundColor = UIColor(displayP3Red: 92.0/255.0, green: 82.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        photoEditViewController.delegate = self
        
        
        return photoEditViewController
    }
    
    private func createCameraViewController() {
        let configuration = Configuration { builder in
            // Setup global colors
            builder.theme.backgroundColor = .white
            builder.theme.menuBackgroundColor = UIColor(displayP3Red: 92.0/255.0, green: 82.0/255.0, blue: 217.0/255.0, alpha: 1.0)
            
            self.customizeCameraController(builder)
            self.customizePhotoEditorViewController(builder)
        }
        
        
        let cameraViewController = CameraViewController(configuration: configuration)
        cameraViewController.modalPresentationStyle = .fullScreen
        cameraViewController.locationAccessRequestClosure = { locationManager in
            locationManager.requestWhenInUseAuthorization()
        }
        
        cameraViewController.completionBlock = { [unowned cameraViewController] image, _ in
            if let image = image {
                let photo = Photo(image: image)
                let photoEditModel = cameraViewController.photoEditModel
                cameraViewController.present(self.createPhotoEditViewController(with: photo, and: photoEditModel), animated: true)
            }
        }
        
        cameraViewController.dataCompletionBlock = { [unowned cameraViewController] data in
            if let data = data {
                let photo = Photo(data: data)
                let photoEditModel = cameraViewController.photoEditModel
                cameraViewController.present(self.createPhotoEditViewController(with: photo, and: photoEditModel), animated: true)
            }
        }
        
        
        
        self.present(cameraViewController, animated: true, completion: nil)
    }
    
    fileprivate func customizeCameraController(_ builder: ConfigurationBuilder) {
        builder.configureCameraViewController { options in
            // Enable/Disable some features
            options.cancelButtonConfigurationClosure = { butn in
                butn.backgroundColor = UIColor(displayP3Red: 92.0/255.0, green: 82.0/255.0, blue: 217.0/255.0, alpha: 1.0)
                butn.tintColor = .white
                butn.addTarget(self, action: #selector(self.cancelTapped), for: .touchUpInside)
            }
            
            options.cropToSquare = true
            options.showFilterIntensitySlider = false
            options.tapToFocusEnabled = false
            
            // Use closures to customize the different view elements
            options.cameraRollButtonConfigurationClosure = { button in
                button.layer.borderWidth = 2.0
                button.layer.borderColor = UIColor(displayP3Red: 92.0/255.0, green: 82.0/255.0, blue: 217.0/255.0, alpha: 1.0).cgColor
            }
            
            
            
            options.timeLabelConfigurationClosure = { label in
                label.textColor = UIColor(displayP3Red: 92.0/255.0, green: 82.0/255.0, blue: 217.0/255.0, alpha: 1.0)
            }
            
            options.showCancelButton = true
            options.allowedRecordingModes = [.photo]
            
        }
    }
    
    private func buildConfiguration() -> Configuration {
        let configuration = Configuration { builder in
            
            // Setup UI
            builder.theme.backgroundColor = .white
            builder.theme.menuBackgroundColor = UIColor(displayP3Red: 92.0/255.0, green: 82.0/255.0, blue: 217.0/255.0, alpha: 1.0)
            
            // Configure editor
            builder.configurePhotoEditViewController { options in
                var menuItems = PhotoEditMenuItem.defaultItems
                menuItems.removeLast() // Remove last menu item ('Magic')
                
                options.menuItems = menuItems
            }
            
            // Configure sticker tool
            builder.configureStickerToolController { options in
                // Enable personal stickers
                options.personalStickersEnabled = true
                // Enable smart weather stickers
                options.weatherProvider = self.weatherProvider
            }
            
            
            self.customizePhotoEditorViewController(builder)
        }
        
        return configuration
    }
    
    fileprivate func customizePhotoEditorViewController(_ builder: ConfigurationBuilder) {
        // Customize the main editor
        builder.configurePhotoEditViewController { options in
            options.titleViewConfigurationClosure = { titleView in
                if let titleLabel = titleView as? UILabel {
                    titleLabel.text = "Photo Editor"
                }
            }
            
            options.actionButtonConfigurationClosure = { cell, _ in
                cell.contentTintColor = .white
            }
        }
    }
    
    
}

// ----------------------------------------
// MARK: ImagePicker Delegate Methods
// ----------------------------------------

extension HomeViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        guard let image = image else {return}
        
        self.present(createPhotoEditViewController(with: Photo(image: image)), animated: true, completion: nil)
    }
}


extension HomeViewController : PhotoEditViewControllerDelegate {
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        if let navigationController = photoEditViewController.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        if let navigationController = photoEditViewController.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        if let navigationController = photoEditViewController.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

