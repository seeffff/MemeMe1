//
//  ViewController.swift
//  Meme Me
//
//  Created by Joe DePhillipo on 3/1/17.
//  Copyright © 2017 NewWesternDev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate  {

    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var meme = Meme()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSStrokeWidthAttributeName: -5.0,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        ] as [String : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        initText(textField: topText)
        initText(textField: bottomText)
        memeImageView.image = nil
        shareButton.isEnabled = false
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        shareButton.isEnabled = false
        setupView()
    }
    
    @IBAction func addImageFromAlbum(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addImageFromCamera(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func shareMeme(_ sender: UIBarButtonItem) {
        let activityController = UIActivityViewController(activityItems: [makeMemeImage()], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {
            type, completed, returnedItems, error -> Void in
            if completed{
                self.saveMeme()
            }
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
    func initText(textField: UITextField){
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.textAlignment = NSTextAlignment.center
        textField.isHidden = true
    }
    
    func showMemeText(textField: UITextField, text: String){
        textField.isHidden = false
        
        if(textField == topText){
            topText.text = "TOP"
        }else if(textField == bottomText){
            bottomText.text = "BOTTOM"
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.dismiss(animated: true, completion: nil)
            self.memeImageView.image = image
            showMemeText(textField: topText, text: "TOP")
            showMemeText(textField: bottomText, text: "BOTTOM")
            shareButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        if bottomText.isFirstResponder && view.frame.origin.y == 0{
            view.frame.origin.y -= getKeyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        if bottomText.isFirstResponder && view.frame.origin.y != 0{
            view.frame.origin.y += getKeyboardHeight(notification: notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool     {
        topText.resignFirstResponder()
        bottomText.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == topText && topText.text == "TOP") {
            topText.text = ""
        } else if (textField == bottomText && bottomText.text == "BOTTOM") {
            bottomText.text = ""
        }
    }
    
    func makeMemeImage() -> UIImage {
        hideBars()
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let meme: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        showBars()
        
        return meme
    }
    
    func saveMeme(){
        meme = Meme(topText: topText.text, bottomText: bottomText.text, baseImage: memeImageView.image, memeImage: makeMemeImage())
    }
    
    func hideBars(){
        navBar.isHidden = true
        toolBar.isHidden = true
    }
    
    func showBars(){
        navBar.isHidden = false
        toolBar.isHidden = false
    }
}

