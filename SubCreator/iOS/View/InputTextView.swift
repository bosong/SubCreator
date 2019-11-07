//
//  InputTextView.swift
//  SubCreator
//
//  Created by ripple_k on 2019/8/1.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InputTextView: UIView {
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    init() {
        super.init(frame: screenFrame)
        initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }
    
    var container = UIView()
    func initSubView() {
        self.addSubview(container)
        backgroundColor = UIColor.white
        keyboardHeight = safeAreaBottomMargin
        
        textHeight = textView.font?.lineHeight ?? 0
        textView.delegate = self
        addSubview(textView)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self,
                    let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return
                }
                let size = value.cgRectValue.size
                self.keyboardHeight =  UIInterfaceOrientation.portrait.isLandscape ? size.width : size.height
                self.updateTextViewFrame()
                self.backgroundColor = .white
                self.textView.textColor = .black
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.keyboardHeight = safeAreaBottomMargin
                self.updateTextViewFrame()
//                self.textView.textColor = .white
                self.backgroundColor = UIColor.white
            })
            .disposed(by: disposeBag)
    }
    
    private var textViewHeightSubject = PublishSubject<CGFloat>()
    var textViewHeightObservable: Observable<CGFloat> {
        return textViewHeightSubject.asObservable()
    }
    
    func updateTextViewFrame() {
        let textViewHeight = (keyboardHeight > safeAreaBottomMargin ?
            (textHeight + 2 * topBottomInset) :
            (textView.font?.lineHeight ?? 0) + 2 * topBottomInset) + 10
        
        textView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: textViewHeight)
        let inputTextViewY = keyboardHeight == 0 ? screenHeight - textViewHeight : screenHeight - keyboardHeight - textViewHeight
//        let inputTextViewY = screenHeight - keyboardHeight - textViewHeight
        frame = CGRect(x: 0, y: inputTextViewY, width: screenWidth, height: textViewHeight + keyboardHeight)
        textViewHeightSubject.onNext(frame.height)
    }
    
    deinit {
        textViewHeightSubject.onCompleted()
        _postSubject.onCompleted()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTextViewFrame()
    }
    
    var textHeight: CGFloat = 0
    var keyboardHeight: CGFloat = 0
    let leftRightInset: CGFloat = 20
    let topBottomInset: CGFloat = 15
    
    lazy var textView: UITextView = {
        var textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.placeholder = "赋予它灵魂……"
        textView.placeholderColor = UIColor.lightGray
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.returnKeyType = .done
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: topBottomInset, left: leftRightInset, bottom: topBottomInset, right: leftRightInset)
        textView.textContainer.lineBreakMode = .byTruncatingTail
        return textView
    }()
    
    var postObservable: Observable<String> {
        return _postSubject.asObservable()
    }
    private var _postSubject = PublishSubject<String>()
}

extension InputTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let attributeText = NSMutableAttributedString(attributedString: textView.attributedText)
        if !textView.hasText {
            textHeight = textView.font?.lineHeight ?? 0
        } else {
            textHeight = attributeText.contentSize(width: screenWidth - leftRightInset * 2).height
        }
        updateTextViewFrame()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            _postSubject.onNext(textView.text)
            textView.resignFirstResponder()
//            textView.text = ""
            textHeight = textView.font?.lineHeight ?? 0
            textView.resignFirstResponder()
        }
        return true
    }
}
