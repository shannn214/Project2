//
//  CardDetailViewController.swift
//  Project2
//
//  Created by 尚靖 on 2018/5/21.
//  Copyright © 2018年 尚靖. All rights reserved.
//

import Foundation

protocol CardDetailDelegate: class {

    func cardDetailDidTransition(controller: CardDetailViewController)

}

class CardDetailViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cardViewWidth: NSLayoutConstraint!
    @IBOutlet weak var cardViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardImage: UIImageView!

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var shadowViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowViewWidth: NSLayoutConstraint!
    @IBOutlet weak var shadowViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var shadowViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet weak var cardContentLabel: UILabel!
    @IBOutlet weak var cardContentTextView: UIView!
    @IBOutlet weak var cardContentView: UIView!
    @IBOutlet weak var cardContentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardContentLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    var imageView: UIImageView!

    let initialPoint = CGPoint(x: 0, y: 0)

    weak var delegate: CardDetailDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()

    }

    func initialSetup() {

        cardView.layer.cornerRadius = 15
        cardViewWidth.constant = UIScreen.main.bounds.width * 0.3
        cardViewHeight.constant = UIScreen.main.bounds.width * 0.3
        cardViewLeadingConstraint.constant = UIScreen.main.bounds.width * 0.1
        cardViewTopConstraint.constant = UIScreen.main.bounds.width * 0.1
        cardContentTextView.layer.cornerRadius = 18

        shadowView.layer.cornerRadius = 15
        shadowViewWidth.constant = UIScreen.main.bounds.width * 0.3
        shadowViewHeight.constant = UIScreen.main.bounds.width * 0.3
        shadowViewLeadingConstraint.constant = UIScreen.main.bounds.width * 0.1
        shadowViewTopConstraint.constant = UIScreen.main.bounds.width * 0.1

        cardContentView.alpha = 0
        cardContentTopConstraint.constant = UIScreen.main.bounds.width * 0.3
        cardContentLeadingConstraint.constant = UIScreen.main.bounds.width * 0.1

        panGesture.delegate = self
        panGesture.isEnabled = false

        tapGesture.cancelsTouchesInView = false

    }

    @IBAction func tapped(_ sender: UITapGestureRecognizer) {

        switch sender.state {
        case .ended:

            let pop = PopView()
            pop.center = sender.location(in: view)
            view.addSubview(pop)

        default:
            break
        }

    }

    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {

        let touchPoint = sender.location(in: self.view.window)

        let touchTrans = sender.translation(in: self.view.window)

        if sender.state == UIGestureRecognizerState.began {
//            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {

            if touchPoint.y - initialPoint.y > 0 {

                self.view.frame = CGRect(x: touchTrans.x,
                                         y: touchTrans.y,
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height
                )

                UIView.animate(withDuration: 0.35) { [weak self] in

                    self?.backgroundView.alpha = 0

                    self?.cardContentView.alpha = 0
                    self?.cardContentTopConstraint.constant = UIScreen.main.bounds.width * 0.3
                    self?.view.layoutIfNeeded()

                }

                if touchTrans.y < 16 {
                    backgroundView.layer.cornerRadius = touchTrans.y
                }

                backgroundView.clipsToBounds = true

            }

        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {

            if touchTrans.y > 150 {
                // Back to cell view
                self.delegate?.cardDetailDidTransition(controller: self)

            } else {
                // Back to full screen
                UIView.animate(withDuration: 0.3,
                               animations: { [weak self] in

                                             self?.view.frame = CGRect(x: 0, y: 0,
                                                                       width: (self?.view.frame.size.width)!,
                                                                       height: (self?.view.frame.size.height)!
                                                                      )

                                             self?.backgroundView.alpha = 1
                                             self?.backgroundView.layer.cornerRadius = 0

                                             self?.cardContentView.alpha = 1
                                             self?.cardContentTopConstraint.constant = UIScreen.main.bounds.width

                })
            }

        }

    }

    func startToMoveContent() {

        UIView.animate(withDuration: 0.4) { [weak self] in

            if UIScreen.main.bounds.height > 740 {

                self?.cardContentView.alpha = 1
                self?.cardContentTopConstraint.constant = UIScreen.main.bounds.width * 1.1

            } else {

                self?.cardContentView.alpha = 1
                self?.cardContentTopConstraint.constant = UIScreen.main.bounds.width

            }

            self?.view.layoutIfNeeded()

        }

    }

    func pullBackContent() {

        UIView.animate(withDuration: 0.4) { [weak self] in

            self?.cardContentView.alpha = 0
            self?.cardContentTopConstraint.constant = UIScreen.main.bounds.width * 0.3

        }

    }

    func changeContraintToFullScreen() {

        backgroundView.layer.cornerRadius = 0

        cardViewLeadingConstraint.constant = UIScreen.main.bounds.width * 0.125
        cardViewWidth.constant = UIScreen.main.bounds.width * 0.75
        cardViewHeight.constant = UIScreen.main.bounds.width * 0.75

        self.cardContentView.alpha = 0
        self.cardContentTopConstraint.constant = UIScreen.main.bounds.width * 0.3
        cardContentLeadingConstraint.constant = UIScreen.main.bounds.width * 0.125

        view.layoutIfNeeded()
        panGesture.isEnabled = true

    }

    func changeConstraintToCellSize() {

        cardViewWidth.constant = UIScreen.main.bounds.width * 0.3
        cardViewHeight.constant = UIScreen.main.bounds.width * 0.3
        cardViewLeadingConstraint.constant = UIScreen.main.bounds.width * 0.1

        view.layoutIfNeeded()
        panGesture.isEnabled = false

    }

}

extension CardDetailViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return panGesture.isEnabled
    }

}
