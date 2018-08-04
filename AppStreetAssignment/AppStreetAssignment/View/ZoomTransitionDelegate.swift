//
//  ZoomingViewController.swift
//  AppStreetAssignment
//
//  Created by Dipika Madan on 04/08/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import UIKit

@objc
protocol ZoomingViewController{
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView?
}

enum TransitionState {
    case initial
    case final
}

class ZoomTransitioningDelegate: NSObject
{
    var transitionDuration = 0.5
    var operation: UINavigationControllerOperation = .none
    private let backgroundScale = CGFloat(0.5)
    
    func configureViews(for state: TransitionState, containerView: UIView, backgroundViewController: UIViewController, backgroundImageView: UIImageView, foregroundImageView: UIImageView, snapshotImageView: UIImageView)
    {
        switch state {
        case .initial:
            backgroundViewController.view.transform = CGAffineTransform.identity
            backgroundViewController.view.alpha = 1
            
            snapshotImageView.frame = containerView.convert(backgroundImageView.frame, from: backgroundImageView.superview)
            
        case .final:
            backgroundViewController.view.transform = CGAffineTransform(scaleX: backgroundScale, y: backgroundScale)
            backgroundViewController.view.alpha = 0
            
            snapshotImageView.frame = containerView.convert(foregroundImageView.frame, from: foregroundImageView.superview)
        }
    }
}

extension ZoomTransitioningDelegate : UIViewControllerAnimatedTransitioning
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let duration = transitionDuration(using: transitionContext)
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let containerView = transitionContext.containerView
        
        let backgroundVC = operation == .pop ? toVC: fromVC
        let foregroundVC = operation == .pop ? fromVC: toVC
        
        if let backgroundVC = backgroundVC, let foregroundVC = foregroundVC, let backgroundImageView = (backgroundVC as? ZoomingViewController)?.zoomingImageView(for: self), let foregroundImageView = (foregroundVC as? ZoomingViewController)?.zoomingImageView(for: self){
            
            let snapshotImage = operation == .pop ? backgroundImageView.image: foregroundImageView.image
            let imageViewSnapshot = UIImageView(image: snapshotImage)
            imageViewSnapshot.contentMode = .scaleAspectFit
            imageViewSnapshot.layer.masksToBounds = true
            
            backgroundImageView.isHidden = true
            foregroundImageView.isHidden = true
            let foregroundViewBackgroundColor = foregroundVC.view.backgroundColor
            foregroundVC.view.backgroundColor = UIColor.clear
            containerView.backgroundColor = UIColor.white
            
            containerView.addSubview(backgroundVC.view)
            containerView.addSubview(foregroundVC.view)
            containerView.addSubview(imageViewSnapshot)
            
            var preTransitionState = TransitionState.initial
            var postTransitionState = TransitionState.final
            
            if operation == .pop {
                preTransitionState = .final
                postTransitionState = .initial
            }
            
            configureViews(for: preTransitionState, containerView: containerView, backgroundViewController: backgroundVC, backgroundImageView: backgroundImageView, foregroundImageView: foregroundImageView, snapshotImageView: imageViewSnapshot)
            
            foregroundVC.view.layoutIfNeeded()
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
                
                self.configureViews(for: postTransitionState, containerView: containerView, backgroundViewController: backgroundVC, backgroundImageView: backgroundImageView, foregroundImageView: foregroundImageView, snapshotImageView: imageViewSnapshot)
                
            }) { (finished) in
                
                backgroundVC.view.transform = CGAffineTransform.identity
                imageViewSnapshot.removeFromSuperview()
                backgroundImageView.isHidden = false
                foregroundImageView.isHidden = false
                foregroundVC.view.backgroundColor = foregroundViewBackgroundColor
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

extension ZoomTransitioningDelegate : UINavigationControllerDelegate
{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is ZoomingViewController && toVC is ZoomingViewController {
            self.operation = operation
            return self
        } else {
            return nil
        }
    }
}













