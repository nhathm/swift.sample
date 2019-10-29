Sample of create place holder for UITextView

```Swift
//
//  ViewController.swift
//  TextViewPlaceHolderDemo
//
//  Created by NhatHM on 10/27/19.
//  Copyright © 2019 GST.PID. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let placeholder = "Placeholder"
    @IBOutlet weak var textviewdemo: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        textviewdemo.delegate = self
        textviewdemo.text = placeholder
        textviewdemo.textColor = UIColor.lightGray
        textviewdemo.selectedTextRange = textviewdemo.textRange(from: textviewdemo.beginningOfDocument, to: textviewdemo.endOfDocument)
    }
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText: String = textView.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if updatedText.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            return false
        }
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}
```