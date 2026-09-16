//
//  ConstraintsHelper.swift
//
//  Created by Karthi on 28/01/25.
//

import Foundation
import UIKit

// MARK: - NSLayoutDimension
extension NSLayoutDimension {
    struct Dimension {
        let constraint: NSLayoutDimension
        let constant: CGFloat?
        let multiplier: CGFloat
    }
    
    @discardableResult
    static func == (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalToConstant: rhs)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func <= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
        let constraint = lhs.constraint(lessThanOrEqualToConstant: rhs)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
}

// MARK: - NSLayoutXAxisAnchor

extension NSLayoutXAxisAnchor {
    struct Constraint {
        let constraint: NSLayoutXAxisAnchor
        let constant: CGFloat
    }
    
    @discardableResult
    static func == (lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalTo: rhs)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func == (lhs: NSLayoutXAxisAnchor, rhs: Constraint) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalTo: rhs.constraint, constant: rhs.constant)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func + (lhs: NSLayoutXAxisAnchor, rhs: CGFloat) -> Constraint {
        return Constraint(constraint: lhs, constant: rhs)
    }
    
    @discardableResult
    static func + (lhs: NSLayoutXAxisAnchor, rhs: Double) -> Constraint {
        return lhs + CGFloat(rhs)
    }
    
    @discardableResult
    static func - (lhs: NSLayoutXAxisAnchor, rhs: CGFloat) -> Constraint {
        return Constraint(constraint: lhs, constant: -rhs)
    }
}

// MARK: - NSLayoutYAxisAnchor

extension NSLayoutYAxisAnchor {
    struct Constraint {
        let constraint: NSLayoutYAxisAnchor
        let value: CGFloat
    }
    
    @discardableResult
    static func == (lhs: NSLayoutYAxisAnchor, rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalTo: rhs)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func == (lhs: NSLayoutYAxisAnchor, rhs: Constraint) -> NSLayoutConstraint {
        let constraint = lhs.constraint(equalTo: rhs.constraint, constant: rhs.value)
        constraint.isActive = true
        (constraint.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        return constraint
    }
    
    @discardableResult
    static func + (lhs: NSLayoutYAxisAnchor, rhs: CGFloat) -> Constraint {
        return Constraint(constraint: lhs, value: rhs)
    }
    
    @discardableResult
    static func - (lhs: NSLayoutYAxisAnchor, rhs: CGFloat) -> Constraint {
        return Constraint(constraint: lhs, value: -rhs)
    }
}

// MARK: - LayoutCenterAnchor

struct LayoutCenterAnchor {
    let centerX: NSLayoutXAxisAnchor
    let centerY: NSLayoutYAxisAnchor
    
    @discardableResult
    static func == (lhs: LayoutCenterAnchor, rhs: LayoutCenterAnchor) -> [NSLayoutConstraint] {
        let centerX = lhs.centerX == rhs.centerX
        let centerY = lhs.centerY == rhs.centerY
        return [centerX, centerY]
    }
}

// MARK: - LayoutEdgesAnchor

struct LayoutEdgesAnchor {
    let top: NSLayoutYAxisAnchor
    let trailing: NSLayoutXAxisAnchor
    let bottom: NSLayoutYAxisAnchor
    let leading: NSLayoutXAxisAnchor
    
    struct Constraint {
        let edges: LayoutEdgesAnchor
        let insets: UIEdgeInsets
    }
    
    @discardableResult
    static func == (lhs: LayoutEdgesAnchor, rhs: LayoutEdgesAnchor) -> [NSLayoutConstraint] {
        let top = lhs.top == rhs.top
        let trailing = lhs.trailing == rhs.trailing
        let bottom = lhs.bottom == rhs.bottom
        let leading = lhs.leading == rhs.leading
        return [top, trailing, bottom, leading]
    }
}

struct LayoutEdgesAnchorWithOutBottom {
    let top: NSLayoutYAxisAnchor
    let trailing: NSLayoutXAxisAnchor
    let leading: NSLayoutXAxisAnchor

    struct Constraint {
        let edges: LayoutEdgesAnchorWithOutBottom
        let insets: UIEdgeInsets
    }

    @discardableResult
    static func == (lhs: LayoutEdgesAnchorWithOutBottom, rhs: LayoutEdgesAnchorWithOutBottom) -> [NSLayoutConstraint] {
        let top = lhs.top == rhs.top
        let trailing = lhs.trailing == rhs.trailing
        let leading = lhs.leading == rhs.leading
        return [top, trailing, leading]
    }
}

struct LayoutEdgesAnchorWithOutTop {
    let bottom: NSLayoutYAxisAnchor
    let trailing: NSLayoutXAxisAnchor
    let leading: NSLayoutXAxisAnchor

    struct Constraint {
        let edges: LayoutEdgesAnchorWithOutTop
        let insets: UIEdgeInsets
    }

    @discardableResult
    static func == (lhs: LayoutEdgesAnchorWithOutTop, rhs: LayoutEdgesAnchorWithOutTop) -> [NSLayoutConstraint] {
        let bottom = lhs.bottom == rhs.bottom
        let trailing = lhs.trailing == rhs.trailing
        let leading = lhs.leading == rhs.leading
        return [bottom, trailing, leading]
    }
}

// MARK: - UIView

extension UIView {
    
    var leading: NSLayoutXAxisAnchor {
        return leadingAnchor
    }
    
    var trailing: NSLayoutXAxisAnchor {
        return trailingAnchor
    }
    
    var top: NSLayoutYAxisAnchor {
        return topAnchor
    }
    
    var bottom: NSLayoutYAxisAnchor {
        return bottomAnchor
    }
    
    var width: NSLayoutDimension {
        return widthAnchor
    }
    
    var height: NSLayoutDimension {
        return heightAnchor
    }
    
    var centerX: NSLayoutXAxisAnchor {
        return centerXAnchor
    }
    
    var centerY: NSLayoutYAxisAnchor {
        return centerYAnchor
    }
    
    var mid: LayoutCenterAnchor {
        return LayoutCenterAnchor(centerX: centerX, centerY: centerY)
    }
    
    var edges: LayoutEdgesAnchor {
        return LayoutEdgesAnchor(top: top, trailing: trailing, bottom: bottom, leading: leading)
    }

    var exceptTop: LayoutEdgesAnchorWithOutTop {
        return LayoutEdgesAnchorWithOutTop(bottom: bottom, trailing: trailing, leading: leading)
    }

    var exceptBottom: LayoutEdgesAnchorWithOutBottom {
        return LayoutEdgesAnchorWithOutBottom(top: top, trailing: trailing, leading: leading)
    }
    
    func addSubviews(with views: [UIView]) {
        views.forEach { (view) in
            addSubview(view)
        }
    }

    func bringSubviewsToFront(with views: [UIView]) {
        views.forEach { (view) in
            bringSubviewToFront(view)
        }
    }
}

extension CGFloat{
    static func ratioHeightBasedOniPhoneX(_ val: CGFloat) -> CGFloat{
        return UIScreen.main.bounds.height * (val/812)
    }
    
    static func ratioWidthBasedOniPhoneX(_ val: CGFloat) -> CGFloat{
        return UIScreen.main.bounds.width * (val/375)
    }
}

extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController , let selected = tab.selectedViewController {
            return topViewController(selected)
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        
        return viewController
    }
    
    func topViewController() -> UIViewController?{
        let keyWindow = Self.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
